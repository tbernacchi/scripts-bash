#!/bin/bash
/usr/bin/sshpass -p 'mudar123' rsync -avzh root@fachada01.prd1.tabajara.local:/var/www/Institucional/public_html/* /var/www/Institucional/public_html/ 2>&1 > /dev/null 
