#!/bin/bash
# Input hosts on /etc/bacula/bacula.d/clients.conf
# The format of the input file must be:
# 192.168.33.101 somehost.example.com
USER=root
HOST=host1

while read ip hostname;do

ssh "$USER"@"$HOST" /bin/bash << EOF
echo "" >> /tmp/teste

echo "Client {
  Name = $hostname
  Password = f13IGu4inGdgpfQL7VvoEsThGwutb1iKBgBdSMbWNHEBx
  Address = $ip
  FDPort = 9102
  Catalog = MyCatalog
  File Retention = 30 days
  Job Retention = 6 months
}"  >> /tmp/teste

sudo cat /tmp/teste >> /etc/bacula/bacula.d/clients.conf
rm -rf /tmp/teste
EOF

done < "$1"
