#!/bin/bash

source $(dirname $0)/conf.txt

rm -f out
mkfifo out
trap "rm -f out" EXIT
while true
do
  cat out | nc -l $port > >( # parse the netcat output, to build the answer redirected to the pipe "out".
    export REQUEST=
    export HOST=
    while read line
    do
      line=$(echo "$line" | tr -d '[\r\n]')

      if echo "$line" | grep -qE '^GET /' # if line starts with "GET /"
      then
        REQUEST=$(echo "$line" | cut -d ' ' -f2) # extract the request
      elif echo "$line" | grep -qE '^Host: ' # if line starts with "Host: "
      then
        HOST=$(echo "$line" | grep -E "Host: " | cut -d ' ' -f2)
      elif [ "x$line" = x ] # empty line / end of request
      then
        HTTP_200="HTTP/1.1 200 OK"
        HTTP_LOCATION="Location:"
        HTTP_404="HTTP/1.1 404 Not Found"
        # call a script here
        # Note: REQUEST is exported, so the script can parse it (to answer 200/403/404 status code + content)
        if echo $REQUEST | grep -qE '^/api/speedtest/average'
        then
            sqlite3 $database_name "select count(1), round(avg(response_time), 2), round(avg(download_speed), 2), round(avg(upload_speed), 2) from speedtest" | awk -F'|' '
   # sqlite output line - pick up fields and store in arrays
   { count[++i]=$1; response_time[i]=$2; download_speed[i]=$3; upload_speed[i]=$4 }

   END {
      printf "[\n";
      for(j=1;j<=i;j++){
         printf "  {\n"
         printf "    |count|:%d,\n",count[j]
         printf "    |response_time|:%s,\n",response_time[j]
         printf "    |download_speed|:%s,\n",download_speed[j]
         printf "    |upload_speed|:%s\n",upload_speed[j]
         closing="  },\n"
         if(j==i){closing="  }\n"}
         printf closing;
      }
      printf "]\n";
   }' | tr '|' '"' > out
        elif echo $REQUEST | grep -qE '^/api/speedtest/worst'
        then
            sqlite3 $database_name "select count(1), max(response_time), min(download_speed), min(upload_speed) from speedtest" | awk -F'|' '
   # sqlite output line - pick up fields and store in arrays
   { count[++i]=$1; response_time[i]=$2; download_speed[i]=$3; upload_speed[i]=$4 }

   END {
      printf "[\n";
      for(j=1;j<=i;j++){
         printf "  {\n"
         printf "    |count|:%d,\n",count[j]
         printf "    |response_time|:%s,\n",response_time[j]
         printf "    |download_speed|:%s,\n",download_speed[j]
         printf "    |upload_speed|:%s\n",upload_speed[j]
         closing="  },\n"
         if(j==i){closing="  }\n"}
         printf closing;
      }
      printf "]\n";
   }' | tr '|' '"' > out
        elif echo $REQUEST | grep -qE '^/api/speedtest/best'
        then
            sqlite3 $database_name "select count(1), min(response_time), max(download_speed), max(upload_speed) from speedtest" | awk -F'|' '
   # sqlite output line - pick up fields and store in arrays
   { count[++i]=$1; response_time[i]=$2; download_speed[i]=$3; upload_speed[i]=$4 }

   END {
      printf "[\n";
      for(j=1;j<=i;j++){
         printf "  {\n"
         printf "    |count|:%d,\n",count[j]
         printf "    |response_time|:%s,\n",response_time[j]
         printf "    |download_speed|:%s,\n",download_speed[j]
         printf "    |upload_speed|:%s\n",upload_speed[j]
         closing="  },\n"
         if(j==i){closing="  }\n"}
         printf closing;
      }
      printf "]\n";
   }' | tr '|' '"' > out
        elif echo $REQUEST | grep -qE '^/api/speedtest'
        then
            sqlite3 $database_name "SELECT * FROM speedtest ORDER BY id DESC LIMIT 1000" | awk -F'|' '
   # sqlite output line - pick up fields and store in arrays
   { id[++i]=$1; timestamp[i]=$2; host_distance[i]=$3; response_time[i]=$4; download_speed[i]=$5; upload_speed[i]=$6 }

   END {
      printf "[\n";
      for(j=1;j<=i;j++){
         printf "  {\n"
         printf "    |id|:%d,\n",id[j]
         printf "    |timestamp|:|%s|,\n",timestamp[j]
         printf "    |host_distance|:%s,\n",host_distance[j]
         printf "    |response_time|:%s,\n",response_time[j]
         printf "    |download_speed|:%s,\n",download_speed[j]
         printf "    |upload_speed|:%s\n",upload_speed[j]
         closing="  },\n"
         if(j==i){closing="  }\n"}
         printf closing;
      }
      printf "]\n";
   }' | tr '|' '"' > out
        elif echo $REQUEST | grep -qE '^/api/'
        then
            echo "
            {
                |speedtest|: {
                    |lasts|: |http://$HOST/api/speedtest|,
                    |average|: |http://$HOST/api/speedtest/average|,
                    |best|: |http://$HOST/api/speedtest/best|,
                    |worst|: |http://$HOST/api/speedtest/worst|
                }
            }
            " | tr '|' '"' > out
        else
            cat $(dirname $0)$REQUEST > out
            #printf "%s\n%s %s\n\n%s\n" "$HTTP_404" "$HTTP_LOCATION" $REQUEST "Resource $REQUEST NOT FOUND!" > out
        fi
      fi
    done
  )
done