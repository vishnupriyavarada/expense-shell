#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date '+%Y-%m-%d-%H-%M-%S')
LOGFILE="${LOGS_FOLDER}/${LOG_FILE}-${TIME_STAMP}.log"

CHEK_ROOT_USER(){
    if [ ${USERID} !=  0 ]
    then
        echo "ERROR: You must have sudo/root user access to execute this script"
        exit 1 #other than 0
    fi

}

if [ ! -d ${LOGS_FOLDER} ]
then
    echo "Log directory does not exist.Creating log directory..."
    CHEK_ROOT_USER
    mkdir -p ${LOGS_FOLDER}
fi

CHEK_ROOT_USER

VALIDATE(){
    if [ $1 -ne 0 ]
    then
    echo "ERROR:$2 ... failed" 
    else
    echo "$2 ... Success"
    fi
}

echo "$0 started executing at ${TIME_STAMP}" &>>${LOGFILE}

dnf install mysql-server -y &>>${LOGFILE}
VALIDATE $? "mysql Installation"

systemctl enable mysqld
VALIDATE $? "Enabling mysql server "

systemctl start mysqld
VALIDATE $? "Starting mysql server" 

mysql -h mysql.vishnudevopsaws.online -u root -pExpenseApp@1 -e 'show databases;' &>>${LOGFILE}

if [ $? -ne 0 ]
then
    echo "mysql root password is not set"  &>>${LOGFILE}
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password" 
else
    echo "mysql root password is already set. Skipping." &>>${LOGFILE}
fi









    