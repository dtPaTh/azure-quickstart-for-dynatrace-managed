#!/bin/bash

managedLicenseKey="$1"
seedIp="$2"
seedAuthToken="$3"
initialEnvironmentAdminSecret="$4"
nodeId="$5"
installerDownloadUrl="$6"

LOGFILE='/tmp/install-managed-extension.log'

log() {
    echo "[CustomScript] $1" >> $LOGFILE
}

log "run installmanagednode.sh"

log 'prepare datadisks'
sudo bash prepare_vm_disks.sh 1>> $LOGFILE

log 'download latest installer'
if curl --fail --silent --show-error "$installerDownloadUrl" --output /tmp/dt-mgd-install.sh; then 
    log 'done.'
else
    log 'failed.'
    exit -1
fi

log 'execute installer'
 
 #--binaries-dir <path>     full path to Dynatrace binaries
 #--datastore-dir <path>    full path to Dynatrace data
 #--cas-datastore-dir <path> full path to Dynatrace metrics repository
 #--els-datastore-dir <path> full path to Dynatrace Elasticsearch store
 #--svr-datastore-dir <path> full path to Dynatrace server store
 #--rpl-datastore-dir <path> full path to Dynatrace session replay store
sudo sh /tmp/dt-mgd-install.sh --timeouts fw:120 --install-silent --license "$managedLicenseKey" --seed-ip "$seedIp" --seed-auth "$seedAuthToken" --datastore-dir /datadisks/disk1/dynatrace --svr-datastore-dir /datadisks/disk2/dynatrace --cas-datastore-dir /datadisks/disk3/dynatrace --els-datastore-dir /datadisks/disk4/dynatrace  1>> $LOGFILE

publicIp=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2019-06-01&format=text")

if [ -z "$publicIp" ] 
then
    log "[WARNING] Couldn't resolve public Ip, skip config to define endpoint for webui"
else
    log 'try set nodes public ip'
    curl --fail --silent -X PUT --insecure -u "admin":"$initialEnvironmentAdminSecret" "https://127.0.0.1:8021/api/v1.0/onpremise/endpoint/publicIp/domain/$nodeId" -d "$publicIp" -H "Content-Type: application/json" 1>> $LOGFILE
fi

log 'finished successful'
echo "success"