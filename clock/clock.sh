#!/bin/bash

### C L O C K  I N / O U T ###

### Author: murmile ###

### REQUIREMENTS ####
# Config for Bash environment:
# alias clockin='function _clockin() { [PATH_TO_SCRIPT]/clock.sh in "$@"; }; _clockin'
# alias clockout='function _clockout() { [PATH_TO_SCRIPT]/clock.sh out "$@"; }; _clockout'
# alias clock='function _clock() { [PATH_TO_SCRIPT]/clock.sh }; _clock'
# alias clockopen='function _clockopen() { [PATH_TO_SCRIPT]/clock.sh open; }; _clockopen'
# alias clockedit='function _clockedit() { [PATH_TO_SCRIPT]/clock.sh edit; }; _clockedit'

shopt -s extglob  # Enable extended globbing

# Get the directory of the script
SCRIPT_DIR=$(dirname "$0")

touch "$SCRIPT_DIR/clock.log"

# Expecting first parameter to be either "in" (clock in), "out" (clock out) or "open" (to open time tracking .txt file)
if [[ $1 ]]; then
	
	# Analysing second parameter (time specifications) - if existing - and defining time to be clocked
    	if [[ $2 ]]; then    
		if [[ $2 == +([0-9]):+([0-9]) ]]; then
			clocker=$(date +"%Y-%m-%d $2:00")
		elif [[ $2 == ++([0-9]) ]]; then
			timediff=$(echo "$2" | grep -o '[0-9]\+')	
            		clocker=$(date -j -v +"$timediff"M +"%Y-%m-%d %H:%M:%S")
        	elif [[ $2 == -+([0-9]) ]]; then
            		timediff=$(echo "$2" | grep -o '[0-9]\+')	
			clocker=$(date -j -v -"${timediff}"M +"%Y-%m-%d %H:%M:%S")
        	else
            		echo "### invalid parameters ###"
			echo "# ------------- clock usage: ------------- #"
			echo "clockin [hh:mm]|[+|- mm] - clock in at specified OR current time +/- x min"
			echo "clockout [hh:mm]|[+|- mm] - clock out at specified OR current time +/- x min"
			echo "clock - show clock status"
			echo "clockopen - open clock.log file"
			echo ""
			echo "clockin          # example 1: clock in at current time"
			echo "clockin 08:30    # example 2: clock in at 08:30"
			echo "clockout -10     # example 3: clock out 10 minutes ago"
			echo "# ---------------------------------------- #"
            		exit 1
        	fi
				
	else
        	clocker=$(date +"%Y-%m-%d %H:%M:%S")
	fi
    
	# If clocking "in"
	if [[ "$1" == "in" ]]; then
    		echo "#clockin $clocker"
    		echo "#clockin $clocker" >> "$SCRIPT_DIR/clock.log"
		exit 1
	
	# If clocking "out"
	elif [[ "$1" == "out" ]]; then
		
		echo "$clocker"
	    
		### Calculate working hours between clock events
		
	    	last=$(tail -n 1 "$SCRIPT_DIR/clock.log" | xargs)
			
			# Confirming a preceding clock "in" event
	    	if [[ "$last" == *"in"* ]]; then
	        	lastclockin="${last#*#clockin }"
			lastclockin="${lastclockin//\[\] /}"
	        	lastclockintime=$(date -j -f "%Y-%m-%d %H:%M:%S" "$lastclockin" +"%s")
	        	clockouttime=$(date -j -f "%Y-%m-%d %H:%M:%S" "$clocker" +"%s")
	        	workminutes=$(( (clockouttime - lastclockintime) / 60 ))  # convert seconds to minutes
	    	else
	        	echo "warning: no prior clock-in"
			echo "clock-in missing" >> "$SCRIPT_DIR/clock.log"
			workminutes=0
	    	fi
	
		hours=$(( workminutes / 60 ))
		minutes=$(( workminutes % 60 ))
		workingtime=$(printf "%d:%02d" "$hours" "$minutes")
		
		###

	    	echo "#clockout $clocker (hours worked: $workingtime)"
	    	echo "#clockout $clocker (hours worked: $workingtime)" >> "$SCRIPT_DIR/clock.log"
	
		exit 1

	# If editing .log file
	elif [[ "$1" == "edit" ]]; then
		vi "$SCRIPT_DIR/clock.log"
		exit 1		
	
	# If opening .log file for viewing
	elif [[ "$1" == "open" ]]; then
		open "$SCRIPT_DIR/clock.log"
		exit 1
	else
        	echo "### invalid parameters ###"
		echo "# ------------- clock usage: ------------- #"
	    	echo "clockin [hh:mm]|[+|- mm] - clock in at specified OR current time +/- x min"
	    	echo "clockout [hh:mm]|[+|- mm] - clock out at specified OR current time +/- x min"
	    	echo "clock - show clock status"
		echo "clockopen - open clock.log file"
		echo ""
		echo "clockin          # example 1: clock in at current time"
		echo "clockin 08:30    # example 2: clock in at 08:30"
		echo "clockout -10     # example 3: clock out 10 minutes ago"
		echo "# ---------------------------------------- #"
        	exit 1
	fi

# If no parameters, show current clock status and info
elif [[ -z "$1" ]]; then
	echo ""
        echo "### recent entries: ###"
        echo "$(tail -n 6 $SCRIPT_DIR/clock.log)"
	echo ""

    	echo "#### clock status ####"
	
	last=$(tail -n 1 "$SCRIPT_DIR/clock.log")
	
    	if [[ $last == *"in"* ]]; then
		# currently clocked in
		# figure out working hours in current clockin event
		last=$(tail -n 1 "$SCRIPT_DIR/clock.log" | xargs)
		lastclockin="${last#*#clockin }"
        	lastclockin="${lastclockin//\[\] /}"
        	lastclockintime=$(date -j -f "%Y-%m-%d %H:%M:%S" "$lastclockin" +"%s")
		lastclockinday=$(date -j -f "%Y-%m-%d %H:%M:%S" "$lastclockin" +"%Y-%m-%d")
		currenttime=$(date +%s)
		workminutes=$(( (currenttime - lastclockintime) / 60 ))  # convert seconds to minutes
		hours=$(( workminutes / 60 ))
        	minutes=$(( workminutes % 60 ))
        	workingtime=$(printf "%d:%02d" "$hours" "$minutes")
		if [[ $lastclockinday < $(date +"%Y-%m-%d") ]]; then
			read -p "The clockout event of a previous day is missing - enter retrospectively [hh:mm]: " lastclockout
			echo "#clockout $lastclockinday $lastclockout:00 (entered in retrospective)" >> "$SCRIPT_DIR/clock.log"
			echo "Clockout for $lastclockinday added..."
			sleep 1
			$SCRIPT_DIR/clock.sh
			exit 1
		else
			echo "currently clocked in (working time: $workingtime)"
		fi


    	elif [[ $last == *"out"* ]]; then
        	# currently clocked out
		echo "currently clocked out"
    	else
        	echo "no clock status available - check clock.log for syntax errors"
    	fi
	
    	echo ""
	echo "# ------------- clock usage: ------------- #"
    	echo "clockin [hh:mm]|[+|- mm] - clock in at specified OR current time +/- x min"
    	echo "clockout [hh:mm]|[+|- mm] - clock out at specified OR current time +/- x min"
    	echo "clock - show clock status"
	echo "clockopen - open clock.log file"
	echo ""
	echo "clockin          # example 1: clock in at current time"
	echo "clockin 08:30    # example 2: clock in at 08:30"
	echo "clockout -10     # example 3: clock out 10 minutes ago"
	echo "# ---------------------------------------- #"
	exit 1
fi
