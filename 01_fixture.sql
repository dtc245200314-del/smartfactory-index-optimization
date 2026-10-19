CREATE DATABASE IF NOT EXISTS codegym_smartfactory CHARACTER SET utf8mb4;
USE codegym_smartfactory;
CREATE TABLE SensorLogs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sensor_id INT NOT NULL,
    recorded_at DATETIME NOT NULL,
    temperature DECIMAL(5,2),
    humidity DECIMAL(5,2),
    status VARCHAR(20)
) ENGINE=InnoDB;
CREATE INDEX idx_fat_covering ON SensorLogs(sensor_id, recorded_at, temperature, humidity, status);
CREATE TABLE digits (n INT PRIMARY KEY);
INSERT INTO digits VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
INSERT INTO SensorLogs(sensor_id, recorded_at, temperature, humidity, status)
SELECT MOD(seq.n,1000)+1, TIMESTAMP('2026-06-01')+INTERVAL seq.n MINUTE,
       20+MOD(seq.n,1500)/100, 30+MOD(seq.n,6000)/100,
       ELT(MOD(seq.n,3)+1,'NORMAL','WARNING','CRITICAL')
FROM (SELECT a.n+10*b.n+100*c.n+1000*d.n+10000*e.n AS n
      FROM digits a CROSS JOIN digits b CROSS JOIN digits c CROSS JOIN digits d CROSS JOIN digits e) seq;
DROP TABLE digits;
ANALYZE TABLE SensorLogs;
SELECT COUNT(*) AS fixture_rows FROM SensorLogs;
