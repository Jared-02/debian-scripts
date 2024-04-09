#!/bin/sh
# To add this repository please do:

if [ "$(whoami)" != "root" ]; then
    SUDO=sudo
fi
if [ -f /etc/apt/sources.list.d/nginx.list ]; then
    ${SUDO} rm /etc/apt/sources.list.d/nginx.list
fi
if [ -f /etc/apt/preferences.d/99nginx ]; then
    ${SUDO} rm /etc/apt/preferences.d/99nginx
fi

${SUDO} apt-get update
${SUDO} apt-get -y install curl gnupg2 ca-certificates lsb-release debian-archive-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | ${SUDO} tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | ${SUDO} tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | ${SUDO} tee /etc/apt/preferences.d/99nginx
${SUDO} apt-get update