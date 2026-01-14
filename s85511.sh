#!/bin/bash 

if [ $# -gt 2 ] || [ $# -eq 0 ]; then 

	echo "usage : <Rechnername/IP-Adress> <Datum : TT.MM.JJJJ>"
	exit 1
fi
 
input="$1"
datum="$2"

process_host(){

        local host="$1"
        cert_output=$(echo -n | openssl s_client -connect "$host":443 2>/dev/null)
	expiry=$(echo "$cert_output" | grep "NotAfter:" | head -n 1 | sed 's/.*NotAfter: //')	

	#error handling in case there is no certificate present
	# -z checks if the string is empty 
 
	if [ -z "$expiry" ]; then
        	echo "Failed to retrieve certificate for $host"
        	return 1
   	fi


        expiry_seconds=$(date -d "$expiry" +%s)

        #optional second variable
        #-n checks if sting s not empty
        # linux dont understand TT.MM.YYYY so format to --> YYYY.MM.TT

        if [ -n "$datum" ]; then

        	datum_formatted=$(echo "$datum" | sed 's/\([0-9]\{2\}\)-\([0-9]\{2\}\)-\([0-9]\{4\}\)/\3-\2-\1/')
        	ref_seconds=$(date -d "$datum_formatted" +%s)

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
	process_host "$host"
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



	







