USE codegym_smartfactory;
SET SESSION information_schema_stats_expiry=0;
SELECT 'AFTER (new connection)' AS phase, TABLE_ROWS, DATA_LENGTH, INDEX_LENGTH,
       ROUND(INDEX_LENGTH/1024/1024,2) AS index_mb
FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='SensorLogs';
