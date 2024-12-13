#!/bin/bash 
export https_proxy=http://proxy.tabajara.intranet:3130/
export http_proxy=http://proxy.tabajara.intranet:3130/
export no_proxy='.tabajara.local, 10.0.0.0/8'
/usr/bin/wget -q -N http://cefs.steve-meier.de/errata.latest.xml
