#!/bin/bash

managedLicenseKey="$1"
initialEnvironmentName="$2"
initialEnvironmentAdminFirstname="$3"
initialEnvironmentAdminLastname="$4"
initialEnvironmentAdminEmail="$5"
initialEnvironmentAdminSecret="$6"
installerDownloadUrl="$7"


LOGFILE='/tmp/install-managed-extension.log'

log() {
    echo "[CustomScript] $1" >> $LOGFILE
}

log "run installmanaged.sh"

log 'prepare datadisks'

sudo bash prepare_vm_disks.sh >> $LOGFILE

log 'download latest installer...'
if curl --location --fail --silent --show-error "$installerDownloadUrl" --output /tmp/dt-mgd-install.sh ; then
    log 'done.'
else
    log 'failed.'
    exit -1
fi


log 'execute installer'
sudo sh /tmp/dt-mgd-install.sh --timeouts fw:120 --install-silent --license "$managedLicenseKey" --datastore-dir /datadisks/disk1/dynatrace --svr-datastore-dir /datadisks/disk2/dynatrace --cas-datastore-dir /datadisks/disk3/dynatrace --els-datastore-dir /datadisks/disk4/dynatrace --initial-environment "$initialEnvironmentName" --initial-first-name "$initialEnvironmentAdminFirstname" --initial-last-name "$initialEnvironmentAdminLastname" --initial-email "$initialEnvironmentAdminEmail" --initial-pass "$initialEnvironmentAdminSecret"  1>> $LOGFILE

publicIp=$(curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2019-06-01&format=text")

if [ -z "$publicIp" ] 
then
    log "[WARNING] Couldn't resolve public IP, skip config to define endpoint for webui"
else
    log 'try set nodes public ip'
    curl --fail --silent --insecure --user "admin":"$initialEnvironmentAdminSecret"  -X PUT "https://127.0.0.1:8021/api/v1.0/onpremise/endpoint/publicIp/domain/1" -d "$publicIp" -H "Content-Type: application/json" 1>> $LOGFILE;
fi

log 'get api-token'
token=$(curl --fail --silent --insecure --user admin:"$initialEnvironmentAdminSecret" "https://127.0.0.1:8021/api/v1.0/onpremise/tokens/"  | grep -o 'tokenId":".[^"]*' | cut -b11- | head -n1)

if [ -z "$token" ] 
then
    log '[ERROR] could not retrieve api-token'
    echo 'Could not rereive api-token'
   
    exit -1
else
    log 'finished successfully'
    echo "$token" #write token to std output, so it can be passed over to node installers
fi

exit 0
