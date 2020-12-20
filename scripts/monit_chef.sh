#!/bin/sh    
#Script to monitoring the state of chef-server
HST=`hostname -f`                                                                                            
                                                                                                             
#LOCKFILE                                                                                                   
LOCK="/tmp/chef-lock"                                                                                      
                                                                                                             
#SENDER                                                                                          
ZBXPRX="zbxprx04.tabajara.intranet"                                                                                
ZBXSND=$(which zabbix_sender)                                                                                
                                                                                                             
#LOCK                                                                                                     
fn_check_lock() {                                                                                                    
if [ -e $LOCK ];then                                                                                         
	echo "Arquivo de lock $LOCK encontrado, saindo..."                                   
 	exit 0                                                                               
else                                                                                         
 	echo $$ > $LOCK                                                                      
  	fn_check_chef   
fi                                                                                                   
}                                                                                                    
                                                                                                             
fn_check_chef() {                                                                                                    
DOWN=$(chef-server-ctl status | awk -F: '{ print $1"-"$2}' | sed 's/ //g') 

for component in `echo $DOWN`;do
 KEY=`echo $component | sed 's/run-//g'`
 STATUS=`echo $component | cut -f1 -d"-"`
	if [ "$STATUS" == down ];then 
   	fn_send_zabbix_critical
   	else 
   	fn_send_zabbix_ok
   	fi 
done 
}                                                                                                    
                                                                                                             
fn_send_zabbix_critical() {                                                                                                    
MSG="FAILED - Falha no componente $KEY no $HST"                                          
$ZBXSND -z $ZBXPRX -s $HST -k $KEY -o "$MSG"                                               
}                                                                                                    
                                                                                                             
fn_send_zabbix_ok() {                                                                                                    
$ZBXSND -z $ZBXPRX -s $HST -k $KEY -o 0                                                    
}                                                                                                    

fn_gc() {                                                                                                    
rm $LOCK                                                                                                                                                                    }                                                                                                    
fn_check_lock                                                                                                
fn_gc         
