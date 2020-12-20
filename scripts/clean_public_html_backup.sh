#!/bin/bash 
DIR="/root/public_html_backup" 

clean_public_html ()
        {
        /usr/bin/find $DIR -type f -name '*.tar.gz' -ctime +7 -exec rm '{}' ';'
        }

clean_public_html 
