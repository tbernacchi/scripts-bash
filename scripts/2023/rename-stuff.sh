#!/bin/bash
#Preciso testar
for f in `ls 165*` ; do 
  echo rename s/$(echo $f | awk -F_ '{print $1}')/$(echo $f | awk -F_ '{print $1}' | \ 
  xargs -I {} date -jr {} '+%Y%m%d-%H%M')/ 165\* ; \  
done  > rename-stuff.sh
