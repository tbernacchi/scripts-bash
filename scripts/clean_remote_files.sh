#!/bin/bash
REMOTE_FILES="/var/log/remotefiles/" 

clean_remote_files()
        {
	cd $REMOTE_FILES 
        /usr/bin/find . -type d -ctime +30 -exec rm -rf '{}' ';'
        }
clean_remote_files
