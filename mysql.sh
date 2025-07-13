#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE= $(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date '+%Y-%m-%d-%H-%M-%S')
LOGFILE="${LOGS_FOLDER}/${LOG_FILE}-${TIME_STAMP}.log"

if [ ! -d ${LOGFILE} ]
then
    echo "Log directory does not exist.Creating log directory..."
    mkdir -p ${LOGFILE}
fi


CHEK_ROOT_USER(){
    if [ ${USERID} !=  0 ]
    then
        echo "ERROR: You must have sudo/root user access to execute this script" &>>${LOGFILE}
        exit 1 #other than 0
    fi

}

echo "$0 started executing at ${TIME_STAMP}" &>>${LOGFILE}




    