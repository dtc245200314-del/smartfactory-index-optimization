USE codegym_smartfactory;
SET SESSION information_schema_stats_expiry=0;
SELECT 'BEFORE' AS phase, TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH,
       ROUND(INDEX_LENGTH/1024/1024,2) AS index_mb
FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='SensorLogs';
EXPLAIN SELECT temperature, humidity, status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
-- Add the replacement and drop the audited old index in one rebuild operation.
ALTER TABLE SensorLogs DROP INDEX idx_fat_covering,
    ADD INDEX idx_lean_search(sensor_id, recorded_at);
ANALYZE TABLE SensorLogs;
-- Run storage_snapshot.sql in a NEW connection to avoid stale pre-DDL engine statistics.
SHOW INDEX FROM SensorLogs;
EXPLAIN SELECT temperature, humidity, status FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
SELECT COUNT(*) AS returned_rows FROM SensorLogs
WHERE sensor_id=105 AND recorded_at >= '2026-06-20';
