#!/bin/bash
# for internal
self_ip=`ifconfig eth0|sed -n '/inet addr/s/^[^:]*:\([0-9.]\{7,15\}\) .*/\1/p'`
cluster_ip=$1
port=$2
node=$3
datadir=/DATA/$node

if [[ a$self_ip -eq a ]];then
	self_ip="127.0.0.1"
fi
if [[  $# -ne 3 ]];then
	echo "usage:	pxc_add_nodes.sh Cluster_ip Port Node"
	exit
fi
folder=pxc_packages
# init

mkdir $folder
cd $folder
#get packages
wget -q http://192.168.1.201/pub/software/unix/MySQL/Percona/pxc/5.5.30-23.7.4/Percona-XtraDB-Cluster-client-5.5.30-23.7.4.404.rhel6.x86_64.rpm
wget -q http://192.168.1.201/pub/software/unix/MySQL/Percona/pxc/5.5.30-23.7.4/Percona-XtraDB-Cluster-devel-5.5.30-23.7.4.404.rhel6.x86_64.rpm
wget -q http://192.168.1.201/pub/software/unix/MySQL/Percona/pxc/5.5.30-23.7.4/Percona-XtraDB-Cluster-galera-2.5-1.150.rhel6.x86_64.rpm
wget -q http://192.168.1.201/pub/software/unix/MySQL/Percona/pxc/5.5.30-23.7.4/Percona-XtraDB-Cluster-server-5.5.30-23.7.4.404.rhel6.x86_64.rpm
wget -q http://192.168.1.201/pub/software/unix/MySQL/Percona/pxc/5.5.30-23.7.4/Percona-XtraDB-Cluster-shared-5.5.30-23.7.4.404.rhel6.x86_64.rpm


#install

yum install nc -q -y
yum install xtrabackup -q -y
rpm -Uh Percona-XtraDB-Cluster-galera-2.5-1.150.rhel6.x86_64.rpm
rpm -Uh Percona-XtraDB-Cluster-shared-5.5.30-23.7.4.404.rhel6.x86_64.rpm
rpm -Uh Percona-XtraDB-Cluster-devel-5.5.30-23.7.4.404.rhel6.x86_64.rpm
rpm -Uh Percona-XtraDB-Cluster-client-5.5.30-23.7.4.404.rhel6.x86_64.rpm
rpm -Uh Percona-XtraDB-Cluster-server-5.5.30-23.7.4.404.rhel6.x86_64.rpm


#config



cnf_content="
[client]\n
socket=$datadir/mysql$port.sock\n
\n
[mysqld_safe]\n
wsrep_urls=gcomm://$cluster_ip\n
\n
[mysqld]\n
port = $port\n

socket=$datadir/mysql$port.sock\n
datadir=$datadir\n
user=mysql\n
log_error=error.log\n
binlog_format=ROW\n
wsrep_provider=/usr/lib64/libgalera_smm.so\n
wsrep_sst_receive_address=$self_ip:4020\n
wsrep_node_incoming_address=$self_ip\n
wsrep_slave_threads=32\n
wsrep_cluster_name=sohupxc1\n
wsrep_provider_options = \"gmcast.listen_addr=tcp://$self_ip:4030;\"\n
wsrep_sst_method=xtrabackup\n
wsrep_sst_auth=dba:dba\n
wsrep_node_name=$node\n
innodb_locks_unsafe_for_binlog=1\n
innodb_autoinc_lock_mode=2\n
\n
performance_schema\n
open_files_limit = 65535\n
interactive_timeout = 3600\n
expire_logs_days=15\n
wait_timeout = 3600\n
net_write_timeout=360\n
innodb-status-file\n
local_infile = 0\n
#skip-name-resolve\n
lower_case_table_names = 1\n
back_log = 200\n
max_connections = 1000\n
max_connect_errors = 1000000\n
table_cache = 1024\n
external-locking = FALSE\n
max_allowed_packet = 64M\n
max_heap_table_size = 96M\n
sort_buffer_size = 32M\n
join_buffer_size = 8M\n
thread_cache_size = 512\n
thread_concurrency = 16\n
query_cache_size =0\n
query_cache_limit = 2M\n
query_cache_min_res_unit = 2k\n
ft_min_word_len = 4\n
thread_stack = 192K\n
tmp_table_size = 120M\n
tmpdir = /tmp\n
binlog_cache_size = 64M\n
key_buffer_size = 256M\n
read_buffer_size = 8M\n
read_rnd_buffer_size = 32M\n


binlog_format=ROW\n
log-bin = mysql-bin\n
max_binlog_size=300M\n
relay-log = relay\n
sync_binlog=1\n
max_binlog_size=300M\n
log_slave_updates\n
#enforce_storage_engine=InnoDB\n
#default_storage_engine=InnoDB\n
innodb_doublewrite=1\n
innodb_flush_log_at_trx_commit = 1\n
innodb_additional_mem_pool_size = 128M\n
innodb_buffer_pool_size = 80G\n
innodb_data_file_path=ibdata1:200M:autoextend\n
innodb_log_buffer_size = 5242880\n
innodb_log_files_in_group=3\n
innodb_log_file_size= 200M\n
innodb_max_dirty_pages_pct = 80\n
innodb_lock_wait_timeout = 120\n
innodb_file_per_table\n
innodb_rollback_on_timeout\n
innodb_sync_spin_loops = 30\n
innodb_locks_unsafe_for_binlog=1\n
innodb_autoinc_lock_mode=2\n
innodb_flush_method = O_DIRECT\n
innodb_read_io_threads = 16\n
innodb_write_io_threads = 16\n
innodb_io_capacity = 20000\n
innodb_buffer_pool_restore_at_startup=0\n
innodb_buffer_pool_populate=1\n
"
echo -e $cnf_content >/etc/my.cnf
chmod 644 /etc/my.cnf
mysql_install_db --defaults-file=/etc/my.cnf
service mysql restart

counts=`ps aux |grep mysql |wc -l`
if [[ $counts -gt 1 ]];then
 	echo '1'
else
	echo '0'
