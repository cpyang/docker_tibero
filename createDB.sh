export PATH
export TB_HOME=/opt/tmaxsoft/tibero6
if [ ! -v TB_SID ]; then
	TB_SID=tibero
fi
if [ ! -v TB_SYS_PASSWD ]; then
	TB_SYS_PASSWD=tibero
fi
export TB_SYS_PASSWD
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib
export JAVA_HOME=/usr/java/latest
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin:$JAVA_HOME/bin
ulimit -c 0
if [ ! -f $TB_HOME/config/$TB_SID.tip ]; then
	$TB_HOME/config/gen_tip.sh
	if [ ! -v MEMORY_TARGET ]; then
		MEMORY_TARGET=2048
	fi
	TOTAL_SHM_SIZE=$(( $MEMORY_TARGET / 2 ))
	sed -i "s/TOTAL_SHM_SIZE=/&`echo $TOTAL_SHM_SIZE`M#/" $TB_HOME/config/tibero.tip
	sed -i "s/MEMORY_TARGET=/&`echo $MEMORY_TARGET`M#/" $TB_HOME/config/tibero.tip
	echo _PSM_BOOT_JEPA=Y >> $TB_HOME/config/tibero.tip
	echo BOOT_WITH_AUTO_DOWN_CLEAN=Y >> $TB_HOME/config/tibero.tip
	cat $TB_HOME/config/tibero.tip
	echo "epa=((EXTPROC=(LANG=JAVA)(LISTENER=(HOST=localhost)(PORT=9390))))" >> $TB_HOME/client/config/tbdsn.tbr
	tbboot nomount
	#tbsql sys/tibero @$TB_HOME/scripts/create_database.sql
	tbsql sys/tibero << EOF
spool /tmp/create_database.log
create database "$TB_SID"
user sys identified by $TB_SYS_PASSWD
maxinstances 8
maxdatafiles 100
character set UTF8
national character set UTF16
logfile
	group 1 'log001.log' size 100M,
	group 2 'log002.log' size 100M,
	group 3 'log003.log' size 100M
maxloggroups 255
maxlogmembers 8
noarchivelog
	datafile 'system001.dtf' size 100M autoextend on next 100M maxsize unlimited
	default temporary tablespace TEMP
		tempfile 'temp001.dtf' size 100M autoextend on next 100M maxsize unlimited
		extent management local autoallocate
	undo tablespace UNDO
	datafile 'undo001.dtf' size 100M autoextend on next 100M maxsize unlimited
		extent management local autoallocate;
exit;
EOF
	tbboot
	$TB_HOME/scripts/system.sh -p1 $TB_SYS_PASSWD -p2 syscat -a1 Y -a2 Y -a3 Y -a4 Y
fi
sleep 5
tbsql sys/$TB_SYS_PASSWD << EOF
alter system checkpoint;
alter system checkpoint;
EOF
#tbdown -t IMMEDIATE
