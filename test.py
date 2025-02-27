import subprocess

def get_logged_in_users():
    users = {}

    # Run 'who' command and get output
    output = subprocess.check_output("who", shell=True, text=True).strip().split("\n")

    for line in output:
        parts = line.split()
        if len(parts) < 5:
            continue  # Ignore malformed lines

        username = parts[0]
        ip_address = parts[4] if "(" in parts[4] else "Local"

        if username in users:
            users[username].append(ip_address)
        else:
            users[username] = [ip_address]

    # Display the results
    print("Logged-in Users Information:")
    print("-----------------------------")
    for user, ips in users.items():
        unique_ips = set(ips)  # Remove duplicate IPs
        print(f"User: {user} | Sessions: {len(ips)} | IPs: {', '.join(unique_ips)}")

if __name__ == "__main__":
    get_logged_in_users()
