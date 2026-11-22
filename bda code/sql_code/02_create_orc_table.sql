-- Step 2: Create Optimized ORC Table with Dynamic Partitioning
USE web_analytics;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;

DROP TABLE IF EXISTS access_logs_orc;

CREATE TABLE IF NOT EXISTS access_logs_orc (
    ip STRING,
    client_ident STRING,
    remote_user STRING,
    log_time TIMESTAMP,
    method STRING,
    request_url STRING,
    protocol STRING,
    status_code INT,
    bytes_sent BIGINT,
    referer STRING,
    user_agent STRING
)
PARTITIONED BY (log_date STRING)
STORED AS ORC
TBLPROPERTIES (
    "orc.compress" = "SNAPPY",
    "orc.create.index" = "true"
);

-- Insert & transform into ORC format
INSERT OVERWRITE TABLE access_logs_orc PARTITION (log_date)
SELECT 
    ip,
    client_ident,
    remote_user,
    -- Converts '22/Nov/2026:10:15:32 +0000' to Hive Timestamp
    from_unixtime(unix_timestamp(time_stamp, 'dd/MMM/yyyy:HH:mm:ss Z')) AS log_time,
    method,
    request_url,
    protocol,
    status_code,
    CASE 
        WHEN bytes_sent IS NULL OR bytes_sent = -1 THEN 0 
        ELSE bytes_sent 
    END AS bytes_sent,
    referer,
    user_agent,
    -- Extract YYYY-MM-DD for table partitioning
    from_unixtime(unix_timestamp(time_stamp, 'dd/MMM/yyyy:HH:mm:ss Z'), 'yyyy-MM-dd') AS log_date
FROM raw_access_logs
WHERE ip IS NOT NULL;