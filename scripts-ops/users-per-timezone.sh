#!/bin/bash
# Given this users API: https://randomuser.me/api?results=50
# Write a script that will optionally accept a timezone value and will print the list of users on the given timezone following a summary in the first line. If no timezone is given, then your script will list all the users without a summary line.
# Users should be printed with only their names flattened as <title> <name> <surname>; e.g: Mr Daniel Wuollet

# Sample output for <your_script> -t +10:00

# 2/50 users in timezone +10:00
# Madame Roswitha Barbier
# Miss Nicoline Mortensen

# Sample output (without timezone) for <your_script>

# Ms Mandy Collins
# Miss Emeli Nesland
# Miss Ariana Wood
# Miss Norma Patiño
#

#curl --silent https://randomuser.me/api?results=1 | jq '.results[] | "\(.location.timezone)"'
# curl --silent https://randomuser.me/api?results=50 | jq '.results[] | "\(.name) \(.location.timezone)"'| sed -e 's/\\"/ /g' | sed -e 's/first \':'/ /g' | sed -e 's/\"{ title :/ /g' | awk '{ print $1,$3,$7,$12 }'

if [ $# -eq 2 ] && [ "$1" = "-t" ]; then
    TIMEZONE=$2
    RESULT=$(curl --silent https://randomuser.me/api?results=50 | \
        jq -r '.results[] | "\(.name.title) \(.name.first) \(.name.last) \(.location.timezone)"')
    
    COUNT=$(echo "$RESULT" | grep -c "$TIMEZONE")
    
    printf "%d/50 users in timezone %s\n" "$COUNT" "$TIMEZONE"
    echo "$RESULT" | grep "$TIMEZONE" | cut -d' ' -f1-3
else
    curl --silent https://randomuser.me/api?results=50 | \
        jq -r '.results[] | "\(.name.title) \(.name.first) \(.name.last)"'
fi
