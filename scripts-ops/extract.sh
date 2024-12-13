#!/bin/bash
/usr/bin/tar zxf nginx-ldap-1.13.10.tar.gz
cp -pr etc/nginx/* /etc/nginx
cp -pr usr/local/nginx/* /usr/local/nginx
rm -rf /opt/nginx/etc/ && rm -rf /opt/nginx/usr/
