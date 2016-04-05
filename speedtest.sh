#!/bin/bash
source $(dirname $0)/conf.txt

sqlite3 $database_name "create table if not exists speedtest (id integer primary key autoincrement, timestamp integer, host_distance real, response_time real, download_speed real, upload_speed real);"

speedtest_result=`$speedtest_path`
host_line=`echo "$speedtest_result" | grep -E 'Hosted by '`
host_distance=`echo "$host_line" | grep -oE '\[.*\]' | grep -Eo '([0-9]+\.[0-9]+)'`
response_time=`echo "$host_line" | grep -oE '[0-9]+\.[0-9]+ ms' | grep -Eo '([0-9]+\.[0-9]+)'`
download_speed=`echo "$speedtest_result" | grep -E 'Download:' | grep -Eo '([0-9]+\.[0-9]+)'`
upload_speed=`echo "$speedtest_result" | grep -E 'Upload:' | grep -Eo '([0-9]+\.[0-9]+)'`

sqlite3 $database_name "insert into speedtest (timestamp, host_distance, response_time, download_speed, upload_speed) values (CURRENT_TIMESTAMP, $host_distance, $response_time, $download_speed, $upload_speed);"