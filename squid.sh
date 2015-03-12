#!/bin/bash -ex
echo "CAI DAT PROXY-SERVER TREN CENTOS 7 CORE"
echo "CAP NHAT HE THONG TRUOC KHI CAI DAT"
yum update -y
echo "CAI DAT GOI PHAN MEM "
yum -y install squid
sleep 3
echo "CAU HINH FILE CONFIG"
squid=/etc/squid/squid.conf
test -f $squid.bak || cp $squid $squid.bak
rm -rf $squid
touch $squid
cat << EOF >> $squid
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT
acl lan src 10.145.37.0/24
acl chan-website dstdomain "/etc/squid/chan.website"
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/.htpasswd
auth_param basic children 5
auth_param basic realm Squid Basic Authentication
auth_param basic credentialsttl 5 hours
acl password proxy_auth REQUIRED
http_access allow password
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
#http_access allow localnet
http_access allow localhost
http_access allow lan
#http_access deny chan-website
http_access deny all
http_port 8080
coredump_dir /var/spool/squid
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
request_header_access Referer deny all
request_header_access X-Forwarded-For deny all
request_header_access Via deny all
request_header_access Cache-Control deny all
visible_hostname 10.145.37.13
forwarded_for on
EOF
sleep 3
echo "CAU HINH Authentication CHO Squid"
htpasswd -c /etc/squid/.htpasswd home
echo "CONFIG FIREWALL OPENPORT 8080"
iptables -A IN_public_allow -p tcp -m tcp --dport 8080 -j ACCEPT
echo "HOAN THANH CONG VIEC"
