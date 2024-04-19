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

echo "Please enter DB Password"
read -s mysql-root-password

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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing My-SQL Server...."

systemctl enable mysqld &>>LOGFILE
VALIDATE $? "Enabling MY-SQL Server....."

systemctl start mysqld &>>LOGFILE
VALIDATE $? "Starting MY-SQL Server....."

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>LOGFILE
# VALIDATE $? "Setting up Root password..."


#Below code will be useful for Idempotent nature
mysql -h db.dawsmani.site -uroot -p${mysql-root-password} -e 'show databases;' &>>LOGFILE# Checking does Passwoed is setup already?
if [ $? -ne 0 ]
then 
     mysql_secure_installation --set-root-pass ${mysql-root-password} &>>$LOGFILE
     VALIDATE $? "Setting up MYSQL Root Password"
else
    echo -e "MYSQL Password ALready Setup... $Y SKIPPING $N"
fi
























