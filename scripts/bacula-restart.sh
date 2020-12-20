#!/bin/sh

/usr/local/bin/bacula-stop.sh
sleep 3
/usr/local/bin/bacula-start.sh
echo "Use: bconsole - Test the environment"
