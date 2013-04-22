#!/bin/bash
# OK Tested fine
#Endpoints on Local Loop : 127.0.0.1
#########################################################################################################
#													#
#  The Scripts were created to simlipyfy the Openstack Installation for General Users.			#
#   													#
#  Created Date : 26 March 2013 									#
#													#
#  Created By : Shivaram Y & Shyam Y									#
#													#
#  Support Gorups : Cloudconverge & Cloudhyd								#
#													#
#  Email: yshivaram@yahoo.com & yedurushyam@hotmail.com							#
#													#
#########################################################################################################
clear
LOG_FILE=cloudhyd_opinstallation.log
function start_log() {
if [ -f /var/log/$LOG_FILE ]; then
mv $LOG_FILE /var/log/cloudhyd_opinstallation.`date '+%Y-%m-%d_%H-%M-%S'`.log
echo " Starting Installation of Openstack at `date` "> $LOG_FILE
echo "creating installation log at '$LOG_FILE' "
echo " " >> $LOG_FILE
else
echo "creating installation log at '$LOG_FILE' "
echo " Starting Installation of Openstack at `date` "> $LOG_FILE
echo " " >> $LOG_FILE 
fi 
}

function check_root() {
echo "Checking User  " >>$LOG_FILE
echo "Checking User  " 
echo "  "
sleep 1
if [ "$(id -u)" != "0" ]; then
echo "User is not root " >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands "  >>$LOG_FILE
echo "You should be 'root' or use sudo to execute the commands " 1>&2
echo " "
exit 1
else
echo "User is Root Process started" >>$LOG_FILE
echo "User is Root Process started" 
echo " "
fi

}

function check_inst() {
if [  -f /etc/InstInfo.env ]; then
echo " Openstack Installed, Verifying the installation">>$LOG_FILE
echo " Openstack Installed, Verifying the installation"
echo "  "
sleep 1

if [ -f /usr/sbin/rabbitmq-server ]; then
echo "Rabbit MQ Server already Installed ">>$LOG_FILE
echo "Rabbit MQ Server already Installed "
echo "  "
sleep 1
else
echo "Install Rabbit MQ Server with rabbitmq.sh ">>$LOG_FILE
echo "Install Rabbit MQ Server with rabbitmq.sh "
echo "  "
exit 1
fi

if [ -f /etc/keystone/keystone.conf ]; then
echo " keystone Installed, Verify the installation with 'keystone user-list' ">>$LOG_FILE
echo " keystone Installed, Verify the installation with 'keystone user-list' "
echo "  "
sleep 1
else
echo " Install keystone with keystone.sh ">>$LOG_FILE
echo " Install keystone with keystone.sh "
echo "  "
exit 1
fi

if [ -f /etc/glance/glance.conf ]; then
echo " glance Installed, Verify the installation with 'glance index' " >>$LOG_FILE
echo " glance Installed, Verify the installation with 'glance index' "
echo "  "
sleep 1
else
echo " Install glance with glance.sh ">>$LOG_FILE
echo " Install glance with glance.sh "
echo "  "
exit 1
fi

if [ -f /etc/nova/nova.conf ]; then
echo " nova Installed, Verify the installation with 'nova image-list ' ">>$LOG_FILE
echo " nova Installed, Verify the installation with 'nova image-list ' "
else
echo " Install nova with nova.sh ">>$LOG_FILE
echo " Install nova with nova.sh "
echo "  "
exit 1
fi
fi
}

echo " Updating Repositories " >>$LOG_FILE
echo " Updating Repositories  "
echo " "
sleep 1
apt-get update
if [ "$?" -ne 0 ]; then
echo "Error Updating Repositories, Check Internet Connection ">>$LOG_FILE
echo "Error  Updating Repositories, Check Internet Connection "
exit 1
else
echo "Updating Repositories Completed ">>$LOG_FILE
echo "Updating Repositories Completed "
echo "  "
sleep 1
fi


#echo " Checking & Upgrading the System for latest Softwares   ">>$LOG_FILE
#echo " Checking & Upgrading the System for latest Softwares  "
#echo " "
#sleep 1
#apt-get -y upgrade
#if [ "$?" -ne 0 ]; then
#echo "Error Upgrading the System for latest Softwares">>$LOG_FILE
#echo "Error  Upgrading the System for latest Softwares "
#exit 1
#else
#echo "Checking & Upgrading the System for latest Softwares Completed ">>$LOG_FILE
#echo "Checking & Upgrading the System for latest Softwares Completed "
#echo "  "
#sleep 1
#fi

function install_ntp () {
echo "Installing NTP Server " >>$LOG_FILE
echo "Installing NTP Server " 
echo " "
echo " "
sleep 3
apt-get install -y ntp
if [ "$?" = "0" ]; then
echo "NTP Server Installation completed ">>$LOG_FILE
echo "NTP Server Installation completed "
else
echo "NTP Server Installation Failed ">>$LOG_FILE
echo "NTP Server Installation Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi
}

function config_ntp() {
echo "Configuring NTP Server " >>$LOG_FILE
echo "Configuring NTP Server " 
sleep 1
echo "server ntp.ubuntu.com
server 127.127.1.0
fudge 127.127.1.0 stratum 10
" >>/etc/ntp.conf
if [ "$?" = "0" ]; then
echo "NTP Server Configuring Completed ">>$LOG_FILE
echo "NTP Server Configuring Completed "
else
echo "NTP Server Configuring Failed ">>$LOG_FILE
echo "NTP Server Configuring Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi

}

function restart_ntp() {
echo "Restarting NTP Server " >>$LOG_FILE
echo "Restarting NTP Server " 
echo "  "
sleep 1
service ntp restart
if [ "$?" = "0" ]; then
echo "NTP Server Restarted ">>$LOG_FILE
echo "NTP Server Restarted "
else
echo "NTP Server restarting Failed ">>$LOG_FILE
echo "NTP Server restarting Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi
}

function check_ntp(){
echo "Checking NTP Server " >>$LOG_FILE
echo "Checking NTP Server " 
echo "Network Time Protocol is the Service which provieds extact Date and Time to be same on all Servers"
sleep 2
if [ -f /etc/ntp.conf ];then
echo "NTP Server Installed " >>$LOG_FILE
echo "NTP Server Installed "
else
echo "NTP Server Not Installed " 
echo "NTP Server Not Installed " >>$LOG_FILE
fi
}

function enable_ipfwd() {
echo "Enable IP forwarding on Server to forward the Packets between differnt LANs " 
echo "Modifying '/etc/sysctl.conf' " >>$LOG_FILE
echo "Modifying '/etc/sysctl.conf' " 
echo "  "
sleep 1
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -e "/^#net.ipv4.ip_forward=1/i net.ipv4.ip_forward=1 " -i /etc/sysctl.conf

if [ "$?" = "0" ]; then
echo "IP Forwardng Enabled ">>$LOG_FILE
echo "IP Forwardng Enabled "
else
echo "IP Forwarding Failed ">>$LOG_FILE
echo "IP Forwarding Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi
}

function check_mysqld() {

echo "MySql Database will store all the Data related to the modules which are used by Openstack "
echo "  "
echo "Checking MySQL Database Server  " >>$LOG_FILE
echo "Checking MySQL Database Server  "
sleep 1
if [ -f /etc/mysql/my.cnf ];then
echo "Already MySQL Database Server Installed ">>$LOG_FILE
echo "Already MySQL Database Server Installed "
else
echo "Install MySQL Database Server">>$LOG_FILE
echo "Install MySQL Database Server"
fi
}

function install_mysqld() {
echo "Installation of Mysql Database server Started" >>$LOG_FILE
echo "Installation of MysqlDatabase server Started"
echo "################################################################################################################

"
echo "It will prompt to enter New PASSWORD for mysql,
      This password is used to login as root in mysql and will allow you perform root ( admin )related tasks"
echo "
      ################################################################################################################ "
echo " "
echo " "
sleep 3
apt-get install -y mysql-server python-mysqldb
if [ "$?" = "0" ]; then
echo "MySQL Database Server Installation Completed ">>$LOG_FILE
echo "MySQL Database Server Installation Completed "
else
echo "MySQL Database Server Installation Failed ">>$LOG_FILE
echo "MySQL Database Server Installation Failed "
echo "Exiting "  >>$LOG_FILE
fi
}

function config_mysqld() {
echo "Configuring MySQL Database Server " >>$LOG_FILE
echo "Configuring MySQL Database Server " 
echo "  "
sleep 1
sed -i '/^bind-address/s/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
if [ "$?" = "0" ]; then
echo "Configuration of MySQL Database Server Completed ">>$LOG_FILE
echo "Configuration of MySQL Database Server Completed "
else
echo "Configuration of MySQL Database Server Failed ">>$LOG_FILE
echo "Configuration of MySQL Database Server Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi
/etc/init.d/mysql restart
echo " Restarting MySQL Database Server ">>$LOG_FILE
echo " Restarting MySQL Database Server "
if [ "$?" = "0" ]; then
echo "Restarting MySQL Database Server Completed ">>$LOG_FILE
echo "Restarting MySQL Database Server Completed "
else
echo "Restarting MySQL Database Server Failed ">>$LOG_FILE
echo "Restarting MySQL Database Server Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi

}

function mysqld_pass() {
echo "Creating InstInfo.env file and saving password to the file"  >>$LOG_FILE
read -p "Enter a the root password which was given at the time of Mysql Installation : " mysql_pass
echo "Storing MySQL Root Password " >>$LOG_FILE
echo "Storing MySQL Root Password "
echo " "
cat > /etc/InstInfo.env <<EOF
export MYSQL_PASSWD=$mysql_pass
export LOG_FILE="cloudhyd_opinstallation.log"
EOF
if [ "$?" = "0" ]; then
echo "Created Install env File">>$LOG_FILE
echo "Created Install env File"
else
echo "Creating Install env File Failed ">>$LOG_FILE
echo "Creating Install env File Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi

/bin/chmod +x /etc/InstInfo.env
if [ "$?" = "0" ]; then
echo "Storing MySQL Root Password Completed ">>$LOG_FILE
echo "Storing MySQL Root Password Completed "
else
echo "Storing MySQL Root Password Failed ">>$LOG_FILE
echo "Storing MySQL Root Password Failed "
echo "Exiting "  >>$LOG_FILE
exit 1
fi
}
function net_banner () {
echo "Create Users as per you modules"
echo "edit your netowrk as per the requirements in  /etc/network/interfaces file and you require two Lan Cards for this Installation"
echo "Please find the below example how your network should look like "
echo "auto eth0
iface eth0 inet static
 address 10.0.1.20
 network 10.0.1.0
 netmask 255.255.255.0
 broadcast 10.0.1.255
 gateway 10.0.1.1
 dns-nameservers 10.0.1.1

auto eth1
"
echo "After editing the Network Settings, Please restart the Network"
echo "/etc/init.d/networking restart"
}

###########################################################################
#                Installation is started from Here                        #
###########################################################################

start_log
check_root
check_inst
check_ntp
install_ntp
config_ntp
restart_ntp
enable_ipfwd
check_mysqld
install_mysqld
config_mysqld
mysqld_pass
net_banner

echo "Installation of Phase one completed Now Install RabbitMQ with rabbitmq.sh file">>$LOG_FILE
echo "Installation of Phase one completed Now Install RabbitMQ with rabbitmq.sh file"
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################
