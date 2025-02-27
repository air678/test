#!/bin/bash

echo "Logged-in Users Information:"
echo "-----------------------------"

# Get the user login information
who | awk '{print $1, $5}' | sort | uniq -c | while read count user ip; do
    if [[ "$ip" == "(:0)" || -z "$ip" ]]; then
        ip="Local Login"
    fi
    echo "User: $user | Sessions: $count | IP: $ip"
done
