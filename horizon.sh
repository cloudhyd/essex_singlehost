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
function Install_horizon() {
if [ -d /etc/horizon ]; then
echo "Horizon  Service already Installed " >>$LOG_FILE
echo "Horizon  Service already Installed "
exit 1
else
echo "Installing Horizon Dashboard " >>$LOG_FILE
echo "Installing Horizon Dashboard "
echo "Downdloaing Horizon Dashboard  Packages from internet" >>$LOG_FILE
echo "Downdloaing Horizon Dashboard  Packages from internet"
sleep 2
echo ""
echo ""
apt-get install -y libapache2-mod-wsgi openstack-dashboard
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Horizon Dashboard  is completed" >>$LOG_FILE
echo " Installation of Horizon Dashboard  is completed"
else
echo ""
echo ""
echo " Error Installing Horizon Dashboard " >>$LOG_FILE
echo " Error Installing Horizon Dashboard "
exit 1
fi
fi

}

function config_horizon() {
. /etc/InstInfo.env
echo "Configuring Horizon Dashboard " >>$LOG_FILE
echo "Configuring Horizon Dashboard "
echo " "
echo " Making Backup of files " >>$LOG_FILE
echo " Making Backup of files "
cp /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py.bkp
echo " "
echo " Modifying the Horizon Configaration files " >>$LOG_FILE
echo " Modifying the Horizon Configaration files "
echo "Removing Object Store Dash Board" >>$LOG_FILE
echo "Modifying /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py" >>$LOG_FILE
sleep 1
sed -i '/^dashboard.Nova.register(Containers)/s/dashboard.Nova.register(Containers)/#dashboard.Nova.register(Containers)/g' /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py
if [ "$?" -eq 0 ]; then
echo "Modified /etc/openstack-dashboard/local_settings.py " >>$LOG_FILE
else
echo "Error in Modifying /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py" >>$LOG_FILE
echo "Error in Modifying /usr/share/pyshared/horizon/dashboards/nova/containers/panel.py"
echo "exiting " >>$LOG_FILE
exit 1
fi

echo ""
echo "Completed Configuration of Horizon Dashboard " >>$LOG_FILE
echo "Completed Configuration of Horizon Dashboard "
echo ""
}

function horizon_restart() {
echo ""
echo "Restarting Apache webserver for the horizon service" >>$LOG_FILE
echo "Restarting Apache webserver for the horizon service" 
service apache2 restart
if [ "$?" -ne 0 ]; then
echo " error Restarting Apache webserver " >>$LOG_FILE
echo " error Restarting Apache webserver "
exit 1
else 
sleep 4
echo " Apache webserver Restarted " >>$LOG_FILE
echo " Apache webserver Restarted "
fi

}

function Remove_horizon() {
echo "Uninstalling Horizon  Service ">>$LOG_FILE
echo "Uninstalling Horizon  Service "
echo " "
sleep 1
apt-get remove -y  memcached libapache2-mod-wsgi openstack-dashboard novnc
if [ "$?" -eq 0 ]; then
echo "Uninstallation of Horizon  Service Packages Completed">>$LOG_FILE
echo "Uninstallation of Horizon  Service Packages Completed"
echo " "
else
echo " Error in Uninstalling Horizon  Service ">>$LOG_FILE
echo " Error in Uninstalling Horizon  Service "
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
echo " Removing the Traces of Horizon  Service ">>$LOG_FILE
echo " Removing the Traces of Horizon  Service "
/usr/bin/updatedb
/usr/bin/locate horizon | /bin/grep "/etc/" | /usr/bin/awk '{ print "rm -rf  "$1 }' > tmp.file
/usr/bin/locate horizon | /bin/grep "/var/" | /usr/bin/awk '{ print "rm -rf  "$1 }' >> tmp.file
/bin/sh tmp.file
rm -rf tmp.file
}


####################################################################
function banner() {
echo ""
echo " "
echo " Horizon is used to  provides services for discovering, registering, and retrieving virtual machine  s by projects in the OpenStack"
echo ""
echo " "
sleep 2
}
if [ "$1" == "remove" ]; then
check_root
Remove_horizon
echo " Uninstallation  of Horizon  Service Completed ">>$LOG_FILE
echo " Uninstallation  of Horizon  Service Completed "
elif  [ "$1" == "install" ]; then
banner
Instcheck
check_root
Install_horizon
config_horizon
horizon_restart
echo "Installation of Horizon  completed">>$LOG_FILE
echo "Installation of Horizon  completed"
else 
echo " 
usage: ./horizon.sh option
options: 

install: Install & Configuration of Horizon Dash Board

remove : Uninstallation of Horizon 

eg: ./horizon.sh install
" 
fi
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

