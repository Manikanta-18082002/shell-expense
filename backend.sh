#!/bin/bash

USERID=$(id -u)

TIMESTAMP=$( date +%F-%H-%M-%S) #Executing command in shell script and  taking output in variable
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) # $0 : Script Name  (Ex: echo 11-functions.sh | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log #(In temp directoy lo name hypen timestamp.log (File))

echo "Script started executing at: $TIMESTAMP"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2....$R FAILURE $N"
        exit 400
    else
        echo -e "$2....$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "You must be a ROOT USER"
    exit 1 #Manually exit if error comes
else
    echo "You are the ROOT USER"
fi


dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing NodeJS"

useradd expense  &>>LOGFILE
if [ $? -ne 0 ]
then
    useradd expense  &>>LOGFILE
    VALIDATE $? "Created Expense User"
else
    echo -e "Expense user already exists...$Y SKIPING $N"
fi



# mkdir /app


# curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip


# cd /app



# unzip /tmp/backend.zip






















