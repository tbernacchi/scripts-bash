#!/bin/sh

gzip `find /var/log/sms/ -type f -ctime +1 -name "sms-mail-dispatcher.log.*"`

rm -f `find /var/log/sms/ -type f -ctime +90 -name "*.gz"`
