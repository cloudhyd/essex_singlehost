#!/bin/bash
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
function keyston_tenants() {
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
}
function keystone_users() {
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
}

function keystone_roles() {
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
}

function keystone_user_roles() {
echo " Assigning Roles to the Users ">> $LOG_FILE
echo " Assigning Roles to the Users "
sleep 1
keystone user-role-add --user-id $ADMIN_USER --role-id $ADMIN_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- ADMIN_ROLE -- ADMIN_TENANT">> $LOG_FILE

sleep 1
keystone user-role-add --user-id $ADMIN_USER --role-id $KEYSTONEADMIN_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- KEYSTONEADMIN_ROLE -- ADMIN_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user-id $ADMIN_USER --role-id $KEYSTONESERVICE_ROLE --tenant_id $ADMIN_TENANT
echo "ADMIN_USER -- KEYSTONESERVICE_ROLE -- ADMIN_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user-id $ADMIN_USER --role-id $ADMIN_ROLE --tenant_id $DEMO_TENANT
echo "ADMIN_USER -- ADMIN_ROLE -- DEMO_TENANT ">> $LOG_FILE

sleep 1
keystone user-role-add --user-id $DEMO_USER --role-id $MEMBER_ROLE --tenant-id $DEMO_TENANT
echo "DEMO_USER -- MEMBER_ROLE -- DEMO_TENANT ">> $LOG_FILE
}

function keystone_service() {
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
}
function keystone_endpoint() {
echo "Creating Keystone Service End Point " >> $LOG_FILE
echo "Creating Keystone Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $KEYSTONESER --publicurl 'http://'"$MASTER_IP"':5000/v2.0' --adminurl 'http://'"$MASTER_IP"':35357/v2.0' --internalurl 'http://'"$MASTER_IP"':5000/v2.0'
if [ "$?" -eq "0" ]; then
echo "Created Keystone Service End Point ">> $LOG_FILE
else
echo "Error Creating Keystone Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function Keystone_ok_banner() {
echo "Keystone Identity Service data configuration  Completed">> $LOG_FILE
echo "Keystone Identity Service  data configuration Completed"
}
######################################################################
function get_keystone_ids() {
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
}

#############################################################################
function glance_user() {
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
}
function glance_roles() {
echo " "
echo " Adding Role to Glance User ">>$LOG_FILE
echo " Adding Role to Glance User "
keystone user-role-add --user-id $GLANCE_USER --role-id $ADMIN_ROLE --tenant-id $SERVICE_TENANT
sleep 1
echo "GLANCE_USER -- ADMIN_ROLE -- SERVICE_TENANT ">>$LOG_FILE
keystone user-role-add --user-id $GLANCE_USER --role-id $ADMIN_ROLE --tenant-id $ADMIN_TENANT
sleep 1
echo "GLANCE_USER -- ADMIN_ROLE -- ADMIN_TENANT ">>$LOG_FILE
}

function glance_service() {
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
}

function glance_endpoint() {
echo "Creating Glance Service End Point ">>$LOG_FILE
echo "Creating Glance Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $GLANCE_IMGSER --publicurl 'http://'"$MASTER_IP"':9292/v2' --adminurl 'http://'"$MASTER_IP"':9292/v2' --internalurl 'http://'"$MASTER_IP"':9292/v2'
if [ "$?" -eq "0" ]; then
echo "Created Glance Service End Point ">> $LOG_FILE
else
echo "Error Creating Glance Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function glance_ok_banner() {
echo "Glance Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Glance Configurations in Keystone Identity Service Completed"
}
###################################################################################################
function nova_user() {

echo " Creating Nova User for Keystone Identity Service">>$LOG_FILE
echo " Creating Nova User for Keystone Identity Service"
sleep 1
export NOVA_USER=$(keystone user-create --name=nova --pass="$NOVA_MYSQL_PASS" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$NOVA_USER" ];then
echo "NOVA_USER=$GLANCE_USER">>$LOG_FILE
else
echo "NOVA_USER=$GLANCE_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function nova_roles() {
echo " "
echo " Adding Roles to Nova User ">>$LOG_FILE
echo " Adding Roles to Nova User "
keystone user-role-add --user-id $NOVA_USER --role-id $ADMIN_ROLE --tenant-id $SERVICE_TENANT
sleep 1
echo "NOVA_USER -- ADMIN_ROLE -- SERVICE_TENANT ">>$LOG_FILE
}
function nova_compute_service() {
echo " Creating Nova Compute Services in Keystone Identity Service ">>$LOG_FILE
echo " Creating Nova Compute Services in Keystone Identity Service "
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
}

function nova_network_service() {
echo " Creating Nova Network Services in Keystone Identity Service ">>$LOG_FILE
echo " Creating Nova Network Services in Keystone Identity Service "
sleep 1
export NOVA_NET_SER=$(keystone service-create --name nova --type network --description 'OpenStack Network Service'| awk '/ id / { print $4 }')
if [ -n "$NOVA_NET_SER" ];then
echo "NOVA_NET_SER=$NOVA_NET_SER ">> $LOG_FILE
echo "Created Nova Network Service ">> $LOG_FILE
else
echo " Error Creating Nova Network Service " >>$LOG_FILE
echo " Error Creating Nova Network Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function nova_compute_endpoint() {
echo "Creating Nova Network Service End Point ">>$LOG_FILE
echo "Creating Nova Network Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $NOVA_COMP_SER --publicurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s' --adminurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s' --internalurl 'http://'"$MASTER_IP"':8774/v2/$(tenant_id)s'
if [ "$?" -eq "0" ]; then
echo "Created Nova Network Service End Point ">> $LOG_FILE
else
echo "Error Creating Nova Network Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function nova_ok_banner() {
echo "Nova Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Nova Configurations in Keystone Identity Service Completed"
}
#########################################################################################################
function ec2_service() {
echo " Creating EC2 Service in Keystone Identity Service ">>$LOG_FILE
echo " Creating EC2 Service in Keystone Identity Service "
sleep 1
export EC2_SER=$(keystone service-create --name ec2 --type ec2 --description 'OpenStack EC2 Service'| awk '/ id / { print $4 }')
if [ -n "$EC2_SER" ];then
echo "EC2_SER=$EC2_SER ">> $LOG_FILE
echo "Created EC2 Service ">> $LOG_FILE
else
echo " Error Creating EC2 Service " >>$LOG_FILE
echo " Error Creating EC2 Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function ec2_endpoint() {
echo "Creating EC2 Service End Point ">>$LOG_FILE
echo "Creating EC2 Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $EC2_SER --publicurl 'http://'"$MASTER_IP"':8773/services/Cloud' --adminurl 'http://'"$MASTER_IP"':8773/services/Admin' --internalurl 'http://'"$MASTER_IP"':8773/services/Cloud'
if [ "$?" -eq "0" ]; then
echo "Created EC2 Service End Point ">> $LOG_FILE
else
echo "Error Creating EC2 Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function ec2_ok_banner() {
echo "EC2 Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "EC2 Configurations in Keystone Identity Service Completed"
}
########################################################################################################
function cinder_user() {
echo " Creating Cinder User for Keystone Identity Service">>$LOG_FILE
echo " Creating Cinder User for Keystone Identity Service"
sleep 1
export CINDER_USER=$(keystone user-create --name=cinder --pass="$CINDER_MYSQL_PASS" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$CINDER_USER" ];then
echo "CINDER_USER=$CINDER_USER">>$LOG_FILE
else
echo "CINDER_USER=$CINDER_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function cinder_roles() {
echo " "
echo " Adding Role to Cinder User ">>$LOG_FILE
echo " Adding Role to Cinder User "
keystone user-role-add --user-id $GLANCE_USER --role-id $ADMIN_ROLE --tenant-id $SERVICE_TENANT
sleep 1
}

function cinder_service() {
echo " Creating Cinder Service in Keystone Identity Service ">>$LOG_FILE
echo " Creating Cinder Service in Keystone Identity Service "
sleep 1
export CINDER_SER=$(keystone service-create --name cinder --type volume --description 'OpenStack Volume Service'| awk '/ id / { print $4 }')
if [ -n "$CINDER_SER" ];then
echo "CINDER_SER=$CINDER_SER ">> $LOG_FILE
echo "Created Cinder Service ">> $LOG_FILE
else
echo " Error Creating Cinder Service " >>$LOG_FILE
echo " Error Creating Cinder Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function cinder_endpoint() {
echo "Creating Cinder Service End Point ">>$LOG_FILE
echo "Creating Cinder Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $CINDER_SER --publicurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s' --adminurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s' --internalurl 'http://'"$MASTER_IP"':8776/v1/$(tenant_id)s'
if [ "$?" -eq "0" ]; then
echo "Created Cinder Service End Point ">> $LOG_FILE
else
echo "Error Creating Cinder Service End Point ">> $LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}

function cinder_ok_banner() {
echo "Cinder Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Cinder Configurations in Keystone Identity Service Completed"
}

##########################################################################################################
function cinder_user() {
echo " Creating Quantum User for Keystone Identity Service">>$LOG_FILE
echo " Creating Quantum User for Keystone Identity Service"
sleep 1
export QUANTUM_USER=$(keystone user-create --name=quantum --pass="$QUANTUM_MYSQL_PASS" --email=$EMAIL | awk '/ id / { print $4 }')
if [ -n "$CINDER_USER" ];then
echo "QUANTUM_USER=$QUANTUM_USER">>$LOG_FILE
else
echo "QUANTUM_USER=$QUANTUM_USER">>$LOG_FILE
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function quantum_roles() {
echo " "
echo " Adding Role to Quantum User ">>$LOG_FILE
echo " Adding Role to Quantum User "
keystone user-role-add --user-id $QUANTUM_USER --role-id $ADMIN_ROLE --tenant-id $SERVICE_TENANT
sleep 1
echo "QUANTUM_USER -- ADMIN_ROLE -- SERVICE_TENANT ">>$LOG_FILE
keystone user-role-add --user-id $QUANTUM_USER --role-id $ADMIN_ROLE --tenant-id $ADMIN_TENANT
sleep 1
echo "QUANTUM_USER -- ADMIN_ROLE -- ADMIN_TENANT ">>$LOG_FILE
}

function quantum_service() {
echo " Creating Quantum Service in Keystone Identity Service ">>$LOG_FILE
echo " Creating Quantum Service in Keystone Identity Service "
sleep 1
export QUANTUM_SER=$(keystone service-create --name quantum --type network --description 'OpenStack Network Service'| awk '/ id / { print $4 }')
if [ -n "$QUANTUM_SER" ];then
echo "QUANTUM_SER=$QUANTUM_SER ">> $LOG_FILE
echo "Created Quantum Service ">> $LOG_FILE
else
echo " Error Quantumng Cinder Service " >>$LOG_FILE
echo " Error Quantumng Cinder Service " 
echo " Exiting ">>$LOG_FILE
exit 1
fi
}
function quantum_endpoint() {
echo "Creating Quantum Service End Point ">>$LOG_FILE
echo "Creating Quantum Service End Point "
sleep 1
keystone endpoint-create --region $KEYSTONE_REGION --service-id $QUANTUM_SER --publicurl 'http://'"$MASTER_IP"':9696/' --adminurl 'http://'"$MASTER_IP"':9696/' --internalurl 'http://'"$MASTER_IP"':9696/'
if [ "$?" -eq "0" ]; then
echo "Created Quantum Service End Point ">> $LOG_FILE
else
echo "Error Creating Quantum Service End Point ">> $LOG_FILE
echo "Error Creating Quantum Service End Point "
echo " Exiting ">>$LOG_FILE
exit 1
fi
}

function quantum_ok_banner() {
echo "Quantum Configurations in Keystone Identity Service Completed">> $LOG_FILE
echo "Quantum Configurations in Keystone Identity Service Completed"
}
##############################################################################################################
#keyston_tenants 
#keystone_users 
#keystone_roles 
#keystone_user_roles 
#keystone_service 
#keystone_endpoint 
#Keystone_ok_banner 
get_keystone_ids 
#glance_user 
#glance_roles 
#glance_service 
#glance_endpoint 
#glance_ok_banner 
#nova_user 
#nova_roles 
#nova_compute_service 
#nova_network_service 
#nova_compute_endpoint 
#nova_ok_banner 
#ec2_service 
#ec2_endpoint 
#ec2_ok_banner 
#cinder_user 
#cinder_roles 
#cinder_service 
#cinder_endpoint 
#cinder_ok_banner 
#cinder_user 
#quantum_roles 
#quantum_service 
#quantum_endpoint 
#quantum_ok_banner 
###########################################################################
# @Cloud Converge Powered By Cloud Hyd.                                   #
###########################################################################

