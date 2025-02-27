#!/bin/bash

# Display ASCII Art
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

# Define log file & whitelist file
logfile="logins.log"
whitelist="whitelist.txt"

# Function to show a downloading animation
downloading_animation() {
    echo -n "📥 Installing jq "
    for i in {1..10}; do
        echo -n "⬇️"
        sleep 0.2
    done
    echo " ✅"
}

# Check if jq is installed
if ! command -v jq &>/dev/null; then
    echo "⚠️ jq is required for geolocation lookup but is not installed."
    read -p "Would you like to install it now? (Y/N): " choice
    if [[ "$choice" == "Y" || "$choice" == "y" ]]; then
        downloading_animation
        sudo apt install jq -y
        echo "✅ jq has been installed successfully!"
    else
        echo "❌ jq is not installed. Geolocation functionality will not work."
    fi
fi

# Function to get geolocation of an IP
get_location() {
    local ip=$1
    if [[ "$ip" == "Local Login" ]]; then
        echo "Local Machine"
    else
        location=$(curl -s "http://ip-api.com/json/$ip" | jq -r '.city, .country' | paste -sd ', ')
        echo "$location"
    fi
}

# Function to show logged-in users
show_logged_in_users() {
    echo "-----------------------------"
    echo "📋 Logged-in Users Information:"
    echo "-----------------------------"
    
    who | awk '{print $1, $2, $3, $4, $5}' | sort | uniq -c | while read count user tty login_time ip; do
        if [[ "$ip" == "(:0)" || -z "$ip" ]]; then
            ip="Local Login"
        fi
        
        location=$(get_location "$ip")

        echo "👤 User: $user | 🖥 Sessions: $count | 🌍 IP: $ip | 📌 TTY: $tty | ⏳ Login Time: $login_time | 📍 Location: $location"

        # Log this login attempt
        echo "$(date) | User: $user | Sessions: $count | IP: $ip | TTY: $tty | Login Time: $login_time | Location: $location" >> "$logfile"
    done

    # Show summary
    total_sessions=$(who | wc -l)
    unique_users=$(who | awk '{print $1}' | sort | uniq | wc -l)

    echo "-----------------------------"
    echo "📊 Total Active Sessions: $total_sessions"
    echo "👥 Unique Logged-in Users: $unique_users"
    echo "-----------------------------"
}

# Function to detect suspicious logins
detect_suspicious_logins() {
    echo "-----------------------------"
    echo "🔍 Checking for Suspicious Logins..."
    echo "-----------------------------"

    who | awk '{print $1, $5}' | sort | uniq -c | while read count user ip; do
        if [[ "$ip" == "(:0)" || -z "$ip" ]]; then
            ip="Local Login"
        fi

        if [[ "$ip" != "Local Login" && ! $(grep -Fxq "$ip" "$whitelist") ]]; then
            status="⚠ SUSPICIOUS LOGIN ⚠"
        else
            status="✅ Normal"
        fi

        echo "👤 User: $user | 🖥 Sessions: $count | 🌍 IP: $ip | 🔎 Status: $status"
    done
}

# Function to show login history from log file
show_login_history() {
    echo "-----------------------------"
    echo "📜 Login History (Last 10 Entries)"
    echo "-----------------------------"
    tail -10 "$logfile"
}

# Function to display system summary
show_summary() {
    total_sessions=$(who | wc -l)
    unique_users=$(who | awk '{print $1}' | sort | uniq | wc -l)

    echo "-----------------------------"
    echo "📊 System Summary"
    echo "-----------------------------"
    echo "📋 Total Active Sessions: $total_sessions"
    echo "👥 Unique Logged-in Users: $unique_users"
    echo "📜 Last 5 Login Attempts:"
    tail -5 "$logfile"
}

# Interactive menu
while true; do
    echo ""
    echo "=================================="
    echo "🔍 Linux User Monitoring Script 🔍"
    echo "=================================="
    echo "1️⃣ Show Logged-in Users"
    echo "2️⃣ Detect Suspicious Logins"
    echo "3️⃣ Show Login History"
    echo "4️⃣ Show System Summary"
    echo "5️⃣ Exit"
    echo "=================================="
    
    read -p "📌 Enter your choice: " choice

    case $choice in
        1) show_logged_in_users ;;
        2) detect_suspicious_logins ;;
        3) show_login_history ;;
        4) show_summary ;;
        5) echo "🚀 Exiting..."; exit ;;
        *) echo "❌ Invalid option, please try again." ;;
    esac
done
