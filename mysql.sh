#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/shellscript-log"
LOG_FILE= $(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date '+%Y-%m-%d-%H-%M-%S')
LOGFILE="${LOGS_FOLDER}/${LOG_FILE}-${TIME_STAMP}.log"

echo "$0 started executing at ${TIME_STAMP}" &>>${LOGFILE}

if [ ${USERID} !=  0 ]
then
    echo "ERROR: You must have sudo/root user access to execute this script" &>>${LOGFILE}
fi


    