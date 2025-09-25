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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm --skip-broken &>>$LOGFILE

VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y &>>$LOGFILE

VALIDATE $? "Enabling redis"

dnf install redis -y &>>$LOGFILE

VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGFILE

VALIDATE $? "Allowing remote connections"

systemctl enable redis &>>$LOGFILE

VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGFILE

VALIDATE $? "Started redis"