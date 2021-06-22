#!/bin/bash

#########################################################################################################
#Script Name            : MariaDB_Installation_Script.sh                                                #
#Usage                  : sh MariaDB_Installation_Script                                                #
#Usage example          : sh MariaDB_Installation_Script                                                #
#Purpose                : Install MariaDB by using shell script                                         #
#########################################################################################################
# Version       Author          Description                             Date                            #
# -------       ------          -----------                             ----                            #
# 1.0           Vasu           Initial Creation                       11-06-2021                        #
#########################################################################################################

      echo     "                                                                                                         "
             printf " %-40s \n" "`date`                                                                                  "
      echo     "                                          ,--.   ,--.               ,--.        ,------.  ,-----.        "
      echo     "                                          |   '.'   | ,--,--.,--.--.'--' ,--,--.|  .-.  \ |  |) /_       "
      echo     "                                          |  |'.'|  |' ,-.  ||  .--',--.' ,-.  ||  |  \  :|  .-.  \      "
      echo     "                                          |  |   |  |\ '-'  ||  |   |  |\ '-'  ||  '--'  /|  '--' /      "
      echo     "                                          '--'   '--' '--'--''--'   '--' '--'--''-------' '------'       "
      echo     "                                                                                                         "

read -p " Please enter the option

                                ----------------------------------------------------------------------------

                                                (1) MariaDB Database Installation .. Type 1
                                                (2) INSTALL Metadata_lock_info Plugin .. Type 2
                                                (3) time_zone_name Meta Database Deployment .. Type 3

                                ----------------------------------------------------------------------------

Please select your option :" INPUT_STRING

mysql_os_group_user_creation() {

read -p " List of versions for MariaDB version

                                      -----------------------------------------
                                         10.3.29      10.4.19        10.5.10
                                         10.3.28      10.4.18        10.5.9
                                         10.3.27      10.4.17        10.5.8
                                         10.3.26      10.4.16        10.5.7
                                         10.3.25      10.4.15        10.5.6
                                      -----------------------------------------

Please enter which MariaDB version to install :" VERSION

    printf "###########################################################################################\n";
    printf "                      (1) MariaDB Database Installation !!!!                               \n";
    printf "###########################################################################################\n";

printf "===================================================================\n";
printf "         PART - I -  Creating GROUP and User in Linux Server       \n";
printf "===================================================================\n";

echo "************ OS User and OS Group Creation for MariaDB Database ************"

while [ x$groupname = "x" ]; do
read -p "What is the OS group_name you would like to create.
         If group not exist, it will be created : " groupname
if id -g $groupname >/dev/null 2>&1; then
echo "Group exist"
else
groupadd $groupname
fi
done

while [ x$username = "x" ]; do
read -p "What is the OS username you would like to create : " username
if id -u $username >/dev/null 2>&1; then
echo "User already exists"
#username=""
useradd $username -g $groupname
fi
done

read -p "Please enter bash [/bin/bash] : " bash
if [ x"$bash" = "x" ]; then
bash="/bin/bash"
fi

read -p "Please enter homedir [/home/$username] : " homedir
if [ x"$homedir" = "x" ]; then
homedir="/home/$username"
fi

read -p "Please confirm [y/n]" confirm
if [ "$confirm" = "y" ]; then
useradd -g $groupname -s $bash -d $homedir -m $username
fi

RC=${?}
return ${RC}
}


dependency_packages () {
echo
echo
printf "======================================================================================\n";
printf "         PART - II -  Cheking Dependency packages which is required to MariaDB        \n";
printf "======================================================================================\n";

echo "Checking availability of pre-required packages"

sudo rpm -q libaio
if [ $? != 0 ]
then
echo "libaio package not found. Installing it......."
sudo yum install libaio.x86_64 -y
fi

sudo rpm -q numactl-libs
if [ $? != 0 ]
then
echo "numactl-libs package not found. Installing it......."
sudo yum install numactl-libs.x86_64 -y
fi

sudo rpm -q tar
if [ $? != 0 ]
then
echo "tar package not found. Installing it......."
sudo yum install tar -y
fi

sudo rpm -q wget
if [ $? != 0 ]
then
echo "wget package not found. Installing it......."
sudo yum install wget -y
fi

#sudo rpm -q libncurse*
#if [ $? != 0 ]
#then
#echo "libncurse package not found. Installing it......."
#sudo yum install libncurse* -y
#fi

sudo rpm -q expect
if [ $? != 0 ]
then
echo "expect package not found. Installing it......."
sudo yum install expect -y
fi

}

mariadb_mount_point_check () {
echo
echo
printf "===========================================================================================================================\n";
printf "     PART - III - Checking Mountpoint and Creating Data Directory , binlog Directory for MariaDB Database Installation     \n";
printf "===========================================================================================================================\n";

#MariaDB mount point is checking

#mount_point="/mariadb"
mount_point="/home"
if [[  -d $mount_point ]]
then
mount|grep -q "$mount_point" && echo "$mount_point is mounted !!!!! "
else
mount|grep -q "$mount_point" || echo "$mount_point is not mounted ...Can't Continue....!"
exit 1
fi
}

#Create directory if not exists :

data_directory_creation () {

echo "The below part for creation of Data dir and binlog directory .... "
echo "Enter directory name [ /home ]"
#echo "Enter directory name [ /mariadb ]"
read dirname

if [[  -d "$dirname" ]]
then
#   mkdir $dirname/mariadb/data
    mkdir $dirname/data
#   mkdir $dirname/mariadb/binlog
    mkdir $dirname/binlog
#   chown -R mysql:mysql $dirname/mariadb/data
    chown -R mysql:mysql $dirname/data
#   chown -R mysql:mysql $dirname/mariadb/binlog
    chown -R mysql:mysql $dirname/binlog
else
    exit 1
fi

echo "Data Directory has been created....."
}

extract_software_install_mariadb () {

echo
echo
printf "=======================================================================================\n";
printf "         PART - IV - Extracting MariaDB tar file and creating the data directory       \n";
printf "=======================================================================================\n";

echo ">>> Installing MariaDB Database $VERSION ..... "

#cmd1=`sudo wget -c --limit-rate=2G --directory-prefix=/usr/local https://archive.mariadb.org//mariadb-${VERSION}/bintar-linux-x86_64/mariadb-${VERSION}-linux-x86_64.tar.gz && sudo tar -xzf /usr/local/mariadb-${VERSION}-linux-x86_64.tar.gz -C /usr/local/ ; echo $?`

#cmd2=`sudo wget -c --limit-rate=2G --directory-prefix=/usr/local https://mirror.rackspace.com/mariadb//mariadb-${VERSION}/bintar-linux-x86_64/mariadb-${VERSION}-linux-x86_64.tar.gz && sudo tar -xzf /usr/local/mariadb-${VERSION}-linux-x86_64.tar.gz -C /usr/local/ ;echo $?`

sudo wget -c --limit-rate=2G --directory-prefix=/usr/local https://mirror.rackspace.com/mariadb//mariadb-${VERSION}/bintar-linux-x86_64/mariadb-${VERSION}-linux-x86_64.tar.gz && sudo tar -xzf /usr/local/mariadb-${VERSION}-linux-x86_64.tar.gz -C /usr/local/

echo ">>>>>>> The selected MariaDB version is $VERSION <<<<<<<"

MARIADB_VERSION='$VERSION'

echo "Extracting MariaDB Tarball....."

echo "Tarball unpacked....."

cd /usr/local
ln -s mariadb-${VERSION}-linux-x86_64 mysql

echo "Database Initialization has been started.. Installing it now...."

su - mysql <<EOF
cd /usr/local/mysql
#sudo ./scripts/mysql_install_db --user=mysql --datadir=/mariadb/data
sudo ./scripts/mysql_install_db --user=mysql --datadir=/home/data
EOF
}

environment_set () {
echo
echo
printf "======================================================================================\n";
printf "         PART - V -  Environment Variable Set for mysql as a OS mysql user            \n";
printf "======================================================================================\n";

su - mysql <<EOF
echo 'export PATH=/usr/local/mysql/bin:$PATH' >> ~/.bashrc; . ~/.bashrc
mysql --version ; exit
EOF
}

configuration_file () {
echo
echo
printf "======================================================================================\n";
printf "         PART - VI -  my.cnf file configuration                                       \n";
printf "======================================================================================\n";

#echo -e "line3\n line4\n line5\n" >> file.txt

FILE=/etc/my.cnf
if [ -f "$FILE" ]; then
{
cp -p /etc/my.cnf /tmp/my.cnf_org
#echo '[client]\n new line' > /etc/my.cnf
#echo -e "[client]\nport=3306\nsocket=/home/data/mysql.sock\n  [mysqld]\n" >> /etc/my.cnf
#echo 'port=3306' >> /etc/my.cnf
echo '[client]' > /etc/my.cnf
echo 'port = 3306' >> /etc/my.cnf
#echo 'socket = /mariadb/data/mysql.sock' >> /etc/my.cnf
echo 'socket = /home/data/mysql.sock' >> /etc/my.cnf
echo >> /etc/my.cnf
#echo >> /etc/my.cnf
echo '[mysqld]' >> /etc/my.cnf
#echo 'datadadir = /mariadb/data' >> /etc/my.cnf
#echo 'socket = /mariadb/data/mysql.sock' >> /etc/my.cnf
echo 'server_id = 1' >> /etc/my.cnf
echo 'datadir = /home/data' >> /etc/my.cnf
echo 'socket = /home/data/mysql.sock' >> /etc/my.cnf
echo 'user = mysql' >> /etc/my.cnf
echo 'bind-address = 0.0.0.0' >> /etc/my.cnf
echo 'innodb_file_per_table = 1' >> /etc/my.cnf
#echo 'log-error = /mariadb/data/mysqld.log' >> /etc/my.cnf
#echo 'pid-file = /mariadb/data/mysqld.pid' >> /etc/my.cnf
echo 'log-error = /home/data/mysqld.log' >> /etc/my.cnf
echo 'pid-file = /home/data/mysqld.pid' >> /etc/my.cnf
echo 'default_storage_engine=innodb' >> /etc/my.cnf
echo '#enforce_innodb_engine = Innodb  ##remove this parameter to avoid the error "ERROR 1286 (42000): Unknown storage engine 'partition'" when creating index' >> /etc/my.cnf
echo 'performance_schema = ON' >> /etc/my.cnf
echo 'max_connections = 300 #(adjust based on requirement)' >> /etc/my.cnf
echo 'innodb_log_file_size = 512M' >> /etc/my.cnf
#echo 'innodb_buffer_pool_size = 10GB #(adjust based on requirement)' >> /etc/my.cnf
echo 'innodb_buffer_pool_size = 512M #(adjust based on requirement)' >> /etc/my.cnf
echo 'sync_binlog = 1' >> /etc/my.cnf
#echo 'log_bin = /mariadb/binlog/mysql-bin.log' >> /etc/my.cnf
echo 'log_bin = /home/binlog/mysql-bin.log' >> /etc/my.cnf
echo '#log-bin-index = /mysql/binlog' >> /etc/my.cnf
echo 'query_cache_type = 0' >> /etc/my.cnf
echo 'query_cache_size = 0' >> /etc/my.cnf
echo 'lower_case_table_names = 1'  >> /etc/my.cnf
echo 'character_set_server = utf8mb4'  >> /etc/my.cnf
echo 'collation_server = utf8mb4_unicode_520_ci'  >> /etc/my.cnf
echo 'max_allowed_packet = 1024M'  >> /etc/my.cnf
}
else
{
#echo '[client]\n new line' > /etc/my.cnf
#echo -e "[client]\nport=3306\nsocket=/home/data/mysql.sock\n  [mysqld]\n" >> /etc/my.cnf
#echo 'port=3306' >> /etc/my.cnf
echo '[client]' > /etc/my.cnf
echo 'port = 3306' >> /etc/my.cnf
#echo 'socket = /mariadb/data/mysql.sock' >> /etc/my.cnf
echo 'socket = /home/data/mysql.sock' >> /etc/my.cnf
echo >> /etc/my.cnf
#echo >> /etc/my.cnf
echo '[mysqld]' >> /etc/my.cnf
#echo 'datadir = /mariadb/data' >> /etc/my.cnf
#echo 'socket = /mariadb/data/mysql.sock' >> /etc/my.cnf
echo 'server_id = 1' >> /etc/my.cnf
echo 'datadir = /home/data' >> /etc/my.cnf
echo 'socket = /home/data/mysql.sock' >> /etc/my.cnf
echo 'user = mysql' >> /etc/my.cnf
echo 'bind-address = 0.0.0.0' >> /etc/my.cnf
echo 'innodb_file_per_table = 1' >> /etc/my.cnf
#echo 'log-error = /mariadb/data/mysqld.log' >> /etc/my.cnf
#echo 'pid-file = /mariadb/data/mysqld.pid' >> /etc/my.cnf
echo 'log-error = /home/data/mysqld.log' >> /etc/my.cnf
echo 'pid-file = /home/data/mysqld.pid' >> /etc/my.cnf
echo 'default_storage_engine = innodb' >> /etc/my.cnf
echo '#enforce_innodb_engine = Innodb  ##remove this parameter to avoid the error "ERROR 1286 (42000): Unknown storage engine 'partition'" when creating index' >> /etc/my.cnf
echo 'performance_schema = ON' >> /etc/my.cnf
echo 'max_connections = 300 #(adjust based on requirement)' >> /etc/my.cnf
echo 'innodb_log_file_size = 512M' >> /etc/my.cnf
#echo 'innodb_buffer_pool_size = 10GB #(adjust based on requirement) ' >> /etc/my.cnf
echo 'innodb_buffer_pool_size = 512M #(adjust based on requirement)' >> /etc/my.cnf
echo 'sync_binlog = 1' >> /etc/my.cnf
#echo 'log_bin = /mariadb/binlog/mysql-bin.log' >> /etc/my.cnf
echo 'log_bin = /home/binlog/mysql-bin.log' >> /etc/my.cnf
echo '#log-bin-index = /mysql/binlog' >> /etc/my.cnf
echo 'query_cache_type = 0' >> /etc/my.cnf
echo 'query_cache_size = 0'  >> /etc/my.cnf
echo 'lower_case_table_names = 1'  >> /etc/my.cnf
echo 'character_set_server = utf8mb4'  >> /etc/my.cnf
echo 'collation_server = utf8mb4_unicode_520_ci'  >> /etc/my.cnf
echo 'max_allowed_packet = 1024M'  >> /etc/my.cnf
}
fi
}

auto_start_mysql () {
echo
echo
printf "======================================================================================\n";
printf "         PART - VII - Enabling MariaDB Auto Start script in OS level                  \n";
printf "======================================================================================\n";

echo "Enabling MariaDB Database Auto start after reboot the OS server ......."

sudo cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
sudo chmod +x /etc/init.d/mysql
sudo chkconfig --add mysql
sudo chkconfig --list
sudo chkconfig --level 345 mysql on
sudo chkconfig --level 2 mysql off

}

mariadb_start () {
echo
echo
printf "======================================================================================\n";
printf "         PART - VIII -  Start the MariaDB Service                                     \n";
printf "======================================================================================\n";

service mysql start

ps -ef|grep mysql|grep mysql.sock|grep -v grep

if [ $? -eq 0 ]
then
  echo "MYSQL Process Check OK"
else
#echo "MYSQL is Not Running .... Starting" | mailx -s "MySQL on `hostname` is not running..... STARTING NOW .... " test123@gmail.com
  echo "MariaDB Process is not Running......."
 fi
}

mysql_secure () {
echo
echo
printf "=======================================================================================================\n";
printf "      PART - IX -  Setting the DB super user password by using mysql_secure_installation utility       \n";
printf "=======================================================================================================\n";

echo 'export PATH=/usr/local/mysql/bin:$PATH' >> ~/.bashrc; . ~/.bashrc <<EOF
mysql --version
EOF

      MYSQL_ROOT_PASSWORD='3tbmchr'
      SECURE_MYSQL=$(expect -c "

      set timeout 10
      spawn mysql_secure_installation -S /home/data/mysql.sock
#spawn mysql_secure_installation -S /mariadb/data/mysql.sock

      expect \"Enter current password for root(enter for none):\"
      #send \"\r\"
      send \"none\r\"

      expect \"Switch to unix_socket authentication \(Press y\|Y for Yes, any other key for No\) \"
      send \"n\r\"

      expect \"Change the root password? \(Press y\|Y for Yes, any other key for No\) :\"
      send \"y\r\"

      expect \"New password:\"
      send \"$MYSQL_ROOT_PASSWORD\r\"

      expect \"Re-enter new password:\"
      send \"$MYSQL_ROOT_PASSWORD\r\"

#expect \"Do you wish to continue with the password provided? \(Press y\|Y for Yes, any other key for No\) :\"
#send \"y\r\"

      expect \"Remove anonymous users? \(Press y\|Y for Yes, any other key for No\) :\"
      send \"y\r\"

      expect \"Disallow root login remotely?\(Press y\|Y for Yes, any other key for No\) :\"
      send \"y\r\"

      expect \"Remove test database and access to it? \(Press y\|Y for Yes, any other key for No\) :\"
      send \"y\r\"

      expect \"Reload privilege tables now?\ (Press y\|Y for Yes, any other key for No\) :\"
      send \"y\r\"

      expect eof
      ")

      echo "$SECURE_MYSQL"
}


validation () {
echo
echo
printf "======================================================================================\n";
printf "         PART - X -  Databae Validation with MariaDB Commands !!!!!                   \n";
printf "======================================================================================\n";

MYSQL_ROOT_PASSWORD='3tbmchr'

mysql -u root -p$MYSQL_ROOT_PASSWORD -e "STATUS ; SELECT @@VERSION ,@@VERSION_COMMENT ,@@VERSION_MALLOC_LIBRARY; SHOW VARIABLES LIKE 'datadir';  SHOW VARIABLES LIKE '%char%'; SHOW VARIABLES LIKE '%collat%';  SHOW VARIABLES LIKE 'pid_file';  SHOW VARIABLES LIKE 'socket';  SHOW VARIABLES LIKE 'server_id';  SHOW VARIABLES LIKE 'binlog_format';  SHOW VARIABLES LIKE 'log_bin'; SELECT USER,HOST,AUTHENTICATION_STRING FROM mysql.user;  SHOW DATABASES; SHOW VARIABLES LIKE 'performance_schema'; "

}

metadata_plugin_installation () {

                      printf "##########################################################################\n";
                      printf "                                                                          \n";
                      printf "              (2)  Metadata_lock_info plugin Installation !!!!            \n";
                      printf "                                                                          \n";
                      printf "##########################################################################\n";

MYSQL_ROOT_PASSWORD='3tbmchr'

if [ $(mysql -N -s -u root -p$MYSQL_ROOT_PASSWORD -e "select count(*) from information_schema.tables where table_schema='information_schema' and table_name='metadata_lock_info';") -eq 1 ]; then
   echo "Table exist"
else
  echo "Table 'metadata_lock_info' does not exist .... Installaing !!!!! "
   mysql -u root -p$MYSQL_ROOT_PASSWORD -e "INSTALL SONAME 'metadata_lock_info'; DESC INFORMATION_SCHEMA.metadata_lock_info; SELECT * FROM mysql.plugin; SELECT * FROM INFORMATION_SCHEMA.metadata_lock_info; "
  exit 1
fi

}

echo

time_zone_info_deploy () {

                     printf "#################################################################################\n";
                     printf "                                                                                 \n";
                     printf "         (3)  time_zone_info Meta Database Deployment in mysql schema            \n";
                     printf "                                                                                 \n";
                     printf "#################################################################################\n";

MYSQL_ROOT_PASSWORD='3tbmchr'

mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT @@GLOBAL.time_zone, @@SESSION.time_zone; SELECT COUNT(1) FROM mysql.time_zone_name; select DATE_FORMAT(CONVERT_TZ(FROM_UNIXTIME(unix_timestamp()), 'GMT', 'Europe/Dublin'), '%Y%u'); "

mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root -p$MYSQL_ROOT_PASSWORD mysql

mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT @@GLOBAL.time_zone, @@SESSION.time_zone; select count(1) from mysql.time_zone_name; select DATE_FORMAT(CONVERT_TZ(FROM_UNIXTIME(unix_timestamp()), 'GMT', 'Europe/Dublin'), '%Y%u');"

}

case ${INPUT_STRING} in

# Invoke your function

(1)

mysql_os_group_user_creation
echo "*********************************** OS User and OS Group Creation has been completed **********************************"
echo

dependency_packages
echo " ********************************** Dependency Packages has been completed ********************************************"
echo

mariadb_mount_point_check
echo " ********************************** $mount_point is Available in File System and this steps is Completed **************"
echo

data_directory_creation
echo " ********************************** MariaDB Data Directory has been completed ********************************************"
echo

extract_software_install_mariadb
echo "********************************** MariaDB Database has been installed **************"
echo

environment_set
echo "*************** Environment variables has been configured as a mysql and as a root OS user's **************"
echo

configuration_file
echo "*********** MariaDB configuration File is ready in $FILE  ************"
echo

auto_start_mysql
echo "*********** Enabling MariaDB Database Auto start after reboot the OS server has been Completed !!!!! ************"
echo

mariadb_start
echo "*********** MariDB Service is up and running !!!!!!! ************"
echo

mysql_secure
echo "*********** MariaDB Super user password has been set ..... Ready to Database connections !!!!!!!! ************"
echo

validation
echo "*********** Database Validation step has been completed ************"
echo "End of script for MariaDB Database Installation  !!!!!!!!!!!!"
echo

exit ${RC}
;;

(2)

metadata_plugin_installation
echo "********* Metadata_lock_info plugin Installation has been completed !!!! ************"
echo "End of script for INSTALL Metadata_lock_info Plugin !!!!!!!!!!!!"

exit ${RC}
;;

(3)

time_zone_info_deploy
echo "*********** mysql.time_zone_name  has been completed ************"
echo "End of script for time_zone_name Meta Database Deployment !!!!!!!!!!!!"

exit ${RC}
;;

*)
       echo " Sorry I didnt understand, plese choose correct option"

esac

