########################################################################
# Bug #483827: support for mysqld_multi
########################################################################

function modify_args()
{
  XB_ARGS=`echo $XB_ARGS | sed -e 's/my.cnf/my_multi.cnf/'`
  IB_ARGS=`echo $IB_ARGS | sed -e 's/my.cnf/my_multi.cnf/'`
}

. inc/common.sh

start_server

backup_dir=$topdir/backup

# change defaults file from my.cnf to my_multi.cnf
modify_args

# make my_multi.cnf
sed -e 's/\[mysqld\]/[mysqld1]/' $topdir/my.cnf > $topdir/my_multi.cnf

# Backup
xtrabackup --backup --defaults-group=mysqld1 --target-dir=$backup_dir
xtrabackup --prepare --target-dir=$backup_dir

stop_server

# clean datadir
rm -rf ${mysql_datadir}/*

# restore backup
xtrabackup --copy-back --defaults-group=mysqld1 --target-dir=$backup_dir

# make sure that data are in correct place
if [ ! -f ${mysql_datadir}/ibdata1 ] ; then
  vlog "Data not found in ${mysql_datadir}"
  exit -1
fi
