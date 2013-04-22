#!/bin/bash
# OK Tested fine but install menu to be added
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
function check_root() {
clear
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
##############################
function check_lvm() {
if [ "$(/usr/bin/dpkg --get-selections | /bin/grep -v "grep" | /bin/grep -i '^lvm' | /usr/bin/wc -l)" -eq "1" ]; then
echo " LVM Package is installed " >>$LOG_FILE
echo " LVM Package is installed "
sleep 1
else
echo " LVM package Not Installed " >>$LOG_FILE
echo " LVM package Not Installed "
echo " Installing LVM package " >>$LOG_FILE
echo " Installing LVM package "
sleep 2
apt-get install -y lvm2
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of LVM Completed" >>$LOG_FILE
echo " Installation of LVM Completed"
else
echo ""
echo ""
echo " Error Installing LVM Check Internet " >>$LOG_FILE
echo " Error Installing LVM Check Internet "
exit 1
fi

echo " "
echo " "
sleep 1
fi
echo " "
echo " "
echo " Checking for NOVA-VOLUME Group"
if [ "$(/sbin/vgdisplay |/bin/grep -v "grep" | /bin/grep -i 'nova' | /usr/bin/wc -l)" -eq "0" ]; then
   echo "You should create nova voulmes to proceed for installation of NOVA"
   echo " "
   echo " "
   echo "If you have another Harddisk or Partition to create NOVA Volumes then follow HDD_PART.txt"
   echo " "
   echo " "
   echo "If you do not have another Harddisk or Partition But have enoudh space to create NOVA Volumes "
   echo " on loop back device then follow VOL_LOOP.txt"
   echo " "
   echo " "
   echo " After creating Volume Group NOVA-VOLUMES then again install nova_4.sh file "
exit
else
echo " NOVA-VOLUME group is Present" >>$LOG_FILE
echo " NOVA-VOLUME group is Present"
fi
}
###############################
function getinfo() {
MASTER=$(/sbin/ifconfig eth0| sed -n 's/.*inet *addr:\([0-9\.]*\).*/\1/p')
echo "#############################################################################################################"
echo "If you want Single LAN card configuration, Press 'S', else Press any key for Dual LAN Configuration : "  >>$LOG_FILE
read -p "If you want Single LAN card configurationi, Press 'S', else Press any key for Dual LAN Configuration : " LANIFACE
echo "Choosen as '$LANIFACE'"  >>$LOG_FILE
echo ""
echo "#############################################################################################################"
echo "The IP address is probably $MASTER" >>$LOG_FILE
echo "The IP address is probably $MASTER"
echo  "Enter the primary ethernet interface IP: "  >>$LOG_FILE
read -p "Enter the primary ethernet interface IP: " MASTER_IP
echo "Entered the primary ethernet interface IP as : $MASTER_IP "   >>$LOG_FILE
echo ""
echo "Enter the network for Internal communication for Virtual Hosts (eg. 192.168.0.0/24): "   >>$LOG_FILE
read -p "Enter the network for Internal communication for Virtual Hosts (eg. 192.168.0.0/24): " VM_NET
echo "Entered '$VM_NET'  as Virtual Host Network "  >>$LOG_FILE
echo ""
echo "Enter the starting IP for Virtual Hosts (eg. 192.168.0.1): "   >>$LOG_FILE
read -p "Enter the starting IP for Virtual Hosts (eg. 192.168.0.1): " VM_STARTIP
echo "Entered '$VM_STARTIP' as Starting IP of Virtual Host Network"  >>$LOG_FILE
echo ""
echo "#######################################################################################"
echo "Enter the Internet IP network (eg. 10.0.1.224/29): "  >>$LOG_FILE
read -p "Enter the Internet IP network (eg. 10.0.1.224/29): " INET_NET
echo "Entered '$INET_NET' as Internet IP network "  >>$LOG_FILE
echo ""
echo "#######################################################################################"
echo "Enter the iscsci network prefix (192.168.1): "   >>$LOG_FILE
read -p "Enter the iscsci network prefix (192.168.1): " IS_PREFIX
echo "Entered '$IS_PREFIX' as iscsci network prefix "  >>$LOG_FILE
echo "#######################################################################################"
if [ "$LANIFACE" = "S" ] || [ "$LANIFACE" = "s" ]
then
echo ""
echo ""
   echo "Selected Single LAN card option,Hence configuring for Single LAN Card 'eth0' with bridge on 'eth0'"  >>$LOG_FILE
   echo "Selected Single LAN card option,Hence configuring for Single LAN Card 'eth0' with bridge on 'eth0'"
FLAT_IFACE=eth0
sleep 2
else
echo ""
echo ""
   echo "Not selected Single LAN option,Hence configuring for Dual LAN Cards 'eth0' & 'eth1' with bridge on 'eth1' "  >>$LOG_FILE
   echo "Not selected Single LAN option,Hence configuring for Dual LAN Cards 'eth0' & 'eth1' with bridge on 'eth1' "
FLAT_IFACE=eth1
sleep 2
fi

VM_NET_SI=$(echo $VM_NET | /usr/bin/cut -f2 -d"/")
VM_NET_SIZE="256"
if [ "$VM_NET_SI" -eq "24" ]; then VM_NET_SIZE="256"; fi
if [ "$VM_NET_SI" -eq "25" ]; then VM_NET_SIZE="128"; fi
if [ "$VM_NET_SI" -eq "26" ]; then VM_NET_SIZE="64"; fi
if [ "$VM_NET_SI" -eq "27" ]; then VM_NET_SIZE="32"; fi
if [ "$VM_NET_SI" -eq "28" ]; then VM_NET_SIZE="16"; fi
if [ "$VM_NET_SI" -eq "29" ]; then VM_NET_SIZE="8"; fi
echo "VM_NET_SIZE IS $VM_NET_SIZE "  >>$LOG_FILE
}

###############################
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

function nova_mysql() {
. /etc/InstInfo.env
echo " Started nova_mysql " >>$LOG_FILE
check_mysql_pass
function prpass() {
echo " Started prpass " >>$LOG_FILE
echo " Using 'nova' as a nova service user for services and mysql"
read -p "Please Enter the New  Password for Nova User  : " mysqlusr_pass1
read -p "Please  Re-Enter the  Password for for Nova User : " mysqlusr_pass2
if [ "$mysqlusr_pass1" == "$mysqlusr_pass2" ]; then
NOVA_MYSQL_PASS=$mysqlusr_pass2
cat >> /etc/InstInfo.env <<EOF
export NOVA_MYSQL_PASS=$mysqlusr_pass2
EOF
echo " exported nova passwd " >>$LOG_FILE
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

echo " Creating Nova Database & Granting Permissions to Nova user " >>$LOG_FILE
echo " Creating Nova Database & Granting Permissions to Nova user "
echo " .... "
mysql -u root -p$MYSQL_PASSWD <<EOF
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$NOVA_MYSQL_PASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$NOVA_MYSQL_PASS';
FLUSH PRIVILEGES;
EOF
if [ "$?" -ne "0" ]; then
echo " Error Creating nova user in mysql " >>$LOG_FILE
echo " Error Creating nova user in mysql "
exit 1
else
echo " nova user created in mysql " >>$LOG_FILE
echo " nova user created in mysql "
fi
}

function create_novadata() {
. /etc/InstInfo.env
echo " Creating Nova Data ">>$LOG_FILE
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

export ADMIN_ROLE=$(keystone role-list | grep "admin" | awk '{print $2}')
sleep 1
if [ -n "$ADMIN_ROLE" ];then
echo "ADMIN_ROLE=$ADMIN_ROLE">>$LOG_FILE
else
echo "ADMIN_ROLE=$ADMIN_ROLE">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Nova User for Keystone Identity Service">>$LOG_FILE
echo " Creating Nova User for Keystone Identity Service"
export NOVA_USER=$(keystone user-create --name=nova --pass="$NOVA_MYSQL_PASS" --email=$EMAIL | awk '/ id / { print $4 }')
sleep 1
if [ -n "$NOVA_USER" ];then
echo "NOVA_USER=$NOVA_USER">>$LOG_FILE
else
echo "NOVA_USER=$NOVA_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " "
echo " Adding Role to Nova User ">>$LOG_FILE
echo " Adding Role to Nova User "
keystone user-role-add --user $NOVA_USER --role $ADMIN_ROLE --tenant_id $SERVICE_TENANT
sleep 1
echo "NOVA_USER -- ADMIN_ROLE -- SERVICE_TENANT ">>$LOG_FILE

echo " Creating Nova Service in Keystone Identity Service ">>$LOG_FILE
echo " Creating Nova Service in Keystone Identity Service "

echo " "
echo " Creating Nova Compute Service in Keystone Identity Service ">>$LOG_FILE
sleep 1
export NOVA_COMP_SER=$(keystone service-create --name nova --type compute --description 'OpenStack Compute Service'| awk '/ id / { print $4 }')
if [ -n "$NOVA_COMP_SER" ];then
echo "NOVA_COMP_SER=$NOVA_COMP_SER ">> $LOG_FILE
echo "Created Nova Compute Service ">> $LOG_FILE
else
echo " Error Creating Nova Compute Service " >>$LOG_FILE
echo " Error Creating Nova Compute Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi
echo " Creating Nova Volume Service in Keystone Identity Service ">>$LOG_FILE
sleep 1
export NOVA_VOLUME=$(keystone service-create --name nova --type volume --description 'OpenStack Volume Service' | awk '/ id / { print $4 }')
if [ -n "$NOVA_VOLUME" ];then
echo "NOVA_VOLUME=$NOVA_VOLUME ">> $LOG_FILE
echo "Created Nova Volume Service">> $LOG_FILE
else
echo " Error Creating Nova Volume Service " >>$LOG_FILE
echo " Error Creating Nova Volume Service"
echo " Exiting ">>$LOG_FILE
exit 1
fi
echo " Creating Nova Objectstore Service in Keystone Identity Service ">>$LOG_FILE
sleep 1
export NOVA_OBSTORE=$(keystone service-create --name nova --type object-store --description 'OpenStack Storage Service' | awk '/ id / { print $4 }')
if [ -n "$NOVA_OBSTORE" ];then
echo "NOVA_OBSTORE=$NOVA_OBSTORE ">> $LOG_FILE
echo "Created Nova Object Store Service">> $LOG_FILE
else
echo " Error Creating Nova Object Store Service " >>$LOG_FILE
echo " Error Creating Nova Object Store Service"
echo " Exiting ">>$LOG_FILE
exit 1
fi
echo " Creating Nova Network Service in Keystone Identity Service ">>$LOG_FILE
sleep 1
export NOVA_NET=$(keystone service-create --name nova --type object-store --description 'OpenStack Storage Service' | awk '/ id / { print $4 }')
if [ -n "$NOVA_NET" ];then
echo "NOVA_NET=$NOVA_NET ">> $LOG_FILE
echo "Created Nova Network Service">> $LOG_FILE
else
echo " Error Creating Nova Network Service " >>$LOG_FILE
echo " Error Creating Nova Network Service"
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Creating Nova EC2 Service in Keystone Identity Service ">>$LOG_FILE
sleep 1
export EC2=$(keystone service-create --name ec2 --type ec2 --description 'OpenStack EC2 service' | awk '/ id / { print $4 }')
if [ -n "$EC2" ];then
echo "EC2=$EC2 ">> $LOG_FILE
echo "Created EC2 Service">> $LOG_FILE
else
echo " Error Creating EC2 Service " >>$LOG_FILE
echo " Error Creating EC2 Service"
echo " Exiting ">>$LOG_FILE
exit 1
fi
########################
echo "Creating Endpoints " >>$LOG_FILE
echo "Creating Endpoints "
echo "Creating Nova Compute Service End Point ">>$LOG_FILE
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $NOVA_COMP_SER --publicurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s' --adminurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s' --internalurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s'
if [ "$?" -eq "0" ]; then
echo "Created Nova Compute Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova Compute Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Nova Volume Service End Point ">>$LOG_FILE
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $NOVA_VOLUME --publicurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s' --adminurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s' --internalurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s'
if [ "$?" -eq "0" ]; then
echo "Created Nova Volume Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova Volume Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Nova Object Store Service End Point ">>$LOG_FILE
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $NOVA_OBSTORE --publicurl 'http://'"$MASTER_IP"':8080/v1/AUTH_$(tenant_id)s' --adminurl 'http://'"$MASTER_IP"':8080/v1' --internalurl 'http://'"$MASTER_IP"':8080/v1/AUTH_$(tenant_id)s'
if [ "$?" -eq "0" ]; then
echo "Created Nova Object Store Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova Object Store Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Nova Network Service End Point ">>$LOG_FILE
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $NOVA_NET --publicurl 'http://'"$MASTER_IP"':9696/' --adminurl 'http://'"$MASTER_IP"':9696/' --internalurl 'http://'"$MASTER_IP"':9696/'
if [ "$?" -eq "0" ]; then
echo "Created Nova Network Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova Network Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo "Creating Nova EC2 Service End Point ">>$LOG_FILE
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service_id $EC2 --publicurl 'http://'"$MASTER_IP"':8773/services/Cloud' --adminurl 'http://'"$MASTER_IP"':8773/services/Admin' --internalurl 'http://'"$MASTER_IP"':8773/services/Cloud'
if [ "$?" -eq "0" ]; then
echo "Created Nova EC2 Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova EC2 Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi

echo " Nova Data created sucessfully ">> $LOG_FILE
echo " Nova Data created sucessfully "
echo "Nova Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Nova Configurations in Keystone Identity Service Completed"

}
###################################################################################################
function Install_nova() {
if [ -d /etc/nova ]; then
echo "Nova Image  Service already Installed " >>$LOG_FILE
echo "Nova Image  Service already Installed "
exit 1
else
echo "Installing Nova Service" >>$LOG_FILE
echo "Downloading Packages for Nova Service" >>$LOG_FILE
echo "Installing Nova Service"
sleep 2
echo ""
echo ""
apt-get install -y nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-vncproxy nova-volume python-nova python-novaclient nova-consoleauth
if [ "$?" -eq 0 ]; then
echo " "
echo " "
echo " Installation of Nova Service is completed" >>$LOG_FILE
echo " Installation of Nova Service is completed"
else
echo ""
echo ""
echo " Error Installing Nova Service Check Internet connection" >>$LOG_FILE
echo " Error Installing Nova ServiceCheck Internet connection"
exit 1
fi
fi

}

function config_nova() {
. /etc/InstInfo.env
echo "Configuring Nova Service" >>$LOG_FILE
echo "Configuring Nova Service"
echo " "
echo " Making Backup of files " >>$LOG_FILE
echo " Making Backup of files "
cp /etc/nova/api-paste.ini /etc/nova/api-paste.ini.bkp 
cp /etc/nova/nova.conf /etc/nova/nova.conf.bkp 


echo " "
echo " Modifying the Nova Configaration files " >>$LOG_FILE
echo " Modifying the Nova Configaration files "
echo "Modifying /etc/nova/api-paste.ini " >>$LOG_FILE
sleep 1
sed -e "
   s,%SERVICE_TENANT_NAME%,service,g;
   s,%SERVICE_USER%,nova,g;
   s,%SERVICE_PASSWORD%,$NOVA_MYSQL_PASS,g;
   " -i /etc/nova/api-paste.ini
if [ "$?" -eq 0 ]; then
echo "Modified /etc/nova/api-paste.ini " >>$LOG_FILE
else
echo "Error in Modifying /etc/nova/api-paste.ini " >>$LOG_FILE
echo "Error in Modifying /etc/nova/api-paste.ini "
echo "exiting " >>$LOG_FILE
exit 1
fi
echo ""
echo "Completed Configuration of Nova Service" >>$LOG_FILE
echo "Completed Configuration of Nova Service"
echo ""
}
########################3
function nova_conf_file() {
echo "# Added by CLoudhyd
# General
--dhcpbridge_flagfile=/etc/nova/nova.conf
--dhcpbridge=/usr/bin/nova-dhcpbridge
--logdir=/var/log/nova
--state_path=/var/lib/nova
--lock_path=/var/lock/nova
--allow_admin_api=true
--use_deprecated_auth=false
--auth_strategy=keystone
--root_helper=sudo nova-rootwrap
--my_ip=$MASTER
# Services
--scheduler_driver=nova.scheduler.simple.SimpleScheduler
--s3_host=$MASTER_IP
--ec2_host=$MASTER_IP
--sql_connection=mysql://nova:$NOVA_MYSQL_PASS@localhost/nova
--rabbit_host=$MASTER_IP
--cc_host=$MASTER_IP
--nova_url=http://$MASTER_IP:8774/v1.1/
--glance_api_servers=$MASTER_IP:9292
--image_service=nova.image.glance.GlanceImageService
--ec2_url=http://$MASTER_IP:8773/services/Cloud
--keystone_ec2_url=http://$MASTER_IP:5000/v2.0/ec2tokens
--api_paste_config=/etc/nova/api-paste.ini
#--ec2_private_dns_show

#Volume
--iscsi_helper=tgtadm
--iscsi_ip_prefix=$IS_PREFIX
--routing_source_ip=$MASTER_IP
--volume_group=nova-volumes

# Hypervisor

--libvirt_type=kvm
--libvirt_use_virtio_for_bridges=true
--start_guests_on_host_boot=true
--resume_guests_state_on_host_boot=true
--connection_type=libvirt
#--libvirt_use_virtio_for_bridges
#VNC
--novnc_enabled=true
--novncproxy_base_url=http://$MASTER_IP:6080/vnc_auto.html
--vncserver_proxyclient_address=$MASTER_IP
--vncserver_listen=0.0.0.0
#--vnc_enabled=true
#--vncproxy_url=http://$MASTER_IP:6080
#--vnc_console_proxy_url=http://$MASTER_IP:6080

#Network
--network_manager=nova.network.manager.FlatDHCPManager
--public_interface=eth0
--flat_interface=$FLAT_IFACE
--flat_network_bridge=br100
--fixed_range=$VM_NET
--floating_range=$INET_NET
--network_size=$VM_NET_SIZE
--flat_network_dhcp_start=$VM_STARTIP
--flat_injected=False
--force_dhcp_release=True
--multi_host=True
--enabled_apis=metadata,ec2,osapi_compute,osapi_volume
#--flat_injected=True
--verbose
 
" >/etc/nova/nova.conf
if [ "$?" -ne 0 ]; then
echo " Error Creating /etc/nova/nova.conf " >>$LOG_FILE
echo " Error Creating /etc/nova/nova.conf "
exit 1
else 
echo "  Created file /etc/nova/nova.conf " >>$LOG_FILE
echo "  Created file /etc/nova/nova.conf " 
fi

}
function restart_nova() {

echo "Creating Nova Image  DB" >>$LOG_FILE
echo "Creating Nova Image  DB"
echo ""
nova-manage db sync
if [ "$?" -ne 0 ]; then
echo " Error Creating Nova Database " >>$LOG_FILE
echo " Error Creating Nova Database "
exit 1
else 
echo "  Nova Database Created " >>$LOG_FILE
echo "  Nova Database Created "
fi

echo ""
echo "Restarting the nova service" >>$LOG_FILE
echo "Restarting the nova service"
for a in libvirt-bin nova-network nova-compute nova-api nova-objectstore nova-scheduler nova-volume nova-vncproxy; do service "$a" stop; done
for a in libvirt-bin nova-network nova-compute nova-api nova-objectstore nova-scheduler nova-volume nova-vncproxy; do service "$a" start; done
if [ "$?" -ne 0 ]; then
echo " error Restarting  nova Service " >>$LOG_FILE
echo " error Restarting  nova Service "
exit 1
else 
sleep 4
echo " Nova Service Restarted " >>$LOG_FILE
echo " Nova Service Restarted "
fi
echo " Creating Virtual Network for Instances " >>$LOG_FILE
echo " Creating Virtual Network for Instances "
sleep 4
nova-manage network create private --fixed_range_v4 $VM_NET --num_networks 1 --bridge br100 --bridge_interface $FLAT_IFACE --network_size $VM_NET_SIZE
if [ "$?" -eq 0 ]; then
echo " Created Virtual Network for Instances " >>$LOG_FILE
else
echo " Error Creating Virtual Network for Instances " >>$LOG_FILE
echo " Error Creating Virtual Network for Instances "
exit 1
fi
echo " Creating Floating Network on $FLAT_IFACE" >>$LOG_FILE
echo " Creating Floating Network on $FLAT_IFACE"
sleep 2
nova-manage floating create --ip_range=$INET_NET
if [ "$?" -eq 0 ]; then
echo " Created Virtual Network for Instances " >>$LOG_FILE
else
echo " Error Creating Floating Network on $FLAT_IFACE" >>$LOG_FILE
echo " Error Creating Floating Network on $FLAT_IFACE"
exit 1
fi
echo "Changing Permission for Nova user " >>$LOG_FILE
chown -R nova:nova /etc/nova
if [ "$?" -ne 0 ]; then
echo " Error Changing Permission for Nova user" >>$LOG_FILE
echo " Error Changing Permission for Nova user"
exit 1
else
sleep 4
echo " Changed Permission for Nova user" >>$LOG_FILE
echo " Changed Permission for Nova user"
fi

echo " Nova Installation Completed ">>$LOG_FILE
echo " Nova Installation Completed "
}
function banner_end() {
echo "#################################################################################################"
echo "Its time to test the NOVA
      execute  '. ./OpenStack.env' for setting environment variables
      issue the command to test Nova  'nova image-list'"
echo "Installation of Nova Services completed Now Install Horizon with 'horizon.sh' file"
echo "#################################################################################################"
}

function Remove_nova() {
apt-get remove -y nova-api nova-cert nova-common nova-compute nova-compute-kvm nova-doc nova-network nova-objectstore nova-scheduler nova-vncproxy nova-volume python-nova python-novaclient nova-consoleauth
if [ "$?" -eq 0 ]; then
echo "Uninstallation of Nova Service Packages Completed">>$LOG_FILE
echo "Uninstallation of Nova Service Packages Completed"
echo " "
else
echo " Error in Uninstalling Nova Service ">>$LOG_FILE
echo " Error in Uninstalling Nova Service "
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
echo " Removing the Traces of Nova Service ">>$LOG_FILE
echo " Removing the Traces of Nova Service "
/usr/bin/updatedb
/usr/bin/locate nova | /bin/grep "/etc/" | /usr/bin/awk '{ print "rm -rf  "$1 }' > tmp.file
/usr/bin/locate nova | /bin/grep "/var/" | /usr/bin/awk '{ print "rm -rf  "$1 }' >> tmp.file
/bin/sh tmp.file
rm -rf tmp.file
}


####################################################################
function banner_nova() {
echo ""
echo " "
echo " Nova is used to  provides services Like COMPUTE, VOLUMES, NETWORK etc "
echo ""
echo " "
sleep 1
}
if [ "$1" == "remove" ]; then
banner_nova
check_root
echo "Uninstalling Nova Service " >>$LOG_FILE
echo "Uninstalling Nova Service "
echo " "
sleep 1
mysql -u root -p$MYSQL_PASSWD <<EOF
DROP DATABASE nova;
FLUSH PRIVILEGES;
EOF
sed '/NOVA_MYSQL_PASS/d' -i  /etc/InstInfo.env
Remove_nova
echo " Uninstallation  of Nova Service Completed "
elif [ "$1" == "install" ]; then
banner_nova
check_root
check_lvm
check_mysql_pass
nova_mysql
getinfo
Install_nova
config_nova
create_novadata
nova_conf_file
restart_nova
banner_end
else
clear
echo "
usage: ./nova.sh option
options:

install: Install & Configuration of Nova Services along with data

remove : Uninstallation of Nova Services along with Nova Services data

eg: ./nova.sh install
"
fi
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

