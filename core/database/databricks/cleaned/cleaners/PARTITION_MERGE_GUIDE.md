# Partition-Aware MERGE Optimization Guide

## 🎯 Klíčové změny pro partitioned tabulky

### 1. **Explicit Partition Pruning v JOIN podmínkách**

**❌ Původní (bez partition pruning):**
```sql
ON target.property_id = source.property_id
  AND target.src_web = source.src_web
  AND target.del_flag = false
```

**✅ Optimized (s partition pruning):**
```sql
ON target.property_id = source.property_id
  AND target.src_web = source.src_web        -- Dynamic partition filter
  AND target.src_web = 'bidli'               -- Static partition pruning
  AND target.del_flag = false
```

### 2. **Hardcoded Partition Value v Source**

**❌ Původní (parametr):**
```sql
:cleaner AS src_web,  -- Může způsobit problémy s partition pruning
```

**✅ Optimized (hardcoded):**
```sql
'bidli' AS src_web,   -- Explicitní hodnota pro lepší optimalizaci
```

### 3. **Partition-Aware WHERE clauses**

Všechny WHERE podmínky by měly obsahovat partition filter:

```sql
-- V source query
FROM realitky.raw.listing_details_bidli
WHERE listing_details_bidli.del_flag = false
-- Implicit partition pruning - source je již jen bidli

-- V monitoring queries
WHERE upd_process_id = :process_id
  AND src_web = 'bidli'  -- Explicit partition pruning
```

## 🚀 Performance Benefits

### Před partitioning:
- MERGE skenuje **celou tabulku**
- **Vysoké riziko** Delta conflicts
- **Pomalé** JOIN operace
- **Neoptimální** resource usage

### Po partitioning:
- MERGE skenuje **pouze jednu partition**
- **Minimální riziko** Delta conflicts
- **Rychlé** partition-pruned JOINy
- **Optimální** resource usage

## 📊 Monitoring Partition Performance

```sql
-- Zkontrolovat, které partitions byly touchnuty
DESCRIBE DETAIL realitky.cleaned.property_price;

-- Partition statistics
SELECT 
    src_web,
    COUNT(*) as row_count,
    MAX(upd_dt) as last_update
FROM realitky.cleaned.property_price 
GROUP BY src_web
ORDER BY src_web;

-- Delta history s partition info
DESCRIBE HISTORY realitky.cleaned.property_price 
WHERE operationParameters.predicate IS NOT NULL;
```

## ⚡ Best Practices pro Concurrent Processing

### 1. **Separate Scripts per Source**
- `raw2clean_idnes_property_price.sql` - pouze idnes
- `raw2clean_bidli_property_price.sql` - pouze bidli  
- `raw2clean_sreality_property_price.sql` - pouze sreality

### 2. **Explicit Partition Values**
Každý script má hardcoded svůj src_web:
```sql
'idnes' AS src_web     -- v idnes script
'bidli' AS src_web     -- v bidli script
'sreality' AS src_web  -- v sreality script
```

### 3. **Job Coordination**
```python
# Spuštění concurrent jobs
job_configs = [
    {'src_web': 'idnes', 'script': 'raw2clean_idnes_property_price.sql'},
    {'src_web': 'bidli', 'script': 'raw2clean_bidli_property_price.sql'},
    {'src_web': 'sreality', 'script': 'raw2clean_sreality_property_price.sql'}
]

# Parallel execution - každý job pracuje s vlastní partition
for config in job_configs:
    run_job_async(config)
```

## 🔍 Troubleshooting

### Problem: Delta conflicts i přes partitioning
**Řešení:** Zkontrolujte, že JOIN podmínky obsahují explicit partition filter

### Problem: Pomalý MERGE i přes partition pruning  
**Řešení:** Aktivujte dynamic partition pruning:
```sql
SET spark.sql.optimizer.dynamicPartitionPruning.enabled = true;
```

### Problem: Partition skew
**Řešení:** Monitorujte velikost partitions:
```sql
SELECT 
    src_web,
    COUNT(*) as row_count,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage
FROM realitky.cleaned.property_price 
GROUP BY src_web;
```
