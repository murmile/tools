# clock.sh
A simple CLI tool for tracking working hours - punch in and out quickly via terminal window and keep record

**Installation:**
1. Place script in desired directory
2. Add the following to your ~/.bashrc (or e.g. ~/.zshrc if using other shells):
```
alias clockin='function _clockin() { [PATH_TO_SCRIPT]/clock.sh in "$@"; }; _clockin'
alias clockout='function _clockout() { [PATH_TO_SCRIPT]/clock.sh out "$@"; }; _clockout'
alias clock='function _clock() { [PATH_TO_SCRIPT]/clock.sh }; _clock'
alias clockopen='function _clockopen() { [PATH_TO_SCRIPT]/clock.sh open; }; _clockopen'
```

**Usage:**
```
clockin [hh:mm]|[+|- mm] - clock in at specified OR current time +/- x min
clockout [hh:mm]|[+|- mm] - clock out at specified OR current time +/- x min
clock - show clock status
clockopen - open clock.txt file

clockin          # example 1: clock in at current time
clockin 08:30    # example 2: clock in at 08:30
clockout -10     # example 3: clock out 10 minutes ago
```
