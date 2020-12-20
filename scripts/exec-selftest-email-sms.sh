#!/bin/sh

TEL="$1"
EMAIL="$2"

ssh root@zair01.tabajara.intranet "sh -x /usr/local/bin/selftest/self-test-sms-email.sh $TEL $EMAIL"
