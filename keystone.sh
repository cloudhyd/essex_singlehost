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
echo " Checking /etc/InstInfo.env file ">>$LOG_FILE
if [ -f /etc/InstInfo.env ]; then
echo " /etc/InstInfo.env file is present ">>$LOG_FILE
else
echo ""
echo " Start Installation with Installation script by ./install.sh script"
echo "Start Installation with Installation script by ./install.sh script  ">>$LOG_FILE
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
###################################################################################################
function get_details() {
echo " "
echo " "
echo " "
echo " Using get_details " >> $LOG_FILE
read -p "Enter a New Authorization Token (Service Token ) for the OpenStack services  : " service_token
echo "Using 'admin' as a administrator for the OpenStack services " 
read -p "Enter the New Password for 'admin' user : " password1
read -p "ReEnter the Password for 'admin' user : " password2
echo " "
echo " "
if [ "$password1" == "$password2" ]; then
echo "Admin Password ok  " >>$LOG_FILE
password=$password1
else
echo " Both passwords are not same, Enter again " >>$LOG_FILE
echo " Both passwords are not same, Enter again "
exit 1
fi

echo " Appending Install env file  " >> $LOG_FILE
cat >> /etc/InstInfo.env <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$password
export OS_AUTH_URL="http://127.0.0.1:5000/v2.0/"
export ADMIN_PASSWORD=$password
export SERVICE_PASSWORD=$password
export SERVICE_TOKEN=$service_token
export SERVICE_ENDPOINT="http://127.0.0.1:35357/v2.0"
export ADMIN_TENANT_NAME=admin
export SERVICE_TENANT_NAME=service
export MASTER_IP=127.0.0.1
export KEYSTONE_REGION=RegionOne
EOF
if [ "$?" -eq 0 ]; then
echo " Appeded Install env File " >>$LOG_FILE 
else
echo "Failed  Appeding Install env File " >>$LOG_FILE
echo "Failed  Appeding Install env File "
exit 1
fi

cat > OpenStack.env <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$password
export OS_AUTH_URL="http://127.0.0.1:5000/v2.0/"
export ADMIN_PASSWORD=$password
export SERVICE_PASSWORD=$password
export SERVICE_TOKEN=$service_token
export SERVICE_ENDPOINT="http://127.0.0.1:35357/v2.0"
export SERVICE_TENANT_NAME=service
export ADMIN_TENANT_NAME=admin
EOF
if [ "$?" -eq 0 ]; then
echo " Appeded User env File " >>$LOG_FILE 
else
echo "Failed  Appeding User env File " >>$LOG_FILE
echo "Failed  Appeding User env File "
exit 1
fi
/bin/chmod +x /etc/InstInfo.env
/bin/chmod +x OpenStack.env
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

function keystone_mysql() {
echo " Started keystone_mysql " >>$LOG_FILE
check_mysql_pass
function prpass() {
echo " Started prpass " >>$LOG_FILE
echo " Using 'keystone' as a keystone service user for services and mysql"
read -p "Please Enter  New  Password for Keystone User  : " mysqlusr_pass1
read -p "Please  Re-Enter the Password for for Keystone User : " mysqlusr_pass2
if [ "$mysqlusr_pass1" == "$mysqlusr_pass2" ]; then
read -p "Enter the email address for keystone service account : " email
KEYSTONE_MYSQL_PASS=$mysqlusr_pass2
cat >> /etc/InstInfo.env <<EOF
export KEYSTONE_MYSQL_PASS=$mysqlusr_pass2
export EMAIL=$email
EOF
echo " exported keystone passwd " >>$LOG_FILE
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

echo " Creating Keystone Database & Granting Permissions to keystone user " >>$LOG_FILE
echo " Creating Keystone Database & Granting Permissions to keystone user "
echo " .... "
mysql -u root -p$MYSQL_PASSWD <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_MYSQL_PASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_MYSQL_PASS';
FLUSH PRIVILEGES;
EOF
if [ "$?" -ne "0" ]; then
echo " Error Creating keystone user in mysql " >>$LOG_FILE
echo " Error Creating keystone user in mysql "
exit 1
else
echo " keystone user created in mysql " >>$LOG_FILE
echo " keystone user created in mysql "
fi
}

function Install_keystone() {
if [ -d /etc/keystone ]; then
echo "Keystone Service already Installed " >>$LOG_FILE
echo "Keystone Service already Installed "
exit 1
else
echo "Installing Keystone" >>$LOG_FILE
echo "Installing Keystone"
echo " Downloading Keystone Service Packages from Internet" >>$LOG_FILE
echo " Downloading Keystone Service Packages from Internet"
echo ""
echo ""
sleep 2
apt-get install -y keystone python-keystone python-keystoneclient
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Keystone Service is completed" >>$LOG_FILE
echo " Installation of Keystone Service is completed"
else
echo ""
echo ""
echo " Error Installing Keystone Service" >>$LOG_FILE
echo " Error Installing Keystone Service"
exit 1
fi
fi

}
#######################
. /etc/InstInfo.env
function config_keystone() {
echo "Configuring Keystone Service" >>$LOG_FILE
echo "Configuring Keystone Service"
echo " "
echo " Making Backup of files " >>$LOG_FILE
echo " Making Backup of files "
cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bkp
echo " "
echo " Modifying the file " >>$LOG_FILE
echo " Modifying the file "
sed -e "
/^admin_token =.*$/s/^.*$/admin_token = $SERVICE_TOKEN/
/^connection =.*$/s/^.*$/connection = mysql:\/\/keystone:$KEYSTONE_MYSQL_PASS@localhost\/keystone/
" -i /etc/keystone/keystone.conf
if [ "$?" -ne 0 ]; then
echo " error modifying keystone file " >>$LOG_FILE
echo " error modifying keystone file "
exit 1
else
echo ""
echo "Completed Configuration of Keystone Service" >>$LOG_FILE
echo "Completed Configuration of Keystone Service"
echo ""
fi

echo "Creating Keystone DB" >>$LOG_FILE
echo "Creating Keystone DB"
echo ""
keystone-manage db_sync
if [ "$?" -ne 0 ]; then
echo " Error Creating Keystone Database " >>$LOG_FILE
echo " Error Creating Keystone Database "
exit 1
else 
echo "  Keystone Database Created " >>$LOG_FILE
echo "  Keystone Database Created "
fi

echo ""
echo "Restarting the keystone service" >>$LOG_FILE
echo "Restarting the keystone service"
service keystone restart
if [ "$?" -ne 0 ]; then
echo " error Restarting  keystone Service " >>$LOG_FILE
echo " error Restarting  keystone Service "
exit 1
else 
echo " Keystone Service Restarted " >>$LOG_FILE
echo " Keystone Service Restarted "
fi
}

function Remove_keystone() {
echo "Uninstalling Keystone Server ">>$LOG_FILE
echo "Uninstalling Keystone Server "
echo " "
sleep 1
apt-get remove -y   keystone python-keystone python-keystoneclient
if [ "$?" -eq 0 ]; then
echo "Uninstallation of Keystone Server Packages Completed">>$LOG_FILE
echo "Uninstallation of Keystone Server Packages Completed"
echo " "
else
echo " Error in Uninstalling Keystone Server ">>$LOG_FILE
echo " Error in Uninstalling Keystone Server "
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
echo " Removing the Traces of Keystone Server ">>$LOG_FILE
echo " Removing the Traces of Keystone Server "
/usr/bin/updatedb
/usr/bin/locate keystone | /bin/grep "/etc/" | /usr/bin/awk '{ print "rm -rf  "$1 }' > tmp.file
/usr/bin/locate keystone | /bin/grep "/var/" | /usr/bin/awk '{ print "rm -rf  "$1 }' >> tmp.file
/bin/sh tmp.file
rm -rf tmp.file
}


function create_keystonedata() {
. /etc/InstInfo.env
echo " Creating Keystone Data ">>$LOG_FILE
echo " Creating Admin Tenant ">>$LOG_FILE
echo " Creating Admin Tenant "
sleep 5
export ADMIN_TENANT=$(keystone tenant-create --name=$ADMIN_TENANT_NAME | awk '/ id / { print $4 }')
if [ -n "$ADMIN_TENANT" ];then
echo "ADMIN_TENANT=$ADMIN_TENANT">>$LOG_FILE
else 
echo "ADMIN_TENANT=$ADMIN_TENANT">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Service Tenant ">>$LOG_FILE
echo " Creating Service Tenant "
sleep 1
export SERVICE_TENANT=$(keystone tenant-create --name=$SERVICE_TENANT_NAME | awk '/ id / { print $4 }')
if [ -n "$SERVICE_TENANT" ];then
echo "SERVICE_TENANT=$SERVICE_TENANT">>$LOG_FILE
else
echo "SERVICE_TENANT=$SERVICE_TENANT ">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Demo Tenant ">>$LOG_FILE
echo " Creating Demo Tenant "
sleep 1
export DEMO_TENANT=$(keystone tenant-create --name=demo | awk '/ id / { print $4 }')
if [ -n "$DEMO_TENANT" ];then
echo "DEMO_TENANT=$DEMO_TENANT">>$LOG_FILE
else
echo "DEMO_TENANT=$DEMO_TENANT">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Users "
echo " -----------------"
echo " Creating Admin User "
sleep 1
export ADMIN_USER=$(keystone user-create --name=admin --pass="$ADMIN_PASSWORD" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$ADMIN_USER" ];then
echo "ADMIN_USER=$ADMIN_USER">>$LOG_FILE
else
echo "ADMIN_USER=$ADMIN_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Demo User "
sleep 1
export DEMO_USER=$(keystone user-create --name=demo --pass="$ADMIN_PASSWORD" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$DEMO_USER" ];then
echo "DEMO_USER=$DEMO_USER" >>$LOG_FILE
else
echo "DEMO_USER=$DEMO_USER" >>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Roles "
sleep 1
export ADMIN_ROLE=$(keystone role-create --name=admin | awk '/ id / { print $4 }')
if [ -n "$ADMIN_ROLE" ];then
echo "ADMIN_ROLE=$ADMIN_ROLE ">> $LOG_FILE
else
echo "ADMIN_ROLE=$ADMIN_ROLE ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

sleep 1
export KEYSTONEADMIN_ROLE=$(keystone role-create --name=KeystoneAdmin | awk '/ id / { print $4 }')
if [ -n "$KEYSTONEADMIN_ROLE" ];then
echo "KEYSTONEADMIN_ROLE=$KEYSTONEADMIN_ROLE ">> $LOG_FILE
else
echo "KEYSTONEADMIN_ROLE=$KEYSTONEADMIN_ROLE ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

sleep 1
export KEYSTONESERVICE_ROLE=$(keystone role-create --name=KeystoneServiceAdmin | awk '/ id / { print $4 }')
if [ -n "$KEYSTONESERVICE_ROLE" ];then
echo "KEYSTONESERVICE_ROLE=$KEYSTONESERVICE_ROLE ">> $LOG_FILE
else
echo "KEYSTONESERVICE_ROLE=$KEYSTONESERVICE_ROLE ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

sleep 1
export MEMBER_ROLE=$(keystone role-create --name=Member | awk '/ id / { print $4 }')
if [ -n "$MEMBER_ROLE" ];then
echo "MEMBER_ROLE=$MEMBER_ROLE ">> $LOG_FILE
else
echo "MEMBER_ROLE=$MEMBER_ROLE ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Assigning Roles to the Users ">> $LOG_FILE
echo " Assigning Roles to the Users "
sleep 1
keystone user-role-add --user $ADMIN_USER --role $ADMIN_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- ADMIN_ROLE -- ADMIN_TENANT">> $LOG_FILE

sleep 1
keystone user-role-add --user $ADMIN_USER --role $KEYSTONEADMIN_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- KEYSTONEADMIN_ROLE -- ADMIN_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user $ADMIN_USER --role $KEYSTONESERVICE_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- KEYSTONESERVICE_ROLE -- ADMIN_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user $ADMIN_USER --role $ADMIN_ROLE --tenant_id $DEMO_TENANT
echo "ADMIN_USER -- ADMIN_ROLE -- DEMO_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user $DEMO_USER --role $MEMBER_ROLE --tenant_id $DEMO_TENANT
echo "DEMO_USER -- MEMBER_ROLE -- DEMO_TENANT ">> $LOG_FILE

echo " Creating Keystone Service ">> $LOG_FILE
echo " Creating Keystone Service "
sleep 1
export KEYSTONESER=$(keystone service-create --name keystone --type identity --description 'OpenStack Identity' | awk '/ id / { print $4 }')
if [ -n "$KEYSTONESER" ];then
echo "Created Keystone Service ">> $LOG_FILE
else 
echo " Error Creating Keystone Service " >>$LOG_FILE
echo " Error Creating Keystone Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Keystone Service End Point " >> $LOG_FILE
echo "Creating Keystone Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $KEYSTONESER --publicurl 'http://'"$MASTER_IP"':5000/v2.0' --adminurl 'http://'"$MASTER_IP"':35357/v2.0' --internalurl 'http://'"$MASTER_IP"':5000/v2.0'
if [ "$?" -eq "0" ]; then
echo "Created Keystone Service End Point ">> $LOG_FILE
else
echo "Error Creating Keystone Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
echo " Keystone Data created sucessfully ">> $LOG_FILE
echo " Keystone Data created sucessfully "
}

function create_EC2() {
# ec2 compatability
EC2=$(get_id keystone service-create --name ec2 --type ec2 --description EC2 )
keystone endpoint-create --region $KEYSTONE_REGION --service-id $EC2 --publicurl 'http://'"$HOST_IP"':8773/services/Cloud' --adminurl 'http://'"$HOST_IP"':8773/services/Admin' --internalurl 'http://'"$HOST_IP"':8773/services/Cloud'

# create ec2 creds and parse the secret and access key returned
RESULT=$(keystone ec2-credentials-create --tenant-id=$ADMIN_TENANT --user-id=$ADMIN_USER)
ADMIN_ACCESS=`echo "$RESULT" | grep access | awk '{print $4}'`
ADMIN_SECRET=`echo "$RESULT" | grep secret | awk '{print $4}'`
# write the secret and access to ec2rc
cat > ec2rc <<EOF
ADMIN_ACCESS=$ADMIN_ACCESS
ADMIN_SECRET=$ADMIN_SECRET
EOF

echo "########################################################################################"
echo;
echo "Your EC2 credentials have been saved into ./ec2rc"

}

####################################################################
function banner() {
clear
echo " Keystone is used for Identity, Token, Catalog and Policy services for use specifically by projects in the OpenStack"
}

if [ "$1" == "remove" ]; then
banner
check_root
echo " Removing Mysql Data "  >>$LOG_FILE
mysql -u root -p$MYSQL_PASSWD <<EOF
DROP DATABASE keystone;
FLUSH PRIVILEGES;
EOF

echo " Removing Mysql Data Completed"  >>$LOG_FILE
echo " Removing Env Data "  >>$LOG_FILE
sed '/OS_TENANT_NAME/d' -i  /etc/InstInfo.env
sed '/OS_USERNAME/d' -i  /etc/InstInfo.env
sed '/OS_PASSWORD/d' -i  /etc/InstInfo.env
sed '/OS_AUTH_URL/d' -i  /etc/InstInfo.env
sed '/ADMIN_PASSWORD/d' -i  /etc/InstInfo.env
sed '/SERVICE_PASSWORD/d' -i  /etc/InstInfo.env
sed '/SERVICE_TOKEN/d' -i  /etc/InstInfo.env
sed '/SERVICE_ENDPOINT/d' -i  /etc/InstInfo.env
sed '/ADMIN_TENANT_NAME/d' -i  /etc/InstInfo.env
sed '/SERVICE_TENANT_NAME/d' -i  /etc/InstInfo.env
sed '/MASTER_IP/d' -i  /etc/InstInfo.env
sed '/KEYSTONE_REGION/d' -i  /etc/InstInfo.env
echo " Removing Env Data Completed "  >>$LOG_FILE

Remove_keystone
echo " Uninstallation  of Keystone Server Completed " >>$LOG_FILE
echo " Uninstallation  of Keystone Server Completed "
elif  [ "$1" == "rmdb" ]; then
banner
Instcheck
check_root
echo " Removing Mysql Data "  >>$LOG_FILE
mysql -u root -p$MYSQL_PASSWD <<EOF
DROP DATABASE keystone;
FLUSH PRIVILEGES;
EOF
echo "Removal of Keystone database from Mysql Database is completed"
echo "Removal of Keystone database from Mysql Database is completed" >>$LOG_FILE
elif  [ "$1" == "nodata" ]; then
banner
Instcheck
check_root
Install_keystone
config_keystone
echo "Installation of  Keystone Without Data  completed"
echo "Installation of  Keystone Without Data  completed" >>$LOG_FILE
elif  [ "$1" == "onlydata" ]; then
banner
Instcheck
check_root
create_keystonedata
echo "Installation of Keystone Data  completed"
echo "Installation of Keystone Data  completed" >>$LOG_FILE
elif  [ "$1" == "alldata" ]; then
banner
Instcheck
check_root
get_details
keystone_mysql
Install_keystone
config_keystone
echo "Installation of Keystone Data  completed"
echo "Installation of Keystone Data  completed" >>$LOG_FILE
elif  [ "$1" == "install" ]; then
banner
Instcheck
check_root
get_details
keystone_mysql
Install_keystone
config_keystone
create_keystonedata
echo "Installation of Keystone Service is Completed"
echo "Installation of Keystone Service is Completed" >>$LOG_FILE
echo ""
echo "###################################################################################################"
echo "Its time to test Keystone Service,the keystone user list and tenant list etc....
      A file "OpenStack.env" was created at the time of installtion in current directory.
      First execute  '. ./OpenStack.env' for setting environment variables
      issue the commands to test keystone 'keystone user-list' "
echo "Installation of Keystone completed Now Install Glance with glance.sh file"
echo "###################################################################################################"

else
clear
echo "
usage: ./keystone.sh option
options:

install: Install & Configuration of Keystone along with data

remove : Uninstallation of keystone along with keystone data

onlydata : Installation of only keystone data

alldata : Installation of only mysql & keystone data

nodata : Install & Configuration of Keystone without keystone data

rmdb: Removing the Keystine database from Mysql DB.

eg: ./keystone.sh install
"

fi
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

