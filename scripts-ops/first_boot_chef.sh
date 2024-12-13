#!/bin/bash
export HOME=/root
IP="$(hostname -I)"
FQDN="$(hostname -f)"
HOSTNAME="$(hostname | awk -F. '{ print $1 }')"
DOMAIN="$(hostname -f | awk -F. '{ print $2,$3,$4 }' | sed -e 's/ /\./g')"
CHEF_VERSION="chef-13.10.0-1.el7.x86_64.rpm"

#hostname
if [ -f "/etc/hostname" ]; then
  echo "$FQDN" > /etc/hostname && hostnamectl set-hostname "$FQDN"
fi

echo "NETWORKING=yes
NOZEROCONF=yes
NETWORKING_IPV6=no
IPV6INIT=no
HOSTNAME=${FQDN}" > /etc/sysconfig/network

#/etc/hosts
echo "127.0.0.1 ${FQDN} ${HOSTNAME} localhost.localdomain localhost" > /etc/hosts
echo "${IP} ${FQDN} ${HOSTNAME}" >> /etc/hosts

#Install Chef
yum clean all
yum makecache fast
if [ "${DOMAIN}" == "qa.tabajara.intranet" ];then
	wget -q http://repo.qa.tabajara.intranet/pacotes/base/chef/"${CHEF_VERSION}"
	cat <<EOF > /root/qa-tabajara-validator.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEA5ZE3qCD+xURI3RODcIUWXKvknhOr8VOhWIBcwfXBmV78QLOr
7FUzakPgtec4b0yKDXXoCeUYJspaCrNd4rUVGjTIjSr7Wb1s8nzfZuP9oYCmQO4B
05uLk4NBC0+AzgxWHYBEV9MbPnvWzcFwdjKWq1L8+OR9Dg5U0g3BMxNdXid2z+f6
1eWnreabcpkxsePxX+Cww324Z8HB1p/kwUYOaoHJDbQr06Q2RXaOSLOjgu+y8yWs
vmQu37WMUdCHgaKlIz+w9ZEnrPMBEbO5HAybdTJuA0/cBCjOiUetJRq7s5kFICdk
edm6L1VYQ/VT8uzikCiyfARongjeRjEBl/ywYwIDAQABAoIBAHuDt3tZTVpb1AxG
nHik0pRH0/iNQvzT70KLxdyB2oknhvdU9FJywPgSz0tvvXh8qOZ3IsJ4JZdxViLd
wMziexkffywdDSGKfpy1PQnB70u+yTS0Gf19egqDGzL3sqiqEIdM5PiP19+1h6wq
wNSHgXNqcjuDzBkM8uwVhHZzm8+0zRN2adhdGAQuozRqWG3jMdMQkH2r+kcCmB0C
qXkTrrHNJbgDQsXOzEn7iAt3yxIn27O1YirLktmQkzLCP7wQxyz1m/N6nt8PhEgG
JBHdtmNqUPD+Vtaqa+nYU4BmX/wSQOnkSZcexWO80ebb36MxsOv6cZiKVi7RrVEu
2dngPzECgYEA+BFKBmv1/WVuyLwxYiEt0YvaQMqeU0KYjJWWO6/iuMDt24+HJLY0
hhmiRGhzNyA7SsZdN1gqXVUGVi6fSXmSyOM3wsJ3VAG00XK1qUY/dNZ8WBkP2i59
TB8o8Ej3rxDozdggvB9xNysMFHSJ8KSN0POVksmEi8ivDOTHpjg+7hsCgYEA7Oh7
k2Iyg4p61U+vWnjSLfvO0/FRlUIbrJllNRTsLsm/qpMv2KZJL9mHkCsxKniYNaXA
P46JO4nytBk8Ri6upS8O7g3D213y1nZpk6Dn0MZrTbMi35iED5Qw3SIccJjiqrO8
bwROvAx7O1jkWHk35kOBLC11MTWt8o2aU4yuS1kCgYBIUbIFAUBrqUCM4OB8vTOA
XYc5UFir6URT5+Aucm5kckplsggyGbRiS+LUkqbUMV9Xw1C1q8xd/UWlpl3lq72x
NxyweMUVBpJSZWC0grhJNaZ2gIfwkZERuhvTQVKEBSf5qsKQVZJKBRC2fesg7rgx
bHH0oy8zGUR/O8tAmDEwdQKBgQDi5RoNovu8LfHMwJ+yJ4stDUEejb3UFNeKa/OZ
bitx+DmANa2aclAf6tfCBQv2oD8vCktg07OteUYgpRasJOORQsuqxTYyr/z217vv
7yh2NMLqTMn2mgzJGuXdtGDGmjZkxPWQ4fBCfDW+NjmkXpxiBX7+f58A/WdWqbYH
lPINKQKBgDcgmU0Mh2x/mr1QCTaBMd6QILoanrMBCXsJ5wW6otqKSiEtxkdwxHkB
D6im+sgwmUDctA3tbJhvrnHzBOUO7yaFWH1qBRF0xarw5SYDctTPOhqHyWAZSB4a
lRvGvLS+5aWKeOO327RpBCOsOqXj0Fgrk4IF18anFULQxbxXHRz4
-----END RSA PRIVATE KEY-----
EOF

else
	wget -q http://repo.tabajara.intranet/pacotes/base/chef/"${CHEF_VERSION}"
	cat <<EOF > /root/prod-tabajara-validator.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAuk47AsFlfSTWXyWTKyALzD5l2aKXhY2CaWrPlK3TPF+IM5h+
L7nLl2RT38uNGmy9dvsTdGDT/xevfIOcXOvn9XOb2ttQQOU+wxB5qooWObL0cfEQ
LiwdaK3sApK+dR2aYlNPden/Fy5ijkXQmnOUB0c7zWmifYIOzmRPhLL45+XrA4BD
UuQzJN6ZfeXJIbesAMXFQ/u5jhKKa1qqbPhA+fxMBxfMsWuICWWFNgg/tjbjStgF
i1caPkMAqDIqrVxJ0AlaUjMWVNXH5ulH73jiGcnXyIROsi+r9XXG8Cg54BPGgFd8
XHGWPJMwh3tA6biGlycS67akaajlGNLtDvFIPQIDAQABAoIBAQCtfNPuyPEdDASk
LXVSH1FdLG3jsEixEQlz6QbMSOH/wmYuxb4b60PvAnooWIBZLxFvjnabVN+VGBVO
ObCNxxAFvVZRAxFEnTVIqDrj2BrCOCbxQ63xkRsBs5OnAcdhf+OX1ESWZQQqLgOQ
wOp0KVSbQnYp3kh133qyLy7tP0wRhKwPVa5cQl/0k/mZ0jOdtnwSiBL4AzSt09nT
Xq0iIhE+hsbpa2jW7S7PEMnf3EFyfxoWYRgf8Wi3xeVdoHnxrK7YpEcAOJ3JZ5uQ
srmsE5pmZFIla2mlh5XXtVv5oazJBMk5P84qBA1uBjA36CelL99DZEnzKylhPoRu
F7HR5RYBAoGBAPESdTcP+5Ftyf0cmh7m2YioMjQds+Df9zTv9Mpar5LPO674CDLu
GO9TEegc72I7hsgzYkJGcQXJBREnukjaU8L9GNVKfy35aIRhWP7Y0FugdrOaUrHC
RwhLWJIL6YcX6eBbySojioe8E0tdlV6qiP9JdTk2KVjEsWYWX0UyqvodAoGBAMXX
mT6OpZkUCZg2FwoW/CpSZq0nVCA44preAdGjT0tAUEVWILkDRsKKqzsJqwo3wOHv
ftRuDTkU/E6xL/OZ7DfOJPTCtVechjGMySx8KsFCgzYgeooOffW8BVTGuTFrfFNi
LnsfThVJ728L0//BemDqcp7vGZExQgn9Lr50kSyhAoGABbk+dzQ18Nn+dbf8IMey
WoBD0ODzqF8o62TXFwbYLFAnRpw09aCZjvUV88DcHiTzqkUuDAzIGi8Po7yhu6ET
ZAnGUSoXouvNA3ecOVDEgahpqRH87KOENDo1vCH0RXTX5K/JMurtGxPoEV4Dcd/y
qL0Bv339tVHWNGpLkMUHMjECgYEArEtQZ8xupttuZ6JjeiP+QxUz2gPwHYeswNYq
m1kvywcdYOTa5oTV8MI20NlgnStkzN53g6S720RNXnKsoecgcpESWh3fM4dazngf
EqCn01qLTm4GiYiJZaHyupu92C4VPcC5XfwrUhrra7fPTmI+o3xJieQMTgepzW0y
ciat70ECgYEA5Kb23188akB9HHPFWPCyQFtM8d/sI1VPOQLCOgB9w1AjqZKvb58O
nNdE/NdIBoC9lx0xSEzWq2NVHoUfyqNiHIAm+pDCzkxmMfIglGFo8p/ebuQcXcxb
oS2kVWx3bcMzOlQSX0sK3hPS1cQ/xDq8CQohtyoihAkFGqGqpsApcwE=
-----END RSA PRIVATE KEY-----
EOF
fi
rpm -i "${CHEF_VERSION}" --quiet

#Client.rb
mkdir -p /etc/chef
rm -f /etc/chef/client.*
 
touch /etc/chef/client.rb

if [ "${DOMAIN}" == "qa.tabajara.intranet" ];then

cat <<EOF > /etc/chef/client.rb
# Server definitions
chef_server_url  "https://ze01.tabajara.intranet/organizations/qa-tabajara"
validation_key "/etc/chef/qa-tabajara-validator.pem"
validation_client_name "qa-tabajara-validator" 
node_name "${FQDN}"
ssl_verify_mode    :verify_none
file_backup_path   "/var/lib/chef"
file_cache_path    "/var/cache/chef"
pid_file           "/var/run/chef/client.pid"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true})
signing_ca_user "chef"
EOF

else

cat <<EOF > /etc/chef/client.rb
# Server definitions
chef_server_url  "https://ze01.tabajara.intranet/organizations/prod-tabajara"
validation_key "/etc/chef/prod-tabajara-validator.pem"
validation_client_name "prod-tabajara-validator" 
node_name "${FQDN}"
ssl_verify_mode    :verify_none
file_backup_path   "/var/lib/chef"
file_cache_path    "/var/cache/chef"
pid_file           "/var/run/chef/client.pid"
cache_options({ :path => "/var/cache/chef/checksums", :skip_expires => true})
signing_ca_user "chef"
EOF

fi
  
#Copy validation.pem
if [ "${DOMAIN}" == "qa.tabajara.intranet" ];then 
 cp -pr /root/qa-tabajara-validator.pem /etc/chef/qa-tabajara-validator.pem
else
 cp -pr /root/prod-tabajara-validator.pem /etc/chef/prod-tabajara-validator.pem
fi

chmod 600 /etc/chef/*.pem

#Coloca na run_list
echo "{\"run_list\":[\"recipe[bootstrap]\"]}" > /etc/chef/first-boot.json

#Chef-client bootstrap
if [ "${DOMAIN}" == "qa.tabajara.intranet" ];then
 /usr/bin/chef-client -E qa -j /etc/chef/first-boot.json
else
 /usr/bin/chef-client -E prod -j /etc/chef/first-boot.json
fi
 
#Chef-client role[base-centos] 
/usr/bin/chef-client -r role[base-centos] 
