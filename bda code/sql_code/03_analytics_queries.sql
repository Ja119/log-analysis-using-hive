-- Step 3: Analytical Queries for Web Access Logs
USE web_analytics;

-- 1. Top 10 Most Visited Pages / Endpoints
SELECT 
    request_url,
    COUNT(*) AS total_hits
FROM access_logs_orc
WHERE status_code = 200
GROUP BY request_url
ORDER BY total_hits DESC
LIMIT 10;

-- 2. HTTP Status Code Breakdown (Error Rate Analysis)
SELECT 
    status_code,
    COUNT(*) AS request_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM access_logs_orc
GROUP BY status_code
ORDER BY request_count DESC;

-- 3. Top 10 IP Addresses by Traffic Volume & Bandwidth
SELECT 
    ip,
    COUNT(*) AS total_requests,
    ROUND(SUM(bytes_sent) / 1024, 2) AS total_kb,
    ROUND(SUM(bytes_sent) / (1024 * 1024), 4) AS total_mb
FROM access_logs_orc
GROUP BY ip
ORDER BY total_requests DESC
LIMIT 10;

-- 4. Hourly Traffic Trends (Peak Usage Hours)
SELECT 
    HOUR(log_time) AS hour_of_day,
    COUNT(*) AS total_requests,
    ROUND(SUM(bytes_sent) / (1024 * 1024), 2) AS bandwidth_mb
FROM access_logs_orc
GROUP BY HOUR(log_time)
ORDER BY hour_of_day ASC;

-- 5. Top 10 External Referrers (Where visitors come from)
SELECT 
    referer,
    COUNT(*) AS referral_count
FROM access_logs_orc
WHERE referer != '-' 
  AND referer != ''
  AND referer NOT LIKE '%example.com%'
GROUP BY referer
ORDER BY referral_count DESC
LIMIT 10;

-- 6. Missing Resources & Broken Links (404 Detection)
SELECT 
    request_url,
    referer,
    COUNT(*) AS not_found_count
FROM access_logs_orc
WHERE status_code = 404
GROUP BY request_url, referer
ORDER BY not_found_count DESC;

-- 7. Distribution of HTTP Methods
SELECT 
    method,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM access_logs_orc
GROUP BY method
ORDER BY count DESC;