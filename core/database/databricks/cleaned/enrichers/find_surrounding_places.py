import requests
import json
import time
import pandas as pd
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *
from typing import List, Dict, Optional
import concurrent.futures
from datetime import datetime

# Initialize Spark session
spark = SparkSession.builder.appName("POI_Enrichment").getOrCreate()

# Configuration
dbutils.widgets.text("api_key", "your_geoapify_api_key", "Geoapify API Key")
dbutils.widgets.text("batch_size", "50", "Batch Size")
dbutils.widgets.text("process_id", "POI_001", "Process ID")
dbutils.widgets.text("radius_meters", "5000", "Search Radius in Meters")

api_key = dbutils.widgets.get("api_key")
batch_size = int(dbutils.widgets.get("batch_size"))
process_id = dbutils.widgets.get("process_id")
radius_meters = int(dbutils.widgets.get("radius_meters"))

print(f"Configuration:")
print(f"- Batch size: {batch_size}")
print(f"- Process ID: {process_id}")
print(f"- Search radius: {radius_meters}m")

# POI Category mapping to Geoapify categories
POI_CATEGORY_MAPPING = {
    'transport_bus': ['public_transport.bus'],
    'transport_tram': ['public_transport.tram'],
    'transport_metro': ['public_transport.subway'],
    'transport_train': ['public_transport.railway'],
    'restaurant': ['catering.restaurant', 'catering.fast_food', 'catering.cafe'],
    'shop': ['commercial.shopping_mall', 'commercial.supermarket', 'commercial.marketplace'],
    'school': ['education.school', 'education.university', 'education.nursery'],
    'healthcare': ['healthcare.hospital', 'healthcare.clinic', 'healthcare.pharmacy'],
    'sports': ['sport.fitness', 'sport.stadium', 'activity.sport_club'],
    'industry': ['industrial.factory', 'industrial.warehouse'],
    'airport': ['public_transport.airport'],
    'power_plant': ['industrial.power'],
    'highway': ['highway.motorway', 'highway.trunk']
}

class POIEnricher:
    def __init__(self, api_key: str, radius_meters: int = 5000):
        self.api_key = api_key
        self.radius_meters = radius_meters
        self.base_url = 'https://api.geoapify.com/v2/places'
        
    def get_poi_for_property(self, property_id: str, lat: float, lng: float, category_id: str) -> List[Dict]:
        """Get POI for a single property and category"""
        try:
            # Get category mapping
            categories = POI_CATEGORY_MAPPING.get(category_id, [category_id])
            
            # Get max results for this category
            max_results = self._get_max_results_for_category(category_id)
            
            all_pois = []
            
            for category in categories:
                params = {
                    'categories': category,
                    'filter': f'circle:{lng},{lat},{self.radius_meters}',
                    'limit': max_results,
                    'apiKey': self.api_key
                }
                
                response = requests.get(self.base_url, params=params, timeout=30)
                response.raise_for_status()
                
                data = response.json()
                
                if 'features' in data:
                    for idx, feature in enumerate(data['features']):
                        poi_record = self._parse_poi_feature(
                            feature, property_id, category_id, lat, lng, idx + 1
                        )
                        if poi_record:
                            all_pois.append(poi_record)
                
                # Rate limiting
                time.sleep(0.1)
                
            return all_pois
            
        except Exception as e:
            print(f"Error fetching POI for property {property_id}, category {category_id}: {e}")
            return []
    
    def _get_max_results_for_category(self, category_id: str) -> int:
        """Get maximum results based on category"""
        limits = {
            'transport_bus': 10,
            'transport_tram': 10,
            'transport_metro': 5,
            'transport_train': 3,
            'restaurant': 5,
            'shop': 5,
            'school': 5,
            'healthcare': 5,
            'sports': 10,
            'industry': 5,
            'airport': 1,
            'power_plant': 1,
            'highway': 2
        }
        return limits.get(category_id, 5)
    
    def _parse_poi_feature(self, feature: Dict, property_id: str, category_id: str, 
                          property_lat: float, property_lng: float, rank: int) -> Optional[Dict]:
        """Parse POI feature from API response"""
        try:
            props = feature.get('properties', {})
            geometry = feature.get('geometry', {})
            coordinates = geometry.get('coordinates', [])
            
            if len(coordinates) < 2:
                return None
                
            poi_lng, poi_lat = coordinates[0], coordinates[1]
            
            # Calculate distance
            distance_km = self._calculate_distance(
                property_lat, property_lng, poi_lat, poi_lng
            )
            
            # Generate POI ID
            poi_id = f"{property_id}_{category_id}_{rank}_{int(time.time())}"
            
            # Extract attributes
            attributes = {}
            
            # Common attributes
            if 'datasource' in props:
                attributes['data_source'] = props['datasource'].get('sourcename', 'unknown')
            
            if 'contact' in props:
                contact = props['contact']
                if 'phone' in contact:
                    attributes['phone'] = str(contact['phone'])
                if 'email' in contact:
                    attributes['email'] = contact['email']
            
            if 'website' in props:
                attributes['website'] = props['website']
                
            # Category specific attributes
            if category_id.startswith('transport_'):
                if 'public_transport' in props:
                    attributes.update(props['public_transport'])
            elif category_id == 'restaurant':
                if 'cuisine' in props:
                    attributes['cuisine'] = props['cuisine']
                if 'rating' in props:
                    attributes['rating'] = str(props['rating'])
            
            poi_record = {
                'poi_id': poi_id,
                'property_id': property_id,
                'category_id': category_id,
                'poi_name': props.get('name', 'Unknown'),
                'poi_address': props.get('formatted', ''),
                'poi_lat': poi_lat,
                'poi_lng': poi_lng,
                'distance_km': round(distance_km, 3),
                'distance_walking_min': self._estimate_walking_time(distance_km),
                'distance_driving_min': self._estimate_driving_time(distance_km),
                'rank_in_category': rank,
                'poi_attributes': attributes,
                'data_source': 'geoapify',
                'data_quality_score': 1.0,
                'ins_dt': datetime.now(),
                'ins_process_id': process_id,
                'upd_dt': datetime.now(),
                'upd_process_id': process_id,
                'del_flag': False
            }
            
            return poi_record
            
        except Exception as e:
            print(f"Error parsing POI feature: {e}")
            return None
    
    def _calculate_distance(self, lat1: float, lng1: float, lat2: float, lng2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        import math
        
        R = 6371  # Earth's radius in kilometers
        
        lat1_rad = math.radians(lat1)
        lat2_rad = math.radians(lat2)
        delta_lat = math.radians(lat2 - lat1)
        delta_lng = math.radians(lng2 - lng1)
        
        a = (math.sin(delta_lat / 2) * math.sin(delta_lat / 2) +
             math.cos(lat1_rad) * math.cos(lat2_rad) *
             math.sin(delta_lng / 2) * math.sin(delta_lng / 2))
        
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        distance = R * c
        
        return distance
    
    def _estimate_walking_time(self, distance_km: float) -> int:
        """Estimate walking time in minutes (assuming 5 km/h)"""
        return int(distance_km * 12)  # 60 minutes / 5 km/h = 12 minutes per km
    
    def _estimate_driving_time(self, distance_km: float) -> int:
        """Estimate driving time in minutes (assuming 30 km/h in city)"""
        return int(distance_km * 2)  # 60 minutes / 30 km/h = 2 minutes per km

# Initialize POI enricher
enricher = POIEnricher(api_key, radius_meters)

# Get properties with GPS coordinates
print("Loading properties with GPS coordinates...")
properties_query = """
SELECT 
    property_id,
    address_latitude,
    address_longitude
FROM realitky.cleaned.properties
WHERE address_latitude IS NOT NULL 
AND address_longitude IS NOT NULL
AND address_latitude BETWEEN 48.0 AND 51.0  -- Czech Republic bounds
AND address_longitude BETWEEN 12.0 AND 19.0
AND del_flag = FALSE
"""

df_properties = spark.sql(properties_query)
total_properties = df_properties.count()
print(f"Found {total_properties} properties with valid GPS coordinates")

# Show sample
df_properties.show(5)

# Get POI categories
categories_df = spark.sql("SELECT category_id FROM realitky.cleaned.poi_categories")
categories = [row.category_id for row in categories_df.collect()]
print(f"POI Categories to process: {categories}")

# Process properties in batches
def process_property_batch(property_batch: List, categories: List[str]) -> List[Dict]:
    """Process a batch of properties for all POI categories"""
    all_pois = []
    
    for property_data in property_batch:
        property_id = property_data['property_id']
        lat = property_data['address_latitude']
        lng = property_data['address_longitude']
        
        print(f"Processing property: {property_id}")
        
        for category_id in categories:
            try:
                pois = enricher.get_poi_for_property(property_id, lat, lng, category_id)
                all_pois.extend(pois)
                
                # Rate limiting between categories
                time.sleep(0.2)
                
            except Exception as e:
                print(f"Error processing {property_id} - {category_id}: {e}")
                continue
        
        # Rate limiting between properties
        time.sleep(1)
    
    return all_pois

# Convert to list for processing
properties_list = [row.asDict() for row in df_properties.limit(batch_size).collect()]

print(f"Processing {len(properties_list)} properties...")

# Process batch
start_time = time.time()
poi_results = process_property_batch(properties_list, categories)
end_time = time.time()

print(f"Processed {len(properties_list)} properties in {end_time - start_time:.2f} seconds")
print(f"Found {len(poi_results)} POI records")

# Convert results to DataFrame and save
if poi_results:
    # Create DataFrame from results
    df_poi_results = spark.createDataFrame(poi_results)
    
    print("Sample POI results:")
    df_poi_results.show(5, truncate=False)
    
    # Insert into POI table
    df_poi_results.write \
        .mode("append") \
        .option("mergeSchema", "true") \
        .saveAsTable("realitky.cleaned.property_poi")
    
    print(f"✅ Successfully inserted {len(poi_results)} POI records")
    
    # Show statistics
    stats_query = f"""
    SELECT 
        category_id,
        COUNT(*) as poi_count,
        COUNT(DISTINCT property_id) as properties_count,
        ROUND(AVG(distance_km), 3) as avg_distance_km,
        MIN(distance_km) as min_distance_km,
        MAX(distance_km) as max_distance_km
    FROM realitky.cleaned.property_poi
    WHERE ins_process_id = '{process_id}'
    GROUP BY category_id
    ORDER BY poi_count DESC
    """
    
    print("POI Statistics:")
    spark.sql(stats_query).show()
    
else:
    print("❌ No POI data found")

# Create summary statistics
summary_query = f"""
SELECT 
    COUNT(DISTINCT property_id) as properties_processed,
    COUNT(*) as total_poi_found,
    COUNT(DISTINCT category_id) as categories_found,
    ROUND(AVG(distance_km), 3) as avg_distance_km
FROM realitky.cleaned.property_poi
WHERE ins_process_id = '{process_id}'
"""

print("Overall Summary:")
spark.sql(summary_query).show()

print(f"""
=== POI ENRICHMENT COMPLETED ===

✅ **Results:**
- Properties processed: {len(properties_list)}
- POI records created: {len(poi_results)}
- Process ID: {process_id}

🔄 **Next Steps:**
1. Update property_poi_summary table
2. Calculate location scores
3. Verify data quality
4. Scale to full dataset

⚠️ **Important Notes:**
- This is a limited batch processing
- For full dataset, implement proper batching
- Monitor API rate limits
- Consider caching results

💰 **API Usage:**
- Estimated calls: {len(properties_list) * len(categories)}
- Geoapify free tier: 3,000 requests/day
- Consider upgrading for production use
""")