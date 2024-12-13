#!/bin/bash
/usr/bin/sshpass -p 'mudar123' rsync -avzh root@zarpa01.tabajara.intranet:/glusterfs/volume-site-institucional/imagens-admin/imagens-admin/* /var/www/Institucional/imagens/ 2>&1>/dev/null
