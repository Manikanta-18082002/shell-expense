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

dnf install nginx -y  &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

#Remove the default content that web server is serving.
rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing Existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE

unzip /tmp/frontend.zip  &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

#Create Nginx Reverse Proxy Configuration.
# vim /etc/nginx/default.d/expense.conf 
#1) create sepearate file (give backend site name ) and copy to vim path

#Giving absolute path will not get much errors...
cp /home/ec2-user/shell-expense/expense.conf /etc/nginx/default.d/expense.conf  &>>$LOGFILE
VALIDATE $? "Copied Expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"

# telnet backend.dawsmani.site 8080
# Use: sudo systemctl start backend (When text entered in (Website) Amount Place )







