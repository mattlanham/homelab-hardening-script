# Basic Hardening Script

This script automates the basic security hardening process for Ubuntu servers in my homelab environment. It eliminates the need for manual configuration and ensures consistent security settings across multiple virtual machines.

Contributions and suggestions for additional security measures are welcome!

## What it does

* Updates the system package list and upgrades all installed packages
* Installs essential security packages (ufw, fail2ban)
* Configures and enables UFW (Uncomplicated Firewall)
  * Allows SSH (default port 22) connections
  * Denies all other incoming connections by default
* Sets up fail2ban for SSH protection
* Disables root login via SSH
* Enforces SSH key-based authentication (disables password authentication)
* Creates a new sudo user with SSH key access
* Removes unnecessary packages and cleans up package cache
* Enables automatic security updates

## Usage

Download and run the script using these commands:
```bash
wget https://raw.githubusercontent.com/mattlanham/homelab-hardening-script/refs/heads/main/kubernetes/ubuntu.sh
chmod +x ubuntu.sh
sudo ./ubuntu.sh
```