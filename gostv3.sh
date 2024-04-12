#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi

# Set the desired GitHub repository
repo="go-gost/gost"
base_url="https://github.com/$repo/releases/download"
version="3.0.0-nightly.20240201"

# Detect the operating system
if [[ "$(uname)" == "Linux" ]]; then
    os="linux"
elif [[ "$(uname)" == "Darwin" ]]; then
    os="darwin"
elif [[ "$(uname)" == "MINGW"* ]]; then
    os="windows"
else
    echo "Unsupported operating system."
    exit 1
fi

# Detect the CPU architecture
arch=$(uname -m)
case $arch in
x86_64)
    cpu_arch="amd64"
    ;;
armv5*)
    cpu_arch="armv5"
    ;;
armv6*)
    cpu_arch="armv6"
    ;;
armv7*)
    cpu_arch="armv7"
    ;;
aarch64)
    cpu_arch="arm64"
    ;;
i686)
    cpu_arch="386"
    ;;
mips64*)
    cpu_arch="mips64"
    ;;
mips*)
    cpu_arch="mips"
    ;;
mipsel*)
    cpu_arch="mipsle"
    ;;
*)
    echo "Unsupported CPU architecture."
    exit 1
    ;;
esac

${SUDO} apt-get update
${SUDO} apt-get -y install curl

download_url="$base_url/v$version/gost_${version}_${os}_${cpu_arch}.tar.gz"

echo "Downloading gost version $version..."
curl -L -o gost.tar.gz $download_url || { echo "Failed to download gost."; exit 1; }

# Extract and install the binary
echo "Installing gost..."
${SUDO} tar -xzf gost.tar.gz || { echo "Failed to extract gost."; exit 1; }
${SUDO} chmod +x gost
${SUDO} mv gost /usr/local/bin/gost
${SUDO} rm LICENSE README.md README_en.md gost.tar.gz

echo "gost binary installed!"

# Create a systemd service for gost
if [ -f /etc/systemd/system/gost.service ]; then
    ${SUDO} rm -f /etc/systemd/system/gost.service
fi

cat > /etc/systemd/system/gost.service <<EOF
[Unit]
Description=GO Simple Tunnel - Gost
After=network.target
Wants=network.target

[Service]
ExecStart=/usr/local/bin/gost
Restart=always
User=root
Group=root

[Install]
WantedBy=default.target
EOF

# Enable and start the service
${SUDO} chmod 644 /etc/systemd/system/gost.service
${SUDO} systemctl daemon-reload
${SUDO} systemctl enable gost

echo "gost service installed!"