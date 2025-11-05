#!/bin/zsh
set -eu

# REQUIREMENTS:
# - speedtest-cli (available for MacOS via Homebrew)
# - zsh

SCRIPT_DIR=$(dirname "$0")
mkdir -p "${SCRIPT_DIR}/logs"

LOGFILE="${SCRIPT_DIR}/logs/internetspeedmon_$(date +%Y-%m-%d).log"
touch "$LOGFILE"

touch "${SCRIPT_DIR}/logs/internetspeedmon_error.log"
date >> "${SCRIPT_DIR}/logs/internetspeedmon_error.log"

# Delete Average calculations from beginning of the file (will be recalculated)
sed -i '' '/-----------------------------/,$!d' "$LOGFILE"

echo "-----------------------------" >> "$LOGFILE"

date >> "$LOGFILE"

if /sbin/ifconfig "$(/usr/sbin/networksetup -listnetworkserviceorder 2> /dev/null | grep -E 'Hardware Port: .*LAN' | awk -F'Device: |\\)' '{print $2}')" | grep -q 'status: active'; then
        WIRED=1
        echo "Ethernet connection present" >> "$LOGFILE"
else
        WIRED=0
fi

# if ! [[ -x "/opt/homebrew/bin/speedtest-cli" ]]; then
#       echo "Tool speedtest-cli not found at its expected location (/opt/homebrew/bin/speedtest-cli)" >> "$LOGFILE"
#       exit 1
# fi

if [[ "$WIRED" -eq 0 ]]; then
        # Find out Wi-Fi SSID
        # SSID=$(for i in ${(o)$(ifconfig -lX "en[0-9]")};do /usr/sbin/ipconfig getsummary ${i} | awk '/ SSID/ {print $NF}';done 2> /dev/null)
        # SSID=$(/usr/sbin/networksetup -getairportnetwork en0 2>> "${SCRIPT_DIR}/logs/internetspeedmon_error.log")
        SSID=$(system_profiler SPAirPortDataType | sed -n '/Current Network Information:/,/PHY Mode:/ p' | head -2 | tail -1 | sed 's/^[[:space:]]*//' | sed 's/:$//' 2>> "${SCRIPT_DIR}/logs/internetspeedmon_error.log")
        if [[ -n "$SSID" ]]; then
                echo "Network: $SSID" >> "$LOGFILE"
        else
                echo "cannot determine network connection. check the script" >> "$LOGFILE"
        fi

        # Run speedtest-cli and write output to log file
        /opt/homebrew/bin/speedtest-cli --simple --secure >> "$LOGFILE" 2>> "${SCRIPT_DIR}/logs/internetspeedmon_error.log"
fi


### Calculating Averages ###

AVG="Average Speeds per Wi-Fi Network:\n"

# Retrieve all known Wi-Fi SSIDs
NETWORKS=$(grep -i "Network: " "$LOGFILE" | awk -F'Network: ' '{print $2}' | sort | uniq | awk 'NF')

# Calculate average down/up speeds for each Wi-Fi network
while IFS= read -r NETWORK; do
    DOWNSPEED=$(grep -i -F -A 2 "$NETWORK" "$LOGFILE" | grep -i "Download" | awk -F'Download: | Mbit/s' '{print $2}' | awk '{sum+=$1; count++} END {if (count>0) print sum / count}')
    UPSPEED=$(grep -i -F -A 3 "$NETWORK" "$LOGFILE" | grep -i "Upload" | awk -F'Upload: | Mbit/s' '{print $2}' | awk '{sum+=$1; count++} END {if (count>0) print sum / count}')
    PING=$(grep -i -F -A 1 "$NETWORK" "$LOGFILE" | grep -i "Ping" | awk -F'Ping: | ms' '{print $2}' | awk '{sum+=$1; count++} END {if (count>0) print sum / count}')
    
    if [[ -n "$NETWORK" ]]; then
        AVG+=$'\n'"${NETWORK}: Ping ${PING} ms, Download ${DOWNSPEED} Mb/s, Upload ${UPSPEED} Mb/s"
    fi
done <<< "$NETWORKS"

# Prepend AVG calculations to log file
{ echo -e "$AVG"; echo "\n\nIndividual Results:"; cat "$LOGFILE"; } > temp && mv temp "$LOGFILE"

exit

