#######
##
# Programacao para adicionar script:

01 12 * * *  root /bin/sleep `/usr/bin/expr $RANDOM \% 60`; /usr/local/bin/gluster/get-gluster-conf.sh > /dev/null 2>&1
