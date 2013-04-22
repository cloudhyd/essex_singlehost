#!/bin/bash
# OK Tested fine
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
clear
#################################################################
function Instcheck() {
clear
echo " Checking /etc/InstInfo.env file ">>LOG_FILE
if [ -f /etc/InstInfo.env ]; then
echo " /etc/InstInfo.env file is present ">>LOG_FILE
else
echo ""
echo " Start Installation with Installation script by ./install.sh script"
echo "Start Installation with Installation script by ./install.sh script  ">>LOG_FILE
echo " Exiting  ">>LOG_FILE
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


function Install_rabbit() {
echo " Rabbit-QM is used with Advanced Message Queuing Protocol for Message Queuing in the OpenStack"
if [ -f /usr/sbin/rabbitmq-server ]; then
echo "Rabbit MQ Server already Installed ">>$LOG_FILE
echo "Rabbit MQ Server already Installed "
exit 1
else
echo "Installing RabbitMQ">>$LOG_FILE
echo "Installing RabbitMQ"
echo " Downloading RabbitMQ Server Packages from Internet" >>$LOG_FILE
echo " Downloading RabbitMQ Server Packages from Internet"
echo ""
echo ""
sleep 2
apt-get install -y  rabbitmq-server memcached python-memcache
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Rabbit MQ is completed">>$LOG_FILE
echo " Installation of Rabbit MQ is completed"
echo " "
read -p "Enter Rabbit MQ password : " RabMQ

cat >> /etc/InstInfo.env <<EOF
export RabbitMQ_PASS=$RabMQ
EOF

#rabbitmqctl change_password guest $RabMQ
if [ "$?" -eq 0 ]; then
echo " RabbitMQ guest User Password changed ">>$LOG_FILE
echo "  RabbitMQ guest User Password changed "
fi
else
echo ""
echo ""
echo " Error Installing RabbitMQ" >>$LOG_FILE
echo " Error Installing RabbitMQ"
fi
fi
}

function Remove_Rabbit() {
apt-get remove -y  rabbitmq-server 
if [ "$?" -eq 0 ]; then
echo "Uninstallation of RabbitMQ Server Packages Completed">>$LOG_FILE
echo "Uninstallation of RabbitMQ Server Packages Completed"
echo " "
else
echo " Error in Uninstalling RabbitMQ Server ">>$LOG_FILE
echo " Error in Uninstalling RabbitMQ Server "
exit 1
fi

echo "Uninstalling Dependancey packages">>$LOG_FILE
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
echo " Rmoving the Traces of RabbitMQ Server ">>$LOG_FILE
echo " Rmoving the Traces of RabbitMQ Server "
/usr/bin/updatedb
/usr/bin/locate rabbit | /bin/grep "/etc/" | /usr/bin/awk '{ print "rm -rf  "$1 }' > tmp.file
/usr/bin/locate rabbit | /bin/grep "/var/" | /usr/bin/awk '{ print "rm -rf  "$1 }' >> tmp.file
/bin/sh tmp.file
rm -rf tmp.file
}



####################################################################
if [ "$1" == "remove" ]; then
echo "Uninstalling RabbitMQ Server ">>$LOG_FILE
echo "Uninstalling RabbitMQ Server "
echo " "
sleep 1
check_root
Remove_Rabbit
echo " Uninstallation  of RabbitMQ Server Completed "
elif [ "$1" == "install" ]; then
clear
Instcheck
check_root
Install_rabbit
echo "Installation of RabbitMQ completed Now Install Keystone with keystone.sh file">>$LOG_FILE
echo "Installation of RabbitMQ completed Now Install Keystone with keystone.sh file"
else
clear
echo "
usage: ./rabbitmq.sh option
options:

install: Install & Configuration of RabbitMQ along with data

remove : Uninstallation of RabbitMQ along with RabbitMQ data

eg: ./rabbitmq.sh install
"
fi
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

