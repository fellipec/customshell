#!/bin/bash

# Variables
USER="fellipec"  # Replace with your username
HOME_SSIDS=("Besixdouze" "B612")  # Replace with your home SSIDs
LOGFILE="/tmp/manage_screensaver.log"
SCRIPT_PATH="/usr/local/bin/manage_screensaver.sh"
DISPATCHER_PATH="/etc/NetworkManager/dispatcher.d/99-manage-screensaver"

# Important steps, don't skip!
# The NetworkManager will run this script as root. 
# So, your root user should be able to ssh into your desktop user to change the settings
# To this work, you must:
# - Have an SSH server installed, running and accepting connections on 127.0.0.1
# - Have the public key of the user root in your own user accepted keys.


# Create the script to manage screensaver based on Wi-Fi SSID
echo "Creating the screensaver management script..."
cat <<EOL | sudo tee $SCRIPT_PATH
#!/bin/bash

LOGFILE="$LOGFILE"
echo "\$(date) - Script executed" >> "\$LOGFILE"

# List of SSIDs considered "home"
HOME_SSIDS=(${HOME_SSIDS[@]})

# Get the current SSID
CURRENT_SSID=\$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
echo "Current SSID: \$CURRENT_SSID" >> "\$LOGFILE"

# Function to check if SSID is in the list
is_home_ssid() {
    for ssid in "\${HOME_SSIDS[@]}"; do
        if [[ "\$CURRENT_SSID" == "\$ssid" ]]; then
            echo "SSID \$CURRENT_SSID is home" >> "\$LOGFILE"
            return 0
        fi
    done
    echo "SSID \$CURRENT_SSID is NOT home" >> "\$LOGFILE"
    return 1
}

if is_home_ssid; then
    # Disable screensaver and lock screen at home
    ssh $USER@localhost gsettings set org.cinnamon.desktop.screensaver lock-enabled false
    ssh $USER@localhost gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled false
    echo "Screensaver disabled" >> "\$LOGFILE"
else
    # Enable screensaver and lock screen when away
    ssh $USER@localhost gsettings set org.cinnamon.desktop.screensaver lock-enabled true
    ssh $USER@localhost gsettings set org.cinnamon.desktop.screensaver idle-activation-enabled true
    echo "Screensaver enabled" >> "\$LOGFILE"
fi
EOL

# Step 4: Make the script executable
sudo chmod +x $SCRIPT_PATH

# Step 5: Set up the NetworkManager dispatcher to run the script when the network changes
echo "Setting up NetworkManager dispatcher..."
cat <<EOL | sudo tee $DISPATCHER_PATH
#!/bin/bash

case "\$2" in
    up|down)
        /usr/local/bin/manage_screensaver.sh
        ;;
esac
EOL

# Step 6: Make the dispatcher script executable
sudo chmod +x $DISPATCHER_PATH

# Step 7: Reboot the machine (or you can just restart NetworkManager)
echo "Installation complete. Reboot to apply changes..."
