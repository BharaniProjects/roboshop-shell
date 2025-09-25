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

if [ $ID -ne 0 ]
then
 echo -e "ERROR ::$R Please run this script as root access.$N"
 exit 1
else
    echo -e "$G You are root user.$N"
fi

dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>>$LOGFILE

VALIDATE $? "Enabling NodeJS:18"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJs:18"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "roboshop user cration"
else
    echo -e "roboshop user already exist..$Y Skipping..$N"
fi

#VALIDATE $? "creating roboshop user"

mkdir -p /app &>>$LOGFILE

VALIDATE $? "creating app directory"

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE

VALIDATE $? "downloading user application"

cd /app

unzip -o /tmp/user.zip &>>$LOGFILE

VALIDATE $? "unzipping user application"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

cp /home/centos/roboshop-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE

VALIDATE $? "copied user service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "reload daemon"

systemctl enable user &>>$LOGFILE

VALIDATE $? "Enabling user"

systemctl start user &>>$LOGFILE

VALIDATE $? "Starting user"

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE

VALIDATE $? "copied mongo repo in user"

dnf install mongodb-org-shell -y &>>$LOGFILE

VALIDATE $? "Installing mongo client"

mongo --host mongodb.mbkprojects.store </app/schema/user.js &>>$LOGFILE

VALIDATE $? "Loading user data into MongoDB"