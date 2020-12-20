#!/bin/bash
/usr/bin/expect <<END 
set timeout 120
spawn adcli join tabajaradc.local -U svc_chef

expect "Password for svc_chef@TABAJARADC.LOCAL:"
send "#Caciquexingu@2018\r"

expect eof
END
