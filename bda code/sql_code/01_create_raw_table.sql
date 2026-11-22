-- Step 1: Create Database and Raw External Table
CREATE DATABASE IF NOT EXISTS web_analytics;
USE web_analytics;

DROP TABLE IF EXISTS raw_access_logs;

CREATE EXTERNAL TABLE IF NOT EXISTS raw_access_logs (
    ip STRING,
    client_ident STRING,
    remote_user STRING,
    time_stamp STRING,
    method STRING,
    request_url STRING,
    protocol STRING,
    status_code INT,
    bytes_sent BIGINT,
    referer STRING,
    user_agent STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
    "input.regex" = "([^ ]*) +([^ ]*) +([^ ]*) +\\[([^]]+)\\] +\"([^ ]+) +([^ ]+) +([^ ]+)\" +(-|[0-9]+) +(-|[0-9]+) +\"([^\"]*)\" +\"([^\"]*)\"",
    "output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s %10$s %11$s"
)
STORED AS TEXTFILE;

-- Load data from local or HDFS directory
LOAD DATA LOCAL INPATH '../data/sample_access.log' OVERWRITE INTO TABLE raw_access_logs;

-- Verification
SELECT * FROM raw_access_logs LIMIT 5;