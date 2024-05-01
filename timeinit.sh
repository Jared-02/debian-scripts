#!/bin/bash

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Check sudo status
if ! command -v sudo &> /dev/null
then
    echo -e "${RED}sudo is not installed.${NC} Please run 'apt install -y sudo' first."
    exit 1
fi

function display_help() {
    echo "Usage: timeinit.sh [-h|--help] [-t|--timezone <str>] [-r|--region <str>]"
    echo "    -t, --timezone   Set timezone (required, e.g. 'Asia/Shanghai')"
    echo "    -r, --region     Set NTP server region (optional, e.g. 'cn', 'hk')"
}

# Parse command line arguments
region=""
while [[ $# -gt 0 ]]
do
    key="$1"
    case $key in
        -t|--timezone)
        timezone="$2"
        shift
        shift
        ;;
        -r|--region)
        region="$2"
        shift
        shift
        ;;
        -h|--help)
        display_help
        exit 0
        ;;
        *)
        shift
        break
        ;;
    esac
done

# Check if timezone is provided
if [[ -z $timezone ]]; then
  display_help
  exit 1
fi

# Set NTP server region
if [[ -n $region ]]; then
  region="${region}."
fi
ntp_server="NTP=${region}pool.ntp.org"
fallback_ntp_server="FallbackNTP=0.${region}pool.ntp.org 1.${region}pool.ntp.org 2.${region}pool.ntp.org 3.${region}pool.ntp.org"

# Set system timezone
sudo timedatectl set-timezone "$timezone"

# Uninstall ntp and chrony packages if installed
# Reference: https://stackoverflow.com/questions/1298066
if dpkg-query -W -f='${Status}' chrony | grep "ok installed" > /dev/null 2>&1; then
    echo "Removing chrony packages..."
    sudo apt-get purge -y 'chrony*'
fi

if dpkg-query -W -f='${Status}' ntp | grep "ok installed"; then
    echo "Removing ntp packages..."
    sudo apt-get purge -y 'ntp*'
fi

# Install systemd-timesyncd if not installed
if ! dpkg-query -W -f='${Status}' systemd-timesyncd | grep "ok installed"; then
    sudo apt-get install -y systemd-timesyncd
fi

# Generate and write systemd-timesyncd config
sudo tee /etc/systemd/timesyncd.conf > /dev/null <<EOF
[Time]
$ntp_server
$fallback_ntp_server
EOF

# Restart systemd-timesyncd
sudo systemctl restart systemd-timesyncd
echo -e "${GREEN}Success!${NC}"
sudo systemctl status systemd-timesyncd