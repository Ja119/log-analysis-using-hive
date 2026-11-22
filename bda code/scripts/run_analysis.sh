#!/usr/bin/env bash
set -e

echo "=== [1/3] Creating Raw Table & Loading Logs ==="
hive -f ../sql/01_create_raw_table.sql

echo "=== [2/3] Transforming & Partitioning into ORC Format ==="
hive -f ../sql/02_create_orc_table.sql

echo "=== [3/3] Running Analytical Queries ==="
hive -f ../sql/03_analytics_queries.sql

echo "=== Analysis Complete! ==="