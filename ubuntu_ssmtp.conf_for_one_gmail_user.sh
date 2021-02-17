#!/bin/bash

set -eu

umask 077  # Ensure others can't read the file

read -p "Please paste your Gmail proxy email address: " \
     gmail_proxy_email_address
read -sp "Please paste your Gmail proxy email password:" \
     gmail_proxy_email_password && echo

cat <<-EOF > /etc/ssmtp/ssmtp.conf
    root=${gmail_proxy_email_address}
    AuthUser=${gmail_proxy_email_address}
    AuthPass=${gmail_proxy_email_password}
    hostname=${HOSTNAME:-$(hostname)}
    mailhub=smtp.gmail.com:587
    rewriteDomain=gmail.com
    FromLineOverride=YES
    UseTLS=YES
    UseSTARTTLS=YES
EOF
