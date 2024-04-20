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
read  mysql_root_password #No hypens -  add -s for security

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
#Failure in password when runned 2nd Time


#Below code will be useful for idempotent nature (don't run code if the effect of the code is already present. (Exists password))
# Shell script is not Idempotent

#Checking does password is already SET-UP
mysql -h db.dawsmani.site -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE  
if [ $? -ne 0 ]  # Then set the password (BCZ 1st time running)
then
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE #Setting up give password: ExpenseApp@1
    VALIDATE $? "MySQL Root password Setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi


#---------------
# TO check Data exist?
# mysql -h db.dawsmani.site -uroot -pExpenseApp@1
# mysql> show databases;
# +--------------------+
# | Database           |
# +--------------------+
# | information_schema |
# | mysql              |
# | performance_schema |
# | sys                |
# | transactions       |
# +--------------------+

# mysql> use transactions

# Database changed
# mysql> select * from transactions;
# +----+--------+-------------+
# | id | amount | description |
# +----+--------+-------------+
# |  1 |     17 | Surya       |
# +----+--------+-------------+
# 1 row in set (0.00 sec)

#exit




















