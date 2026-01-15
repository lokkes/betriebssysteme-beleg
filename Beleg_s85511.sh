#!/bin/bash

if [ $# -gt 2 ] || [ $# -eq 0 ]; then

        echo "usage : <Rechnername/IP-Adress> <Datum : TT.MM.JJJJ>"
        exit 1
fi

input="$1"
datum="$2"

process_host(){

        local host="$1"

        # prevent blocking longer than a few seconds
        cert_output=$(echo -n | timeout 5 openssl s_client -connect "$host":443 2>/dev/null)

        expiry=$(echo "$cert_output" | grep "NotAfter:" | head -n 1 | sed 's/.*NotAfter: //')

        #error handling in case there is no certificate present
        # -z checks if the string is empty

        if [ -z "$expiry" ]; then
                echo "Failed to retrieve certificate for $host"
                return 1
        fi

        expiry_seconds=$(date -d "$expiry" +%s 2>/dev/null)
        if [ -z "$expiry_seconds" ]; then
                echo "Failed to parse certificate date for $host"
                return 1
        fi

        #optional second variable
        #-n checks if sting s not empty
        # linux dont understand TT.MM.YYYY so format to --> YYYY.MM.TT

        if [ -n "$datum" ]; then

                # manual format validation TT.MM.JJJJ
                if [[ ! "$datum" =~ ^([0-9]{2})\.([0-9]{2})\.([0-9]{4})$ ]]; then
                        echo "Invalid date format: $datum"
                        return 1
                fi

                day=${datum:0:2}
                month=${datum:3:2}
                year=${datum:6:4}

                if (( day < 1 || day > 31 || month < 1 || month > 12 )); then
                        echo "Invalid date value: $datum"
                        return 1
                fi

                datum_formatted="$year-$month-$day"
                ref_seconds=$(date -d "$datum_formatted" +%s 2>/dev/null)

                if [ -z "$ref_seconds" ]; then
                        echo "Invalid reference date: $datum"
                        return 1
                fi

        else
               #using current date in seconds if the optional date is  not given
               ref_seconds=$(date +%s)
        fi

        #calulating remaining seconds until expiry
        remaining_seconds=$(( expiry_seconds-ref_seconds ))

        #converting seconds to date
        #1 day is 86400 seconds

        days=$(( remaining_seconds / 86400 ))
        hours=$(( (remaining_seconds % 86400) / 3600 ))
        minutes=$(( (remaining_seconds % 3600) / 60 ))

        echo "certificate expires for $host in $days days $hours hours $minutes minutes"
}

if [ -f "$input" ]; then

#read and store in var host and process it for every single line

        while read -r host; do
                [ -n "$host" ] && process_host "$host"
        done < "$input"
        #input just feeds the file into read

#regex IP validation not nessesary
elif [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then

    echo "$input is an IPv4 address"
    process_host "$input"

#Hostname
else

        echo "$input  is  a Hostname"
        process_host "$input"
fi

exit 0

