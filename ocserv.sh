#!/usr/bin/env bash
ocserv_management() {
echo -e "
welcome to ocserv management
"
echo "please select your option"
echo "1: start ocserv"
echo "2: restart ocserv"
echo "3: stop ocserv"
echo "4: ocserv status"
echo "5: return to main menu"
read -r
user_selection=$REPLY
if [ $user_selection -eq "1" ]
then
  systemctl start ocserv
elif [ $user_selection -eq "2" ]
then
  systemctl restart ocserv
elif [ $user_selection -eq "3" ]
then
  systemctl stop ocserv
elif [ $user_selection -eq "4" ]
then
  systemctl status ocserv
elif [ $user_selection -eq "5" ]
then
  main
else
  echo "invalid option"
  echo ""
fi
}
user_management() {
echo -e "
welcome to ocserv user management
"
echo "please select your option"
echo "1: create a group1 user"
echo "2: create a group2 user"
echo "3: create a group3 user"
echo "4: create a group4 user"
echo "5: create a group5 user"
echo "6: create an unlimit user"
echo "7: change password for a user"
echo "8: lock a user"
echo "9: unlock an user"
echo "10: delete an user"
echo "11: show All users file"
echo "12: show All users with some information"
echo "13: show All users log"
echo "14: show All users count"
echo "15: show connectted users count"
echo "16: show users Connection Software type"
echo "17: disconnect the specified user"
echo "18: return to main menu"
read -r
user_selection=$REPLY
if [ $user_selection -eq "1" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd -g group1 $username
  echo "user created in group1"
elif [ $user_selection -eq "2" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd -g group2 $username
  echo "user created in group2"
elif [ $user_selection -eq "3" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd -g group3 $username
  echo "user created in group3"
elif [ $user_selection -eq "4" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd -g group4 $username
  echo "user created in group4"
elif [ $user_selection -eq "5" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd -g group5 $username
  echo "user created in group5"
elif [ $user_selection -eq "6" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd $username
  echo "unlimit user created"
elif [ $user_selection -eq "7" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -c /etc/ocserv/ocpasswd $username
  echo "password has been changed"
elif [ $user_selection -eq "8" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -l -c /etc/ocserv/ocpasswd $username
  echo "user locked"
elif [ $user_selection -eq "9" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  ocpasswd -u -c /etc/ocserv/ocpasswd $username
  echo "user unlocked"
elif [ $user_selection -eq "10" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  occtl disconnect user $username
  ocpasswd -d -c /etc/ocserv/ocpasswd $username
  echo "user deleted"
elif [ $user_selection -eq "11" ]
then
  clear
  echo ""
  echo ""
  echo "########################################################################"
  cat /etc/ocserv/ocpasswd
  echo "########################################################################"
  echo ""
  echo ""
elif [ $user_selection -eq "12" ]
then
  occtl show users wc -l
elif [ $user_selection -eq "13" ]
then
  occtl  show events
elif [ $user_selection -eq "14" ]
then
  wc -l /etc/ocserv/ocpasswd
elif [ $user_selection -eq "15" ]
then
  occtl show users | wc -l
  echo ""
elif [ $user_selection -eq "16" ]
then
  occtl show sessions all  > /etc/ocserv/temp_ocserv
  user_connection_info_file="/etc/ocserv/temp_ocserv"
  while read line; do echo "---" $line | awk '{print $3, $6 ,$7}'; done < $user_connection_info_file
  rm -rf /etc/ocserv/temp_ocserv
  echo ""
  elif [ $user_selection -eq "17" ]
then
  echo "please enter the username"
  read -r
  username=$REPLY
  occtl disconnect user $username
  echo ""
elif [ $user_selection -eq "18" ]
then
  main
else
  echo "invalid option"
  echo ""
fi
}
install_and_configure() {
echo "deb http://archive.ubuntu.com/ubuntu/packages jammy main restricted
deb http://archive.ubuntu.com/ubuntu/packages jammy-updates main restricted
deb http://archive.ubuntu.com/ubuntu/packages jammy universe
deb http://archive.ubuntu.com/ubuntu/packages jammy-updates universe
deb http://archive.ubuntu.com/ubuntu/packages jammy multiverse
deb http://archive.ubuntu.com/ubuntu/packages jammy-updates multiverse
deb http://archive.ubuntu.com/ubuntu/packages jammy-backports main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/security jammy-security main restricted
deb http://archive.ubuntu.com/ubuntu/security jammy-security universe
deb http://archive.ubuntu.com/ubuntu/security jammy-security multiverse
" > /etc/apt/sources.list
rm -rf /etc/resolv.conf
echo "nameserver 8.8.8.8
nameserver 8.8.4.4" > /etc/resolv.conf
apt-get update
sed -i -e 's@#net.ipv4.ip_forward=1@net.ipv4.ip_forward=1@g' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/60-custom.conf
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.d/60-custom.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.d/60-custom.conf
sysctl net.ipv4.tcp_available_congestion_control
sysctl net.ipv4.tcp_congestion_control
echo "net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sudo sysctl -p
sysctl net.ipv4.tcp_congestion_control
sudo sysctl -p /etc/sysctl.d/60-custom.conf
apt install iptables -y
apt install iptables-persistent -y
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables-save > /etc/iptables/rules.v4
ip=$(hostname -I|cut -f1 -d ' ')
echo "your server ip address is:$ip"
echo -e "\e[32mInstalling gnutls-bin\e[39m"
apt install gnutls-bin -y
mkdir certificates
cd certificates
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
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
cat << EOF > server.tmpl
#yourIP
cn=$ip
organization = "my company"
expiration_days = 3650
signing_key
encryption_key
tls_www_server
EOF
certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem
echo -e "\e[32mInstalling ocserv\e[39m"
apt install ocserv -y
apt-get install vim net-tools pkg-config build-essential libgnutls28-dev libwrap0-dev liblz4-dev libseccomp-dev libreadline-dev libnl-nf-3-dev libev-dev gnutls-bin -y
wget -N --no-check-certificate https://www.infradead.org/ocserv/download/ocserv-1.1.7.tar.xz
tar -xf ocserv-1.1.7.tar.xz
cd ocserv-1.1.7
./configure
make
make install
cd ..
rm -rf ocserv-1.1.7.tar.xz
rm -rf ocserv-1.1.7
cp /lib/systemd/system/ocserv.service /etc/systemd/system/ocserv.service
sed -i -e 's@ExecStart=/usr/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@ExecStart=/usr/local/sbin/ocserv --foreground --pid-file /run/ocserv.pid --config /etc/ocserv/ocserv.conf@g' /etc/systemd/system/ocserv.service
systemctl daemon-reload
cp /etc/ocserv/ocserv.conf ~/certificates/
sed -i -e 's@auth = "@#auth = "@g' /etc/ocserv/ocserv.conf
sed -i -e 's@auth = "pam@auth = "#auth = "pam"@g' /etc/ocserv/ocserv.conf
sed -i -e 's@try-mtu-discovery = false@try-mtu-discovery = true@g' /etc/ocserv/ocserv.conf
sed -i -e 's@dns = 1.1.1.1@dns = 8.8.4.4@g' /etc/ocserv/ocserv.conf
sed -i -e 's@route =@#route =@g' /etc/ocserv/ocserv.conf
sed -i -e 's@no-route =@#no-route =@g' /etc/ocserv/ocserv.conf
sed -i -e 's@cisco-client-compat@cisco-client-compat = true@g' /etc/ocserv/ocserv.conf
sed -i -e 's@##auth = "#auth = "pam""@auth = "plain[passwd=/etc/ocserv/ocpasswd]"@g' /etc/ocserv/ocserv.conf
sed -i -e 's@server-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem@server-cert = /etc/ocserv/server-cert.pem@g' /etc/ocserv/ocserv.conf
sed -i -e 's@server-key = /etc/ssl/private/ssl-cert-snakeoil.key@server-key = /etc/ocserv/server-key.pem@g' /etc/ocserv/ocserv.conf
sed -i -e 's@max-clients = 128@max-clients = 0@g' /etc/ocserv/ocserv.conf
sed -i -e 's@max-same-clients = 2@max-same-clients = 0@g' /etc/ocserv/ocserv.conf
sed -i -e 's@keepalive = 300@keepalive = 3000@g' /etc/ocserv/ocserv.conf
sed -i -e 's@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128"@tls-priorities = "NORMAL:%SERVER_PRECEDENCE:%COMPAT:-RSA:-VERS-SSL3.0:-ARCFOUR-128:-VERS-TLS1.0:-VERS-TLS1.1"@g' /etc/ocserv/ocserv.conf
sed -i -e 's@max-ban-score = 80@max-ban-score = 0@g' /etc/ocserv/ocserv.conf
sed -i -e 's@ipv4-network = 192.168.1.0@ipv4-network = 192.168.0.0@g' /etc/ocserv/ocserv.conf
sed -i -e 's@ipv4-netmask = 255.255.255.0@ipv4-netmask = 255.255.0.0@g' /etc/ocserv/ocserv.conf
sed -i -e 's@#tunnel-all-dns = true@tunnel-all-dns = true@g' /etc/ocserv/ocserv.conf
sed -i -e 's@#config-per-user = /etc/ocserv/config-per-user/@config-per-user = /etc/ocserv/config-per-user/@g' /etc/ocserv/ocserv.conf
sed -i -e 's@#config-per-group = /etc/ocserv/config-per-group/@#config-per-group = /etc/ocserv/config-per-group/@g' /etc/ocserv/ocserv.conf
mkdir /etc/ocserv/config-per-user/
mkdir /etc/ocserv/config-per-group/
touch /etc/ocserv/config-per-user/user1
touch /etc/ocserv/config-per-user/user2
touch /etc/ocserv/config-per-user/user3
touch /etc/ocserv/config-per-user/user4
touch /etc/ocserv/config-per-user/user5
touch /etc/ocserv/config-per-group/group1
touch /etc/ocserv/config-per-group/group2
touch /etc/ocserv/config-per-group/group3
touch /etc/ocserv/config-per-group/group4
touch /etc/ocserv/config-per-group/group5
echo "max-same-clients = 1" > /etc/ocserv/config-per-group/group1
echo "max-same-clients = 2" > /etc/ocserv/config-per-group/group2
echo "max-same-clients = 3" > /etc/ocserv/config-per-group/group3
echo "max-same-clients = 4" > /etc/ocserv/config-per-group/group4
echo "max-same-clients = 5" > /etc/ocserv/config-per-group/group5
echo "Enter a username:"
read username
ocpasswd -c /etc/ocserv/ocpasswd $username
cp ~/certificates/server-key.pem /etc/ocserv/
cp ~/certificates/server-cert.pem /etc/ocserv/
echo -e "\e[32mStopping ocserv service\e[39m"
service ocserv stop
echo -e "\e[32mStarting ocserv service\e[39m"
service ocserv start
echo "OpenConnect Server Configured Succesfully"
}
main() {
echo -e "
welcome to ocserv
"
echo "Please select your option"
echo "1: install and configure ocserv"
echo "2: uninstall ocserv"
echo "3: ocserv user management"
echo "4: ocserv management"
read -r
user_selection=$REPLY
if [ $user_selection -eq "1" ]
then
  install_and_configure
elif [ $user_selection -eq "2" ]
then
  apt-get purge ocserv -y
  rm -rf /etc/ocserv
  rm -rf /root/certificates
elif [ $user_selection -eq "3" ]
then
  user_management
elif [ $user_selection -eq "4" ]
then
  ocserv_management
else
  echo "invalid option"
  echo ""
fi
}
main
if [[ "$EUID" -ne 0 ]]; then
	echo "please run as root"
	exit 1
fi
		
	
