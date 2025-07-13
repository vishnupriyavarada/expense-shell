#!bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date "+%Y-%m-%d-%H-%M-%S")
APP_FOLDER="/app"

LOGFILE=${LOGS_FOLDER}/${LOGS_FILE}-${TIME_STAMP}.sh

CHECK_ROOT_USER(){
    if [ ${USERID} -ne 0 ]
    then
        echo "ERROR: You must have sudo/root user access to execute this script" 
        exit 1
    fi
}

if [ ! -d ${LOGS_FOLDER} ]
then
    echo "Log directory does not exist.Creating log directory..."
    CHEK_ROOT_USER
    mkdir -p ${LOGS_FOLDER}
fi

CHECK_ROOT_USER

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "$2 ... success" &>>${LOGFILE}
    else
        echo "$2 ... failed" &>>${LOGFILE}
    fi
}

NODEJS_STATUS=$(dnf list available | grep "nodejs")
    
if [ ${NODEJS_STATUS} == 0 ]
then
    dnf module disable nodejs -y &>>${LOGFILE}
    VALIDATE $? "Disabling older nodejs"

    dnf module enable nodejs:20 -y &>>${LOGFILE}
    VALIDATE $? "Enabling nodejs:20"

    dnf install nodejs -y &>>${LOGFILE}
    VALIDATE $? "Installing nodejs:20" &>>${LOGFILE}
else
    dnf install nodejs -y &>>${LOGFILE}
    VALIDATE $? "Installing nodejs:20" 
fi

useradd expense
VALIDATE $? "Adding expense user"

if [ ! -d ${APP_FOLDER} ]
then
    mkdir -p ${APP_FOLDER}
    VALIDATE $? "Creating app directory"   
fi

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>${LOGFILE}
VALIDATE $? "Downloading backend files"  

cd /app

unzip /tmp/backend.zip &>>${LOGFILE}
VALIDATE $? "unzip backend files"  

npm install &>>${LOGFILE}
VALIDATE $? "install dependencies"  

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service


# Prepare mysql schema
dnf install mysql -y  &>>${LOGFILE}
VALIDATE $? "Installing mysql client"  

mysql -h mysql.vishnudevopsaws.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Setting up the transactions schema and tables"  

systemctl daemon-reload &>>${LOGFILE}
VALIDATE $? "Daemon reload" 

systemctl enable backend &>>${LOGFILE}
VALIDATE $? "Enabling backend" 

systemctl start backend &>>${LOGFILE}
VALIDATE $? "Starting backend" 

