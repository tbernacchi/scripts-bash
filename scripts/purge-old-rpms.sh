#!/bin/sh

# USE: This shell script is responsable for purge old rpm files in production internal repository
# 
# Author: Ambrosia Ambrosiano
# mail: ambrosia.ambrosiano@tabajara.com.br / ambrosia@gmail.com
# Data: 18/02/2019

WORKDIR="/var/www/html/prod/tabajarapackages"
LIST_PKG="/tmp/list-pkg"
LIST_PKG_CONV="/tmp/list-pkg-conv"
LIST_PKG_FULL="/tmp/list-pkg-full"
LIST_EXCL="/tmp/list-exclude"

fn_make_list()
	{

		cd $WORKDIR


		# Using with the wildcard for the first selection
		ls $WORKDIR | sed 's/[0-9]/?/g' | grep rpm | sort  -u > $LIST_PKG

		# change the wildcard for another character, so the shell ignore the real function
		cat $LIST_PKG | sed 's/?/%/g' > $LIST_PKG_CONV


		# populate file list for a new file 
		for list in `cat $LIST_PKG_CONV`
			do
				NAME=`echo $list | sed 's/%/?/g'`

				ls $NAME > $LIST_PKG_FULL-$list
			done

	}


fn_make_exclude()
	{

		cd $WORKDIR

		# Generate the exclude list for reverse in grep commadn
		LST=`ls /tmp/ | grep list-pkg-full`

		for list in `echo $LST`
			do
				EXCLUDE=`cat  /tmp/$list | tail -n 5 |  sed ':a;$!N;s/\n/|/g;ta'`

				TODEL=$(cat /tmp/$list | egrep -v `echo $EXCLUDE`)

				for todel in `echo $TODEL`
					do
						rm -f $todel
					done
			done
	}

fn_update_repo()
	{
		# For this operation, the external script create-repo-dev-2-prod.sh verify the last update
		# for a rpm file
		# Howto: rpm generation
		# cd /tmp
		# mkdir pkg
		# echo "eh fake" > fake-rpm.txt
		# tar fake-rpm.tgz fake-rpm.txt
		# alien -r fake-rpm.tgz
		# cp fake-rpm.(version).rpm /var/www/html/prod/tabajarapackages

		touch $WORKDIR/fake-rpm-1-2.noarch.rpm

		sh /usr/local/bin/repo/create-repo-dev-2-prod.sh
	}

fn_gc()
	{
		rm -f $LIST_PKG
		rm -f $LIST_PKG_CONV
		rm -f $LIST_PKG_FULL
		rm -f $LIST_EXCL
	}

fn_make_list
fn_make_exclude
fn_update_repo
fn_gc
