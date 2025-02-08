# Basic Hardening Script

This script automates the basic security hardening process for Ubuntu servers in my homelab environment, with specific optimizations for Kubernetes compatibility. It eliminates the need for manual configuration and ensures consistent security settings across multiple virtual machines.

Contributions and suggestions for additional security measures are welcome!

## What it does

* Updates the system package list and upgrades all installed packages
* Installs essential security packages (fail2ban, unattended-upgrades)
* Creates a new sudo user with SSH key access
* Hardens SSH configuration:
  * Changes SSH port to custom port
  * Disables root login via SSH
  * Enforces SSH key-based authentication (disables password authentication)
  * Limits SSH access to the new admin user only
* Disables UFW (Uncomplicated Firewall) for Kubernetes compatibility
* Sets up fail2ban for SSH protection with custom port
* Enables automatic security updates
* Disables unused services (avahi-daemon)
* Logs all hardening actions to `/var/log/harden-ubuntu.log`

## Usage

Download and run the script using these commands:
```bash
wget https://raw.githubusercontent.com/mattlanham/homelab-hardening-script/refs/heads/main/kubernetes/ubuntu.sh
chmod +x ubuntu.sh
sudo ./ubuntu.sh
```

When running the script, you'll be prompted to provide:
- New admin username
- Custom SSH port number
- Your SSH public key

The script will show a summary of your choices and ask for confirmation before proceeding with the hardening process.

After completion, you can log in to your server using:
```bash
ssh -p <your-custom-port> <new-username>@<your-server-ip>
```