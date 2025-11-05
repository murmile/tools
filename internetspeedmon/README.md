# internetspeedmon.sh
Run Internet speedtests on a regular basis using the speedtest-cli tool and crontab - it keeps records and calculates average connection speeds per WiFi SSID as well as individual test results

**Requirements:**
1. speedtest-cli (available via Homebrew)
2. zshell

**Usage:**
1. Place script in desired directory
2. Run script
```
# either directly via CLI
cd <path_to_script> && ./internetspeedmon.sh
# or on a scheduled basis as crontab (e.g. at minute 50 of every hour between 07:00-09:00 and 16:00-23:00)
50 7-9,16-23 * * * cd <path_to_script> && ./internetspeedmon.sh
```
3. A log folder will be created within the same directory, in which a daily log file will display average and momentary speeds across all WiFi networks that were connected to

# ---------------------------------------------- #
