#!/usr/bin/env bash

########################################
# Check if the script is run as root
########################################
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run this script as root (sudo)."
exit 1
fi

########################################
# Functions
########################################

ocserv_management() {
  echo -e "\nWelcome to Ocserv Management\n"
  echo "Please select your option:"
  echo "1) Start ocserv"
  echo "2) Restart ocserv"
  echo "3) Stop ocserv"
  echo "4) Ocserv status"
  echo "5) Return to main menu"
  echo "6) Exit"
  read -r user_selection

  case "$user_selection" in
    1) systemctl start ocserv ;;
    2) systemctl restart ocserv ;;
    3) systemctl stop ocserv ;;
    4) systemctl status ocserv ;;
    5) main ;;
    6) exit 0 ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

user_management() {
  echo -e "\nWelcome to Ocserv User Management\n"
  echo "Please select your option:"
  echo "1)  Create a group1 user"
  echo "2)  Create a group2 user"
  echo "3)  Create a group3 user"
  echo "4)  Create a group4 user"
  echo "5)  Create a group5 user"
  echo "6)  Create an unlimit user"
  echo "7)  Change password for a user"
  echo "8)  Lock a user"
  echo "9)  Unlock a user"
  echo "10) Delete a user"
  echo "11) Show All users file"
  echo "12) Show All users with some information"
  echo "13) Show All users log"
  echo "14) Show All users count"
  echo "15) Show connected users count"
  echo "16) Show users connection software type"
  echo "17) Disconnect a specified user"
  echo "18) Return to main menu"
  echo "19) Exit"
  read -r user_selection

  case "$user_selection" in
    1)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd -g group1 "$username"
      echo "User '$username' created in group1."
      ;;
    2)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd -g group2 "$username"
      echo "User '$username' created in group2."
      ;;
    3)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd -g group3 "$username"
      echo "User '$username' created in group3."
      ;;
    4)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd -g group4 "$username"
      echo "User '$username' created in group4."
      ;;
    5)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd -g group5 "$username"
      echo "User '$username' created in group5."
      ;;
    6)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd "$username"
      echo "Unlimited user '$username' created."
      ;;
    7)
      echo "Please enter the username:"
      read -r username
      ocpasswd -c /etc/ocserv/ocpasswd "$username"
      echo "Password changed for user '$username'."
      ;;
    8)
      echo "Please enter the username:"
      read -r username
      ocpasswd -l -c /etc/ocserv/ocpasswd "$username"
      echo "User '$username' locked."
      ;;
    9)
      echo "Please enter the username:"
      read -r username
      ocpasswd -u -c /etc/ocserv/ocpasswd "$username"
      echo "User '$username' unlocked."
      ;;
    10)
      echo "Please enter the username:"
      read -r username
      occtl disconnect user "$username"
      ocpasswd -d -c /etc/ocserv/ocpasswd "$username"
      echo "User '$username' deleted."
      ;;
    11)
      clear
      echo "########################################################################"
      cat /etc/ocserv/ocpasswd
      echo "########################################################################"
      echo ""
      ;;
    12)
      # If you want to show more information, modify the command below accordingly
      occtl show users wc -l
      ;;
    13)
      occtl show events
      ;;
    14)
      wc -l /etc/ocserv/ocpasswd
      ;;
    15)
      occtl show users | wc -l
      echo ""
      ;;
    16)
      occtl show sessions all  > /etc/ocserv/temp_ocserv
      user_connection_info_file="/etc/ocserv/temp_ocserv"
      while read -r line; do
        echo "---" "$line" | awk '{print $3, $6 ,$7}'
      done < "$user_connection_info_file"
      rm -rf /etc/ocserv/temp_ocserv
      echo ""
      ;;
    17)
      echo "Please enter the username:"
      read -r username
      occtl disconnect user "$username"
      echo ""
      ;;
    18)
      main
      ;;
    19)
      exit 0
      ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

install_and_configure_ocserv_with_lets_encrypt() {
  # Change DNS
  rm -rf /etc/resolv.conf
  cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

  apt-get update

  # Enabling ipv4_forward
  sed -i -e 's@#net.ipv4.ip_forward=1@net.ipv4.ip_forward=1@g' /etc/sysctl.conf
  sysctl -p /etc/sysctl.conf
  echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/60-custom.conf
  echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
  echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
  sysctl net.ipv4.tcp_available_congestion_control
  sysctl net.ipv4.tcp_congestion_control
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
  sudo sysctl -p
  sysctl net.ipv4.tcp_congestion_control
  sudo sysctl -p /etc/sysctl.d/60-custom.conf

  apt install iptables -y
  apt install iptables-persistent -y
  iptables -t nat -A POSTROUTING -j MASQUERADE
  iptables-save > /etc/iptables/rules.v4

  ip=$(hostname -I | cut -f1 -d ' ')
  echo "Your server IP address is: $ip"

  echo -e "\e[32mInstalling gnutls-bin\e[39m"
  apt install gnutls-bin -y

  echo -e "\e[32mInstalling ocserv\e[39m"
  apt install ocserv -y

  apt-get install -y vim net-tools pkg-config build-essential libgnutls28-dev \
                     libwrap0-dev liblz4-dev libseccomp-dev libreadline-dev \
                     libnl-nf-3-dev libev-dev gnutls-bin

  wget -N --no-check-certificate \
    https://www.infradead.org/ocserv/download/ocserv-1.2.4.tar.xz
  tar -xf ocserv-1.2.4.tar.xz
  cd ocserv-1.2.4 || exit 1
  ./configure
  make
  make install
  cd ..
  rm -rf ocserv-1.2.4.tar.xz ocserv-1.2.4

  cp /lib/systemd/system/ocserv.service /etc/systemd/system/ocserv.service
  sed -i -e 's@ExecStart=/usr/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@ExecStart=/usr/local/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@g' /etc/systemd/system/ocserv.service
  systemctl daemon-reload

  # Adjust ocserv configuration
  sed -i -e 's@auth = "@#auth = "@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@auth = "pam@auth = "#auth = "pam"@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@try-mtu-discovery = false@try-mtu-discovery = true@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@dns = 1.1.1.1@dns = 8.8.4.4@g' /etc/ocserv/ocserv.conf

  sed -i -e 's@##auth = "#auth = "pam""@auth = "plain[passwd=/etc/ocserv/ocpasswd]"@g' /etc/ocserv/ocserv.conf

  # Change the certificate/key paths to the user's domain
  sed -i "s@^server-cert = .*@server-cert = /etc/letsencrypt/live/$your_domain/fullchain.pem@g" /etc/ocserv/ocserv.conf
  sed -i "s@^server-key = .*@server-key = /etc/letsencrypt/live/$your_domain/privkey.pem@g" /etc/ocserv/ocserv.conf
  sed -i "s@^ca-cert = .*@ca-cert = /etc/letsencrypt/live/$your_domain/chain.pem@g" /etc/ocserv/ocserv.conf

  sed -i -e 's@max-clients = 128@max-clients = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@max-same-clients = 2@max-same-clients = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128"@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128:-VERS-TLS1.0:-VERS-TLS1.1"@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@max-ban-score = 80@max-ban-score = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@ipv4-network = 192.168.1.0@ipv4-network = 192.168.0.0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@ipv4-netmask = 255.255.255.0@ipv4-netmask = 255.255.0.0@g' /etc/ocserv/ocserv.conf

  # Enable tunnel-all-dns
  sed -i -e 's@#tunnel-all-dns = true@tunnel-all-dns = true@g' /etc/ocserv/ocserv.conf

  # Enable config-per-user/group
  sed -i -e 's@#config-per-user = /etc/ocserv/config-per-user/@config-per-user = /etc/ocserv/config-per-user/@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@#config-per-group = /etc/ocserv/config-per-group/@config-per-group = /etc/ocserv/config-per-group/@g' /etc/ocserv/ocserv.conf

  # Finally, apply route = default
  sed -i 's@^#route = default@route = default@g' /etc/ocserv/ocserv.conf

  mkdir -p /etc/ocserv/config-per-user/
  mkdir -p /etc/ocserv/config-per-group/
  touch /etc/ocserv/config-per-user/user{1,2,3,4,5}
  touch /etc/ocserv/config-per-group/group{1,2,3,4,5}

  echo "max-same-clients = 1" > /etc/ocserv/config-per-group/group1
  echo "max-same-clients = 2" > /etc/ocserv/config-per-group/group2
  echo "max-same-clients = 3" > /etc/ocserv/config-per-group/group3
  echo "max-same-clients = 4" > /etc/ocserv/config-per-group/group4
  echo "max-same-clients = 5" > /etc/ocserv/config-per-group/group5

  echo "Enter a username:"
  read -r username
  ocpasswd -c /etc/ocserv/ocpasswd "$username"

  echo -e "\e[32mStopping ocserv service\e[39m"
  service ocserv stop
  echo -e "\e[32mStarting ocserv service\e[39m"
  service ocserv start

  echo "OpenConnect Server configured successfully (with Let's Encrypt)."
}

webroot_plugin() {
  echo "Please choose your webroot plugin:"
  echo "1) Apache"
  echo "2) Nginx"
  echo "3) Return to previous menu"
  echo "4) Exit"
  read -r user_selection

  case "$user_selection" in
    1)
      echo "Enter your email:"
      read -r your_email
      echo "Enter your domain:"
      read -r your_domain
      echo -e "\e[32mInstalling certbot and apache2\e[39m"
      apt install certbot -y
      apt install apache2 -y

      cat << EOF > /etc/apache2/sites-available/$your_domain.conf
<VirtualHost *:80>
    ServerName $your_domain
    DocumentRoot /var/www/ocserv
</VirtualHost>
EOF

      mkdir -p /var/www/ocserv
      chown www-data:www-data /var/www/ocserv -R
      a2ensite "$your_domain"
      systemctl reload apache2

      certbot certonly --webroot --agree-tos --email "$your_email" \
          -d "$your_domain" -w /var/www/ocserv

      install_and_configure_ocserv_with_lets_encrypt
      ;;
    2)
      echo "Enter your email:"
      read -r your_email
      echo "Enter your domain:"
      read -r your_domain
      echo -e "\e[32mInstalling certbot and nginx\e[39m"
      apt install certbot -y
      apt install nginx -y

      cat << EOF > /etc/nginx/conf.d/$your_domain.conf
server {
    listen 80;
    server_name $your_domain;

    root /var/www/ocserv/;

    location ~ /.well-known/acme-challenge {
        allow all;
    }
}
EOF

      mkdir -p /var/www/ocserv
      chown www-data:www-data /var/www/ocserv -R
      systemctl reload nginx

      certbot certonly --webroot --agree-tos --email "$your_email" \
          -d "$your_domain" -w /var/www/ocserv

      install_and_configure_ocserv_with_lets_encrypt
      ;;
    3)
      obtain_a_trusted_tls_certificate_from_lets_encrypt
      ;;
    4)
      exit 0
      ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

standalone_plugin() {
  echo "Enter your email:"
  read -r your_email
  echo "Enter your domain:"
  read -r your_domain
  echo -e "\e[32mInstalling certbot\e[39m"
  apt install certbot -y

  certbot certonly --standalone --preferred-challenges http --agree-tos \
      --email "$your_email" -d "$your_domain"

  install_and_configure_ocserv_with_lets_encrypt
}

obtain_a_trusted_tls_certificate_from_lets_encrypt() {
  echo "Please choose your certificate action:"
  echo "1) Standalone plugin"
  echo "2) Webroot plugin"
  echo "3) Renew"
  echo "4) Return to previous menu"
  echo "5) Exit"
  read -r user_selection

  case "$user_selection" in
    1)
      standalone_plugin
      ;;
    2)
      webroot_plugin
      ;;
    3)
      certbot renew
      ;;
    4)
      install_and_configure
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

install_and_configure_ocserv_without_lets_encrypt() {
  # Change DNS
  rm -rf /etc/resolv.conf
  cat << EOF > /etc/resolv.conf
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

  apt-get update
  # Enabling ipv4_forward
  sed -i -e 's@#net.ipv4.ip_forward=1@net.ipv4.ip_forward=1@g' /etc/sysctl.conf
  sysctl -p /etc/sysctl.conf
  echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/60-custom.conf
  echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
  echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
  sysctl net.ipv4.tcp_available_congestion_control
  sysctl net.ipv4.tcp_congestion_control
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
  sudo sysctl -p
  sysctl net.ipv4.tcp_congestion_control
  sudo sysctl -p /etc/sysctl.d/60-custom.conf

  apt install iptables -y
  apt install iptables-persistent -y
  iptables -t nat -A POSTROUTING -j MASQUERADE
  iptables-save > /etc/iptables/rules.v4

  ip=$(hostname -I | cut -f1 -d ' ')
  echo "Your server IP address is: $ip"

  echo -e "\e[32mInstalling gnutls-bin\e[39m"
  apt install gnutls-bin -y

  echo -e "\e[32mInstalling ocserv\e[39m"
  apt install ocserv -y

  apt-get install -y vim net-tools pkg-config build-essential libgnutls28-dev \
                     libwrap0-dev liblz4-dev libseccomp-dev libreadline-dev \
                     libnl-nf-3-dev libev-dev gnutls-bin

  wget -N --no-check-certificate \
    https://www.infradead.org/ocserv/download/ocserv-1.2.4.tar.xz
  tar -xf ocserv-1.2.4.tar.xz
  cd ocserv-1.2.4 || exit 1
  ./configure
  make
  make install
  cd ..
  rm -rf ocserv-1.2.4.tar.xz ocserv-1.2.4

  cp /lib/systemd/system/ocserv.service /etc/systemd/system/ocserv.service
  sed -i -e 's@ExecStart=/usr/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@ExecStart=/usr/local/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@g' /etc/systemd/system/ocserv.service
  systemctl daemon-reload

  cp /etc/ocserv/ocserv.conf ~/certificates/ 2>/dev/null || true
  sed -i -e 's@auth = "@#auth = "@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@auth = "pam@auth = "#auth = "pam"@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@try-mtu-discovery = false@try-mtu-discovery = true@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@dns = 1.1.1.1@dns = 8.8.4.4@g' /etc/ocserv/ocserv.conf

  sed -i -e 's@##auth = "#auth = "pam""@auth = "plain[passwd=/etc/ocserv/ocpasswd]"@g' /etc/ocserv/ocserv.conf

  sed -i -e 's@server-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem@server-cert = /etc/ocserv/server-cert.pem@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@server-key = /etc/ssl/private/ssl-cert-snakeoil.key@server-key = /etc/ocserv/server-key.pem@g' /etc/ocserv/ocserv.conf

  sed -i -e 's@max-clients = 128@max-clients = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@max-same-clients = 2@max-same-clients = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128"@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128:-VERS-TLS1.0:-VERS-TLS1.1"@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@max-ban-score = 80@max-ban-score = 0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@ipv4-network = 192.168.1.0@ipv4-network = 192.168.0.0@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@ipv4-netmask = 255.255.255.0@ipv4-netmask = 255.255.0.0@g' /etc/ocserv/ocserv.conf

  # Enable tunnel-all-dns
  sed -i -e 's@#tunnel-all-dns = true@tunnel-all-dns = true@g' /etc/ocserv/ocserv.conf

  # Enable config-per-user/group
  sed -i -e 's@#config-per-user = /etc/ocserv/config-per-user/@config-per-user = /etc/ocserv/config-per-user/@g' /etc/ocserv/ocserv.conf
  sed -i -e 's@#config-per-group = /etc/ocserv/config-per-group/@config-per-group = /etc/ocserv/config-per-group/@g' /etc/ocserv/ocserv.conf

  # Finally, apply route = default
  sed -i 's@^#route = default@route = default@g' /etc/ocserv/ocserv.conf

  mkdir -p /etc/ocserv/config-per-user/
  mkdir -p /etc/ocserv/config-per-group/
  touch /etc/ocserv/config-per-user/user{1,2,3,4,5}
  touch /etc/ocserv/config-per-group/group{1,2,3,4,5}

  echo "max-same-clients = 1" > /etc/ocserv/config-per-group/group1
  echo "max-same-clients = 2" > /etc/ocserv/config-per-group/group2
  echo "max-same-clients = 3" > /etc/ocserv/config-per-group/group3
  echo "max-same-clients = 4" > /etc/ocserv/config-per-group/group4
  echo "max-same-clients = 5" > /etc/ocserv/config-per-group/group5

  # Simple example for creating a self-signed certificate
  mkdir -p ~/certificates
  cd ~/certificates || exit 1
  cat << EOF > ca.tmpl
cn = "VPN CA"
organization = "Big Corp"
serial = 1
expiration_days = 3650
ca
signing_key
cert_signing_key
crl_signing_key
EOF
  certtool --generate-privkey --outfile ca-key.pem
  certtool --generate-self-signed --load-privkey ca-key.pem \
           --template ca.tmpl --outfile ca-cert.pem

  cat << EOF > server.tmpl
cn = $ip
organization = "my company"
expiration_days = 3650
signing_key
encryption_key
tls_www_server
EOF

  certtool --generate-privkey --outfile server-key.pem
  certtool --generate-certificate --load-privkey server-key.pem \
           --load-ca-certificate ca-cert.pem \
           --load-ca-privkey ca-key.pem --template server.tmpl \
           --outfile server-cert.pem

  cp server-key.pem /etc/ocserv/
  cp server-cert.pem /etc/ocserv/

  echo "Enter a username:"
  read -r username
  ocpasswd -c /etc/ocserv/ocpasswd "$username"

  echo -e "\e[32mStopping ocserv service\e[39m"
  service ocserv stop
  echo -e "\e[32mStarting ocserv service\e[39m"
  service ocserv start

  echo "OpenConnect Server configured successfully (without Let's Encrypt)."
}

install_and_configure() {
  echo -e "\nWelcome to Ocserv installation and configuration\n"
  echo "Please select your installation and configuration mode:"
  echo "1) Install and configure ocserv without Let's Encrypt"
  echo "2) Install and configure ocserv with Let's Encrypt"
  echo "3) Return to main menu"
  echo "4) Exit"
  read -r user_selection

  case "$user_selection" in
    1)
      install_and_configure_ocserv_without_lets_encrypt
      ;;
    2)
      obtain_a_trusted_tls_certificate_from_lets_encrypt
      ;;
    3)
      main
      ;;
    4)
      exit 0
      ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

main() {
  echo -e "\nWelcome to Ocserv\n"
  echo "Please select your option:"
  echo "1) Install and configure ocserv"
  echo "2) Uninstall ocserv"
  echo "3) Ocserv user management"
  echo "4) Ocserv management"
  echo "5) Exit"
  read -r user_selection

  case "$user_selection" in
    1)
      install_and_configure
      ;;
    2)
      apt-get purge ocserv -y
      rm -rf /etc/ocserv
      rm -rf /root/certificates
      echo "Ocserv uninstalled successfully."
      ;;
    3)
      user_management
      ;;
    4)
      ocserv_management
      ;;
    5)
      exit 0
      ;;
    *)
      echo "Invalid option"
      echo ""
      ;;
  esac
}

########################################
# Script entry point
########################################
main
