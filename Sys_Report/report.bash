#!/bin/bash

TIME=$(date +%F_%H-%M-%S)
TO=/var/log/sys_report_$TIME.txt
USER=$(whoami)
USERL=$(who)
process="ps"
memory="free"
disk="df"


echo "===== SYSTEM REPORT =====" > "$TO"
echo "$USER IN THE TIME $TIME MAKE THIS REPORT THAT SHOWS" >> "$TO"
echo "=================================" >> "$TO"

echo "USERS LOGGED IN AT $TIME:" >> "$TO"
echo "$USER" >> "$TO"
echo "=================================" >> "$TO"

echo -e "\n--- DISK USAGE ---" >> "$TO"
$disk -h >> "$TO"

echo -e "\n--- ACTIVE PROCESS ---" >> "$TO"
$process aux --sort=-%mem | head -n 10 >> "$TO"

echo -e "\n--- USE OF MEMORY ---" >> "$TO"
$memory -h >> "$TO"

echo -e "\nREPORT CREATED ON: $(date)" >> "$TO"
echo "=================================" >> "$TO"

echo "REPORT LOCATION: $TO"