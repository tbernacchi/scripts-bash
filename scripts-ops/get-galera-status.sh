#!/bin/sh

# This scrpit is used for get all galera status in tabajara Environment
# Date: 12/03/2019
# Author: ambrosia@gmail.com

ZBXCONF="/etc/zabbix/zabbix_agentd.conf"

fn_send_zabbix()
  {
  /usr/bin/zabbix_sender -c $ZBXCONF -k $KEY -o `echo $VALUE`
  }

#Total number of cluster membership changes happened.
NUM_CHG_MEMB_CLUSTER=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_cluster_conf_id';" | mysql -u replicator --password="admin" | tail -n1`

KEY="NUM_CHG_MEMB_CLUSTER"
VALUE=$NUM_CHG_MEMB_CLUSTER
fn_send_zabbix

#Current number of members in the cluster.
NUM_MEMBERS=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_cluster_size';" | mysql -u replicator --password="admin" | tail -n1`
KEY="NUM_MEMBERS"
VALUE=$NUM_MEMBERS
fn_send_zabbix

 #whether the node is part of a PRIMARY or NON_PRIMARY component.
MEMBER_IS=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_cluster_status';" | mysql -u replicator --password="admin" | tail -n1`
KEY="MEMBER_IS"
VALUE=$MEMBER_IS
fn_send_zabbix

#  the node has not yet connected to any of the cluster components.
MEMBER_CONN=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_connected';" | mysql -u replicator --password="admin" | tail -n1`
KEY="MEMBER_CONN"
VALUE=$MEMBER_CONN
fn_send_zabbix

  #Shows the internal state of the EVS Protocol
EVS_STATUS=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_evs_state';" | mysql -u replicator --password="admin" | tail -n1`
KEY=EVS_STATUS
VALUE=$EVS_STATUS
fn_send_zabbix

  #How much the slave lag is slowing down the cluster.
LAG_TIME_NODE=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_flow_control_paused';" | mysql -u replicator --password="admin" | tail -n1`
KEY="LAG_TIME_NODE"
VALUE=$LAG_TIME_NODE
fn_send_zabbix

  #Returns the number of FC_PAUSE events the node has received. Does not reset over time
FC_PAUSE=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_flow_control_recv';" | mysql -u replicator --password="admin" | tail -n1`
KEY="FC_PAUSE"
VALUE=$FC_PAUSE
fn_send_zabbix

  #Returns the number of FC_PAUSE events the node has sent. Does not reset over time
FC_PAUSE_NUM=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_flow_control_sent';" | mysql -u replicator --password="admin" | tail -n1`
KEY="FC_PAUSE_NUM"
VALUE=$FC_PAUSE_NUM
fn_send_zabbix

  #Displays the group communications UUID.
UUID_GROUP=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_gcomm_uuid';" | mysql -u replicator --password="admin" | tail -n1`
KEY="UUID_GROUP"
VALUE=$UUID_GROUP
fn_send_zabbix

# Last WSREP Commit  or seqno
WSREP_COMMIT=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_last_committed';" | mysql -u replicator --password="admin" | tail -n1`
KEY="WSREP_COMMIT"
VALUE=$WSREP_COMMIT
fn_send_zabbix

   #Internal Galera Cluster FSM state number.
FSM_CLUSTER_STATE=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_state';" | mysql -u replicator --password="admin" | tail -n1`
KEY="FSM_CLUSTER_STATE"
VALUE=$FSM_CLUSTER_STATE
fn_send_zabbix

#Total number of local transactions that were aborted by slave transactions while in execution.
TRANSACTIONS_ABORTED=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_bf_aborts';" | mysql -u replicator --password="admin" | tail -n1`
KEY=TRANSACTIONS_ABORTED
VALUE=$TRANSACTIONS_ABORTED
fn_send_zabbix

   #Current (instantaneous) length of the recv queue.
QUEUE_LENGHT_REC=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_recv_queue';" | mysql -u replicator --password="admin" | tail -n1`
KEY="QUEUE_LENGHT_REC"
VALUE=$QUEUE_LENGHT_REC
fn_send_zabbix

   #Current (instantaneous) length of the send queue.
QUEUE_LENGHT_SND=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_send_queue';" | mysql -u replicator --password="admin" | tail -n1`
KEY="QUEUE_LENGHT_SND"
VALUE=$QUEUE_LENGHT_SND
fn_send_zabbix

   #Human-readable explanation of the state.
SYNC_STATE=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_state_comment';" | mysql -u replicator --password="admin" | tail -n1`
KEY="SYNC_STATE"
VALUE=$SYNC_STATE
fn_send_zabbix

 #The UUID of the state stored on this node.
STATE_UUID=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_local_state_uuid';" | mysql -u replicator --password="admin" | tail -n1`
KEY="STATE_UUID"
VALUE=$STATE_UUID
fn_send_zabbix

   #Whether the server is ready to accept queries.
QUERY_STATE=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_ready';" | mysql -u replicator --password="admin" | tail -n1`
KEY="QUERY_STATE"
VALUE=$QUERY_STATE
fn_send_zabbix

   #Total size of write-sets received from other nodes.
BYTES_RCV=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_received_bytes';" | mysql -u replicator --password="admin" | tail -n1`
KEY="BYTES_RCV"
VALUE=$BYTES_RCV
fn_send_zabbix

   #Total size of write-sets replicated.
BYTES_REPL=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_replicated_bytes';" | mysql -u replicator --password="admin" | tail -n1`
KEY="BYTES_REPL"
VALUE=$BYTES_REPL
fn_send_zabbix

   #Total size of data replicated.
BYTES_DATA_REPL=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_repl_data_bytes';" | mysql -u replicator --password="admin" | tail -n1`
KEY="BYTES_DATA_REPL"
VALUE=$BYTES_DATA_REPL
fn_send_zabbix

   #Total number of keys replicated.
KEYS_REPL=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_repl_keys';" | mysql -u replicator --password="admin" | tail -n1`
KEY="KEYS_REPL"
VALUE=$BYTES_REPL
fn_send_zabbix

   #Total size of keys replicated in bytes
KEYS_REPL_BYTES=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_repl_keys_bytes';" | mysql -u replicator --password="admin" | tail -n1`
KEY="KEYS_REPL_BYTES"
VALUE=$KEYS_REPL_BYTES
fn_send_zabbix

   #Total size of other bits replicated
OTHER_BITS_REPL=`echo "select VARIABLE_VALUE from information_schema.GLOBAL_STATUS where VARIABLE_NAME = 'wsrep_repl_other_bytes';" | mysql -u replicator --password="admin" | tail -n1`
KEY="OTHER_BITS_REPL"
VALUE=$OTHER_BITS_REPL
fn_send_zabbix
