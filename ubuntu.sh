#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ This script must be run as root!" >&2
    exit 1
fi

echo "🚀 Welcome to the Ubuntu Server Hardening Script"
echo "----------------------------------------------"

# 1️⃣ Get User Inputs
read -p "Enter the new admin username: " NEW_USER
read -p "Enter the SSH port you want to use (e.g., 2222): " SSH_PORT
read -p "Paste your SSH public key (for secure login): " SSH_KEY

echo -e "\n🔍 Summary of your choices:"
echo "   - New Admin User: $NEW_USER"
echo "   - SSH Port: $SSH_PORT"
echo "   - SSH Key: $(echo $SSH_KEY | cut -c1-20)...(truncated for security)"
echo ""
read -p "⚠️ Are you sure you want to proceed? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "❌ Process aborted!"
    exit 1
fi

LOG_FILE="/var/log/harden-ubuntu.log"

echo "🚀 Starting Ubuntu Server Hardening Process..."
echo "-------------------------------------------------"

# 2️⃣ Update & Upgrade the System
echo "🔄 Updating and Upgrading System Packages..."
apt update && apt upgrade -y
apt install -y ufw fail2ban unattended-upgrades
echo "✅ System updated successfully!" | tee -a $LOG_FILE

# 3️⃣ Create a new sudo user
echo "👤 Creating a new sudo user: $NEW_USER..."
adduser --gecos "" $NEW_USER
usermod -aG sudo $NEW_USER
mkdir -p /home/$NEW_USER/.ssh
echo "$SSH_KEY" > /home/$NEW_USER/.ssh/authorized_keys
chmod 600 /home/$NEW_USER/.ssh/authorized_keys
chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh
echo "✅ User '$NEW_USER' created with SSH key authentication!" | tee -a $LOG_FILE

# 4️⃣ Secure SSH
echo "🔐 Hardening SSH Configuration..."
SSH_CONFIG="/etc/ssh/sshd_config"
cp $SSH_CONFIG "$SSH_CONFIG.bak"

# Modify SSH settings
sed -i "s/#Port 22/Port $SSH_PORT/" $SSH_CONFIG
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" $SSH_CONFIG
sed -i "s/#PubkeyAuthentication yes/PubkeyAuthentication yes/" $SSH_CONFIG
sed -i "s/PasswordAuthentication yes/PasswordAuthentication no/" $SSH_CONFIG
echo "AllowUsers $NEW_USER" >> $SSH_CONFIG
systemctl restart ssh

echo "✅ SSH secured! Root login disabled, port changed to $SSH_PORT, and access limited to $NEW_USER" | tee -a $LOG_FILE

# 5️⃣ Enable UFW Firewall
echo "🛡️ Configuring UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp
ufw enable
echo "✅ UFW Firewall configured and enabled!" | tee -a $LOG_FILE

# 6️⃣ Configure Fail2Ban
echo "🚔 Setting up Fail2Ban..."
cat <<EOF > /etc/fail2ban/jail.local
[sshd]
enabled = true
port = $SSH_PORT
maxretry = 3
bantime = 3600
EOF
systemctl restart fail2ban
echo "✅ Fail2Ban installed and configured!" | tee -a $LOG_FILE

# 7️⃣ Enable Automatic Security Updates
echo "🔄 Enabling Unattended Security Updates..."
dpkg-reconfigure --priority=low unattended-upgrades
echo "✅ Automatic security updates enabled!" | tee -a $LOG_FILE

# 8️⃣ Disable Unused Services
echo "🛑 Disabling Unused Services..."
systemctl stop avahi-daemon
systemctl disable avahi-daemon
echo "✅ Unused services disabled!" | tee -a $LOG_FILE

# Completion Message
echo "🎉 Ubuntu Server Hardening Completed!"
echo "📌 Don't forget to update your SSH client with the new port: $SSH_PORT"
echo "✅ You can now log in as: ssh -p $SSH_PORT $NEW_USER@<your-server-ip>"