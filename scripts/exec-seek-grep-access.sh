# Programacao para adicionar script:

# monitoria de url no squid
*/2 * * * *  root /bin/sleep `/usr/bin/expr $RANDOM \% 30`; /usr/local/bin/seek-urls/seek-grep-access.sh  > /dev/null 2>&1
