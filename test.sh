#!/bin/bash

cat <<EOF
  _____                         _           _            
 |_   _|                       | |         | |           
   | |  _ __ ___  _ ____      _| |__   ___ | |_ ___ _ __ 
   | | | '_ \` _ \\| '_ \\ \\ /\\ / / '_ \\ / _ \\| __/ _ \\ '__|
  _| |_| | | | | | |_) \\ V  V /| | | | (_) | ||  __/ |   
 |_____|_| |_| |_| .__/ \\_/\\_/ |_| |_|\\___/ \\__\\___|_|   
                 | |                                     
                 |_|                                     
EOF

echo "Logged-in Users Information:"
echo "-----------------------------"

# Get the user login information
who | awk '{print $1, $5}' | sort | uniq -c | while read count user ip; do
    if [[ "$ip" == "(:0)" || -z "$ip" ]]; then
        ip="Local Login"
    fi
    echo "User: $user | Sessions: $count | IP: $ip"
done
