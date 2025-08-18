FROM property
JOIN property_accessibility
    ON property.accessibility_id = property_accessibility.property_accessibility_key AND property.src_web = property_accessibility.src_web
JOIN property_construction_type
    ON property.construction_type_id = property_construction_type.property_construction_type_key AND property.src_web = property_construction_type.src_web
JOIN property_electricity
    ON property.electricity_id = property_electricity.property_electricity_key AND property.src_web = property_electricity.src_web
JOIN property_gas
    ON property.gas_id = property_gas.property_gas_key AND property.src_web = property_gas.src_web
JOIN property_heating
    ON property.heating_id = property_heating.property_heating_key AND property.src_web = property_heating.src_web
JOIN property_location
    ON property.location_id = property_location.property_location_key AND property.src_web = property_location.src_web
JOIN property_parking
    ON property.parking_id = property_parking.property_parking_key AND property.src_web = property_parking.src_web
JOIN property_price
    ON property.property_id = property_price.property_id AND property.src_web = property_price.src_web
JOIN property_subtype
    ON property.subtype_id = property_subtype.property_subtype_key AND property.src_web = property_subtype.src_web
JOIN property_type
    ON property.type_id = property_type.property_type_key AND property.src_web = property_type.src_web
JOIN property_water_supply
    ON property.water_supply_id = property_water_supply.property_water_supply_key AND property.src_web = property_water_supply.src_web
JOIN property_image
    ON property.property_id = property_image.property_id AND property.src_web = property_image.src_web
JOIN property_h
    ON property.property_id = property_h.property_id AND property.src_web = property_h.src_web

JOIN property_price_h
    ON property_price.property_id = property_price_h.property_id AND property_price.src_web = property_price_h.src_web
