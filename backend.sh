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
read  mysql_root_password #No hypens -

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


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling NodeJS"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling NodeJS"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing NodeJS"

# useradd expense
# VALIDATE $? "Adding user" 
#

id expense  &>>$LOGFILE # Checking expense user exists already
if [ $? -ne 0 ] #If not exist then add user
then
    useradd expense  &>>$LOGFILE
    VALIDATE $? "Created Expense User"
else
    echo -e "Expense user already exists...$Y SKIPING $N"
fi

mkdir -p /app  &>>$LOGFILE # -p: if not exist create, else nothing todo silent
VALIDATE $? "Creating App directory"


curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip  &>>$LOGFILE
VALIDATE $? "Downloading backend code"

cd /app

rm -rf /app/* # start means -> Removing existing content inside this folder (If no this line below error)
unzip /tmp/backend.zip  &>>$LOGFILE #Archive:  /tmp/backend.zip -> (replace DbConfig.js? [y]es, [n]o, [A]ll, [N]one, [r]ename:)
VALIDATE $? "Extracted backend code"

npm install  &>>$LOGFILE
VALIDATE $? "Installing nodejs Dependencies"

# vim /etc/systemd/system/backend.service
#1) Dosen't use VIM by Shell scripting 
#2) Instead use <file>.service file

#Giving absolute path will not get much errors...
cp /home/ec2-user/shell-expense/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

 systemctl daemon-reload &>>$LOGFILE
 VALIDATE $? "Daemon Reload"

 systemctl start backend &>>$LOGFILE
 VALIDATE $? "Starting backend"
 
 systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

 dnf install mysql -y &>>$LOGFILE #TO connect to DB (This is MYSQL Client S/W)
VALIDATE $? "Installing MYSQL Client"

mysql -h db.dawsmani.site -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"

# netstat -lntp
# telnet db.dawsmani.site 3306














