#!/bin/bash
export http_proxy=http://proxy.tabajara.intranet:3130
export https_proxy=https://proxy.tabajara.intranet:3130
TOTAL="5000000"
LAST7DAYS=$(curl -s -A 'Mandrill-Curl/1.0' -d '{"key":"Q_Wsq_bKhIbb-EbDXwO_8A"}' \
'https://mandrillapp.com/api/1.0/users/info.json' | jq '.stats.last_7_days.sent')
ZBXPRX="zbxprx01.tabajara.local"
ZBXSND=$(which zabbix_sender)
AGR="mailchimp-mandrill-email"
KEY="QUOTA"

fn_send_zabbix() {
$ZBXSND -z $ZBXPRX -s $AGR -k $KEY -o "$perc"
}

perc=`echo "scale=2; ($LAST7DAYS/$TOTAL) * 100" | bc -l`

fn_send_zabbix 
