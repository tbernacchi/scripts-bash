#!/bin/bash
/usr/bin/sshpass -p 'mudar123' rsync -avzh root@fachada01.prd1.tabajara.local:/home/imagens/email/* /var/www/Institucional/imagens/ 2>&1 > /dev/null
