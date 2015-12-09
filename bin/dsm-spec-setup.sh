#!/bin/sh

source $HOME/.dsm/dsmrc

dsmtrap() {
  echo shutting down dsm database
  ps -ef | sed -n "/[m]ysqld.*dsm/p" | awk '{ print $2 }' | xargs kill
  echo running homebrew mysql instance
  launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.mysql.plist
  sleep 2
}

echo stopping homebrew mysql instance
ls -lrt -d -1 ~/Library/LaunchAgents/* |  grep 'mysql.plist' | xargs launchctl unload -w

dbdir="$dsmdir/dsm"

echo removing $dsmdir
rm -rf "$dsmdir"

echo setting up mysql instance
mkdir -p "$dbdir/data"

cat <<-CNF > $dbdir/my.cnf
[mysqld]
pid-file = $dbdir/mysqld.pid
socket = $dbdir/mysqld.sock
port = $port
log_output = FILE
log-error = $dbdir/error.log
datadir = $dbdir/data
log-bin = db-bin
log-bin-index = db-bin.index
server-id = 1
CNF

(
  cd "$mysqldir"
  install_bin="$(echo ./*/mysql_install_db | tr " " "\\n" | head -1)"
  $install_bin --datadir="$dbdir/data"
)

echo starting mysql instance
"$mysqldir"/bin/mysqld --defaults-file="$dbdir/my.cnf" 2>&1 >$dbdir/lhm.log &
sleep 5

echo create database dsm
db() { "$mysqldir"/bin/mysql --protocol=TCP -P $port -uroot; }
echo "create database dsm" | db

trap dsmtrap SIGTERM SIGINT

echo DSM mysql instance running...
wait
