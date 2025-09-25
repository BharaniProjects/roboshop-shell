#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>>$LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "ERROR :: $2 ... $R Failed$N"
        exit 1
    else
        echo -e "$2 ... $G Success$N"
    fi
}

if [ ID -ne 0 ]
then
 echo -e "ERROR ::$R Please run this script as root access.$N"
 exit 1
else
    echo -e "$G You are root user.$N"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copied mongoDB repo"

dnf install mongodb-org -y &>>$LOGFILE

VALIDATE $? "Installing manogDB"

systemctl enable mongod &>>$LOGFILE

VALIDATE $? "Enabling mongoDB"

systemctl start mongod &>>$LOGFILE

VALIDATE $? "started mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOGFILE

VALIDATE $? "Remote access to mongoDB"

systemctl restart mongod &>>$LOGFILE

VALIDATE $? "restarting mongoDB"