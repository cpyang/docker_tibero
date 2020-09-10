#!/usr/bin/env bash

########### SIGINT handler ############
function handle_int() {
	echo "Stopping container."
	echo "SIGINT received, shutting down database!"
	tbsql sys/tibero << EOF
alter system checkpoint;
alter system checkpoint;
EOF
	tbdown -t IMMEDIATE
	sleep 5
	running=0
	exit 0
}

########### SIGTERM handler ############
function handle_term() {
	echo "Stopping container."
	echo "SIGTERM received, shutting down database!"
	tbsql sys/tibero << EOF
alter system checkpoint;
alter system checkpoint;
EOF
	tbdown -t IMMEDIATE
	sleep 5
	running=0
	exit 0
}

########### SIGKILL handler ############
function handle_kill() {
	echo "Stopping container."
	echo "SIGKILL received, aborting database!"
	tbsql sys/tibero << EOF
alter system checkpoint;
alter system checkpoint;
EOF
	tbdown -t ABORT
	sleep 5
	running=0
	exit 1
}

# Set SIGINT handler
trap 'handle_int' SIGINT

# Set SIGTERM handler
trap 'handle_term' SIGTERM SIGHUP

# Set SIGKILL handler
trap 'handle_kill' SIGKILL

##################################################################
export PATH
export TB_HOME=/opt/tmaxsoft/tibero6
export TB_SID=tibero
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib
export JAVA_HOME=/usr/java/latest
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin:$JAVA_HOME/bin

if [ -d $TB_HOME/database/$TB_SID ]; then
	tbboot
else
	exec /home/tibero/createDB.sh
fi
##################################################################

running=1

while true; do
  if [ "$running" = "1" ]; then
    sleep 1
  else
    break
  fi
done
