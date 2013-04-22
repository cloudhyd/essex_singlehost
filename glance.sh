#!/bin/bash
# OK Tested fine
#Endpoints on Local Loop : 127.0.0.1
#########################################################################################################
#                                                                                                       #
#  The Scripts were created to simlipyfy the Openstack Installation for General Users.                  #
#                                                                                                       #
#  Created Date : 26 March 2013                                                                         #
#                                                                                                       #
#  Created By : Shivaram Y & Shyam Y                                                                    #
#                                                                                                       #
#  Support Gorups : Cloudconverge & Cloudhyd                                                            #
#                                                                                                       #
#  Email: yshivaram@yahoo.com & yedurushyam@hotmail.com                                                 #
#                                                                                                       #
#########################################################################################################

LOG_FILE=cloudhyd_opinstallation.log
#################################################################
function Instcheck() {
clear
if [ -f /etc/InstInfo.env ]; then
echo " Checking /etc/InstInfo.env file ">>$LOG_FILE
if [ -d /etc/keystone ]; then
echo " /etc/InstInfo.env file available ">>$LOG_FILE
echo " Checking /etc/keystone directory ">>$LOG_FILE
else
echo ""
echo "Keystone was not installed, Install it with ./keystone.sh script "
echo " Keystone was not installed ">>$LOG_FILE
echo " Exiting  ">>$LOG_FILE
echo " "
exit 1
fi
else
echo;
echo " Start Installation with Installation script by ./install.sh script"
echo "Start Installation with Installation script by ./install.sh script  ">>LOG_FILE
echo " Exiting  ">>$LOG_FILE
exit 1
fi
}

function check_root() {
. /etc/InstInfo.env
echo " Starting Installation of Openstack module '$0' `date` ">> $LOG_FILE
echo "Checking User  " >>$LOG_FILE
echo "Checking User  " 
echo "  "
sleep 1
if [ "$(id -u)" != "0" ]; then
echo "User is not root " >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands "  >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands " 1>&2
echo " "
else
echo "User is Root Process started" >>$LOG_FILE
echo "User is Root Process started" 
echo " "
fi
 }

function check_mysql_pass() {
. /etc/InstInfo.env
echo "exit" >test.sql
/usr/bin/mysql -u root -p$MYSQL_PASSWD <test.sql
if [ "$?" -eq 0 ]; then
echo " Mysql OK " >>$LOG_FILE
rm -rf test.sql
else
read -p "Enter MySql Root Password : " TTMYSQL_P
/usr/bin/mysql -u root -p$TTMYSQL_P
if [ "$?" -eq 0 ]; then
echo " Mysql Password is OK " >>$LOG_FILE
echo " Mysql Password is OK "
MYSQL_PASSWD=$TTMYSQL_P
echo " Mysql password changed " >> /etc/InstInfo.env
cat >> /etc/InstInfo.env <<EOF
export MYSQL_PASSWD=$TTMYSQL_P
EOF
/bin/chmod +x /etc/InstInfo.env
rm -rf test.sql
else
echo "check mysql password and try again" >>$LOG_FILE
echo "check mysql password and try again"
exit 1
fi
fi
}

function glance_mysql() {
. /etc/InstInfo.env
echo " Started glance_mysql " >>$LOG_FILE
check_mysql_pass
function prpass() {
echo " Started prpass " >>$LOG_FILE
echo " Using 'glance' as a glance image service user for services and mysql"
read -p "Please  Enter New the Password for Glance User  : " mysqlusr_pass1
read -p "Please  Re-Enter the Password for for Glance User : " mysqlusr_pass2
if [ "$mysqlusr_pass1" == "$mysqlusr_pass2" ]; then
GLANCE_MYSQL_PASS=$mysqlusr_pass2
cat >> /etc/InstInfo.env <<EOF
export GLANCE_MYSQL_PASS=$mysqlusr_pass2
EOF
echo " exported glance passwd " >>$LOG_FILE
echo " "
fi
}
prpass
if [ "$mysqlusr_pass1" == "$mysqlusr_pass2" ]; then
echo " "
else
mysqlusr_pass1="x"
mysqlusr_pass2="xx"
echo " "
echo " Both passwords are not same, Enter again " >>$LOG_FILE
echo " Both passwords are not same, Enter again "
echo " "
prpass
fi

echo " Creating Glance Database & Granting Permissions to Glance user " >>$LOG_FILE
echo " Creating Glance Database & Granting Permissions to Glance user "
echo " .... "
mysql -u root -p$MYSQL_PASSWD <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$GLANCE_MYSQL_PASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$GLANCE_MYSQL_PASS';
FLUSH PRIVILEGES;
EOF
if [ "$?" -ne "0" ]; then
echo " Error Creating glance user in mysql " >>$LOG_FILE
echo " Error Creating glance user in mysql "
exit 1
else
echo " glance user created in mysql " >>$LOG_FILE
echo " glance user created in mysql "
fi
}

function create_glancedata() {
. /etc/InstInfo.env
echo " Creating Glance Data ">>$LOG_FILE
sleep 5
export ADMIN_TENANT=$(keystone tenant-list | grep "admin" | awk '{print $2}')
sleep 1
if [ -n "$ADMIN_TENANT" ];then
echo "ADMIN_TENANT=$ADMIN_TENANT">>$LOG_FILE
else
echo "ADMIN_TENANT=$ADMIN_TENANT">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

export SERVICE_TENANT=$(keystone tenant-list | grep "service" | awk '{print $2}')
sleep 1
if [ -n "$SERVICE_TENANT" ];then
echo "SERVICE_TENANT=$SERVICE_TENANT">>$LOG_FILE
else
echo "SERVICE_TENANT=$SERVICE_TENANT">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

sleep 1
export ADMIN_ROLE=$(keystone role-list | grep "admin" | awk '{print $2}')
if [ -n "$ADMIN_ROLE" ];then
echo "ADMIN_ROLE=$ADMIN_ROLE">>$LOG_FILE
else
echo "ADMIN_ROLE=$ADMIN_ROLE">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Glance User for Keystone Identity Service">>$LOG_FILE
echo " Creating Glance User for Keystone Identity Service"
sleep 1
export GLANCE_USER=$(keystone user-create --name=glance --pass="$GLANCE_MYSQL_PASS" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$GLANCE_USER" ];then
echo "GLANCE_USER=$GLANCE_USER">>$LOG_FILE
else
echo "GLANCE_USER=$GLANCE_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " "
echo " Adding Role to Glance User ">>$LOG_FILE
echo " Adding Role to Glance User "
keystone user-role-add --user $GLANCE_USER --role $ADMIN_ROLE --tenant_id $SERVICE_TENANT
keystone user-role-add --user $GLANCE_USER --role $ADMIN_ROLE --tenant_id $ADMIN_TENANT
sleep 1
echo "GLANCE_USER -- ADMIN_ROLE -- SERVICE_TENANT ">>$LOG_FILE

echo " Creating Glance Service in Keystone Identity Service ">>$LOG_FILE
echo " Creating Glance Service in Keystone Identity Service "
sleep 1
export GLANCE_IMGSER=$(keystone service-create --name glance --type image --description 'OpenStack Image Service'| awk '/ id / { print $4 }')
if [ -n "$GLANCE_IMGSER" ];then
echo "GLANCE_IMGSER=$GLANCE_IMGSER ">> $LOG_FILE
echo "Created Glance Image Service ">> $LOG_FILE
else
echo " Error Creating Glance Image Service " >>$LOG_FILE
echo " Error Creating Glance Image Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Glance Service End Point ">>$LOG_FILE
echo "Creating Glance Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $GLANCE_IMGSER --publicurl 'http://'"$MASTER_IP"':9292/v1' --adminurl 'http://'"$MASTER_IP"':9292/v1' --internalurl 'http://'"$MASTER_IP"':9292/v1'
if [ "$?" -eq "0" ]; then
echo "Created Glance Service End Point ">> $LOG_FILE
else
echo "Error Creating Glance Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
echo " Glance Data created sucessfully ">> $LOG_FILE
echo " Glance Data created sucessfully "
echo "Glance Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Glance Configurations in Keystone Identity Service Completed"

}
###################################################################################################
function Install_glance() {
if [ -d /etc/glance ]; then
echo "Glance Image  Service already Installed " >>$LOG_FILE
echo "Glance Image  Service already Installed "
exit 1
else
echo "Installing Glance Image Service" >>$LOG_FILE
echo "Installing Glance Image Service"
echo "Downdloaing Glance Image Service Packages from internet" >>$LOG_FILE
echo "Downdloaing Glance Image Service Packages from internet"
sleep 2
echo ""
echo ""
apt-get install -y glance glance-api glance-client glance-common glance-registry python-glance
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Glance Image  Service is completed" >>$LOG_FILE
echo " Installation of Glance Image  Service is completed"
else
echo ""
echo ""
echo " Error Installing Glance Image  Service" >>$LOG_FILE
echo " Error Installing Glance Image  Service"
exit 1
fi
fi

}

function config_glance() {
. /etc/InstInfo.env
echo "Configuring Glance Image  Service" >>$LOG_FILE
echo "Configuring Glance Image  Service"
echo " "
echo " Making Backup of files " >>$LOG_FILE
echo " Making Backup of files "
   cp /etc/glance/glance-api-paste.ini /etc/glance/glance-api-paste.ini.bkp
   cp /etc/glance/glance-registry-paste.ini /etc/glance/glance-registry-paste.ini.bkp
   cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.conf.bkp
   cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bkp
echo " "
echo " Modifying the Glance Configaration files " >>$LOG_FILE
echo " Modifying the Glance Configaration files "
echo "Modifying /etc/glance/glance-api-paste.ini " >>$LOG_FILE
sleep 1
#s,%SERVICE_TENANT_NAME%,admin,g;
sed -e "
   s,%SERVICE_TENANT_NAME%,service,g;
   s,%SERVICE_USER%,glance,g;
   s,%SERVICE_PASSWORD%,$GLANCE_MYSQL_PASS,g;
   " -i /etc/glance/glance-api-paste.ini

if [ "$?" -eq 0 ]; then
echo "Modified /etc/glance/glance-api-paste.ini " >>$LOG_FILE
else
echo "Error in Modifying /etc/glance/glance-api-paste.ini" >>$LOG_FILE
echo "Error in Modifying /etc/glance/glance-api-paste.ini"
echo "exiting " >>$LOG_FILE
exit 1
fi

echo "Modifying /etc/glance/glance-registry-paste.ini" >>$LOG_FILE
sleep 1
sed -e "
   s,%SERVICE_TENANT_NAME%,service,g;
   s,%SERVICE_USER%,glance,g;
   s,%SERVICE_PASSWORD%,$GLANCE_MYSQL_PASS,g;
   " -i /etc/glance/glance-registry-paste.ini
if [ "$?" -eq 0 ]; then
echo "Modified /etc/glance/glance-registry-paste.ini" >>$LOG_FILE
else
echo "Error in Modifying /etc/glance/glance-registry-paste.ini" >>$LOG_FILE
echo "Error in Modifying /etc/glance/glance-registry-paste.ini"
echo "exiting " >>$LOG_FILE
exit 1
fi


echo "Modifying /etc/glance/glance-registry.conf" >>$LOG_FILE
sleep 1
sed -e "
   /^sql_connection =.*$/s/^.*$/sql_connection = mysql:\/\/glance:$GLANCE_MYSQL_PASS@$MASTER:3306\/glance/
   " -i /etc/glance/glance-registry.conf
echo "
[paste_deploy]
flavor = keystone
" >> /etc/glance/glance-registry.conf

if [ "$?" -eq 0 ]; then
echo "Modified /etc/glance/glance-registry.conf" >>$LOG_FILE
else
echo "Error in Modifying /etc/glance/glance-registry.conf" >>$LOG_FILE
echo "Error in Modifying /etc/glance/glance-registry.conf"
echo "exiting " >>$LOG_FILE
exit 1
fi

echo "Modifying /etc/glance/glance-api.conf" >>$LOG_FILE
sleep 1
echo "
[paste_deploy]
flavor = keystone
" >> /etc/glance/glance-api.conf
#sed -i '/^notifier_strategy/s/noop/rabbit/g' /etc/glance/glance-api.conf
#sed -i '/^rabbit_password/s/guest/$RabbitMQ_PASS/g' /etc/glance/glance-api.conf
if [ "$?" -eq 0 ]; then
echo "Modified /etc/glance/glance-api.conf" >>$LOG_FILE
else
echo "Error in Modifying /etc/glance/glance-api.conf" >>$LOG_FILE
echo "Error in Modifying /etc/glance/glance-api.conf" 
echo "exiting " >>$LOG_FILE
exit 1
fi
echo ""
echo "Completed Configuration of Glance Image  Service" >>$LOG_FILE
echo "Completed Configuration of Glance Image  Service"
echo ""
}

function glance_version_db() {
echo "Creating Glance Image  DB" >>$LOG_FILE
echo "Creating Glance Image  DB"
echo ""
glance-manage version_control 0

if [ "$?" -eq 0 ]; then
echo "  Glance Image  Database Version Control done " >>$LOG_FILE
else
echo " Error Creating Glance Image  Database Version Control" >>$LOG_FILE
echo "exiting " >>$LOG_FILE
exit 1
fi

glance-manage db_sync
if [ "$?" -ne 0 ]; then
echo " Error Creating Glance Image  Database " >>$LOG_FILE
echo " Error Creating Glance Image  Database "
exit 1
else 
echo "  Glance Image  Database Created " >>$LOG_FILE
echo "  Glance Image  Database Created "
fi

echo ""
echo "Restarting the glance service" >>$LOG_FILE
echo "Restarting the glance service"
service glance-api restart && service glance-registry restart
if [ "$?" -ne 0 ]; then
echo " error Restarting  glance Service " >>$LOG_FILE
echo " error Restarting  glance Service "
exit 1
else 
sleep 4
echo " Glance Image  Service Restarted " >>$LOG_FILE
echo " Glance Image  Service Restarted "
fi

}

function image_upload() {
. /etc/InstInfo.env
echo "Now we will download the cirros image  with wget http://cloudhyd.com/openstack/images/cirros-0.3.0-x86_64-disk.img"
echo "You can download more images from http://cloudhyd.com/openstack/images "
echo ""
echo ""
sleep 4
echo "Checking for local images in images folder "
if [ -f images/cirros-0.3.0-x86_64-disk.img ]; then
echo "Image located and uploading to glance "
glance add name="cirros 64bit disk " is_public=true container_format=ovf disk_format=qcow2 <./images/cirros-0.3.0-x86_64-disk.img
else
echo "Downloading http://cloudhyd.com/openstack/images/cirros-0.3.0-x86_64-disk.img " >>$LOG_FILE
wget http://cloudhyd.com/openstack/images/cirros-0.3.0-x86_64-disk.img
if [ "$?" -ne 0 ]; then
echo " error Downloading Image file from http://cloudhyd.com/openstack/images, Check Internet connection " >>$LOG_FILE
echo " error Downloading Image file from http://cloudhyd.com/openstack/images, Check Internet connection "
exit 1
else
glance add name="cirros 64bit disk " is_public=true container_format=ovf disk_format=qcow2 <cirros-0.3.0-x86_64-disk.img
if  [ "$?" -eq 0 ]; then
echo " cirros 64bit disk Added to Glance Image Service " >>$LOG_FILE
echo " cirros 64bit disk Added to Glance Image Service "
echo " Glance Image Service Installtion Completed "
else
echo "Error Adding cirros 64bit disk to Glance Image Service " >>$LOG_FILE
echo "Error Adding cirros 64bit disk to Glance Image Service "
fi
fi
fi
}

function Remove_glance() {
apt-get remove -y  glance glance-api glance-client glance-common glance-registry python-glance
if [ "$?" -eq 0 ]; then
echo "Uninstallation of Glance Image  Service Packages Completed">>$LOG_FILE
echo "Uninstallation of Glance Image  Service Packages Completed"
echo " "
else
echo " Error in Uninstalling Glance Image  Service ">>$LOG_FILE
echo " Error in Uninstalling Glance Image  Service "
exit 1
fi

echo "Uninstalling Dependancey packages"
echo " "
sleep 1
apt-get -y  autoremove
if [ "$?" -eq 0 ]; then
echo "Uninstallation of  Dependancey packages Completed">>$LOG_FILE
echo "Uninstallation of Dependancey packages Completed"
echo " "
else
echo " Error in Uninstalling Dependancey packages">>$LOG_FILE
echo " Error in Uninstalling Dependancey packages"
exit 1
fi
echo " Removing the Traces of Glance Image  Service ">>$LOG_FILE
echo " Removing the Traces of Glance Image  Service "
/usr/bin/updatedb
/usr/bin/locate glance | /bin/grep "/etc/" | /usr/bin/awk '{ print "rm -rf  "$1 }' > tmp.file
/usr/bin/locate glance | /bin/grep "/var/" | /usr/bin/awk '{ print "rm -rf  "$1 }' >> tmp.file
/bin/sh tmp.file
rm -rf tmp.file
}


####################################################################
function banner() {
echo ""
echo " "
echo " Glance is used to  provides services for discovering, registering, and retrieving virtual machine images by projects in the OpenStack"
echo ""
echo " "
sleep 2
}

function banner_end() {
echo "#################################################################################################"
echo " Glance Image Service Installtion COmpleted "
echo "Its time to test the Glance
      execute  '. ./OpenStack.env' for setting environment variables
      issue the commands to test glance 'glance index ', where in you can view the details of image"
echo "Installation of Glance Image  completed Now Upload Images then Install Nova with nova.sh file"
echo "#################################################################################################"
}
if [ "$1" == "remove" ]; then
echo "Uninstalling Glance Image  Service ">>$LOG_FILE
echo "Uninstalling Glance Image  Service "
echo " "
sleep 1
check_root
mysql -u root -p$MYSQL_PASSWD <<EOF
DROP DATABASE glance;
FLUSH PRIVILEGES;
EOF
sed '/GLANCE_MYSQL_PASS/d' -i  /etc/InstInfo.env
Remove_glance
echo " Uninstallation  of Glance Image  Service Completed "
elif  [ "$1" == "onlydata" ]; then
banner
Instcheck
check_root
create_glancedata
echo "Installation of Glance Data in Keystone completed"
elif  [ "$1" == "fullinstall" ]; then
banner
Instcheck
check_root
check_mysql_pass
glance_mysql
Install_glance
config_glance
glance_version_db
create_glancedata
image_upload
banner_end
elif  [ "$1" == "alldata" ]; then
banner
Instcheck
check_root
check_mysql_pass
glance_mysql
create_glancedata
elif  [ "$1" == "nodata" ]; then
banner
Instcheck
check_root
check_mysql_pass
glance_mysql
Install_glance
config_glance
glance_version_db
elif  [ "$1" == "install" ]; then
banner
Instcheck
check_root
check_mysql_pass
glance_mysql
Install_glance
config_glance
glance_version_db
create_glancedata
banner_end
elif  [ "$1" == "imageonly" ]; then
image_upload
else 
echo " 
usage: ./glance.sh option
options: 

fullinstall: Install & Configuration along with mysql data, keystone data and image upload

install: Install & Configuration along with mysql data, keystone data, 'No images will be uploaded'

remove : Uninstallation of Glance except keystone data 

onlydata : Installation of Glance keystone data 

alldata : Installation of Glance,mysql & keystone data 

imageonly : Upload default Cirros 64bit image for testing

nodata : Install & Configuration of Glance only  with mysql data ( no keystone data ) 

eg: ./glance.sh install
" 
fi
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

