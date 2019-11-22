#!/bin/bash


managedLicenseKey="$1"
initialEnvironmentName="$2"
initialEnvironmentAdminFirstname="$3"
initialEnvironmentAdminLastname="$4"
initialEnvironmentAdminEmail="$5"
initialEnvironmentAdminSecret="$6"
nodeId="$7"
fqdn="$8"
installerDownloadUrl="$9"

LOGFILE='/tmp/install-managed-extension.log'
log() {
    echo $1 >> $LOGFILE
}


log "run installmanaged.sh"

log 'prepare datadisks'

sudo bash prepare_vm_disks.sh >> $LOGFILE

log 'download latest installer'
wget "$installerDownloadUrl" -O /tmp/dt-mgd-install.sh 1>> $LOGFILE

log 'execute installer'
sudo sh /tmp/dt-mgd-install.sh --timeouts fw:120 --install-silent --license "$managedLicenseKey" --datastore-dir /datadisks/disk1/dynatrace --svr-datastore-dir /datadisks/disk2/dynatrace --cas-datastore-dir /datadisks/disk3/dynatrace --els-datastore-dir /datadisks/disk4/dynatrace --initial-environment "$initialEnvironmentName" --initial-first-name "$initialEnvironmentAdminFirstname" --initial-last-name "$initialEnvironmentAdminLastname" --initial-email "$initialEnvironmentAdminEmail" --initial-pass "$initialEnvironmentAdminSecret"  1>> $LOGFILE

publicIp=""
if [ -z "$fqdn" ] 
then
    log "FQDN not provided"
else
    publicIp=$(host "$fqdn"|grep " has address "|cut -d" " -f4)

    log "Resolved ip ($publicIp) from FQDN($fqdn)"
fi

if [ -z "$publicIp" ] 
then
    log "[WARNING] Couldn't resolve public IP, skip config to define endpoint for webui"
else
    for i in {1..3}
    do
        log 'try set nodes public ip'
        if curl --fail -X PUT --insecure -u "admin":"$initialEnvironmentAdminSecret" "https://127.0.0.1:8021/api/v1.0/onpremise/endpoint/publicIp/domain/$nodeId" -d "$publicIp" -H "Content-Type: application/json" 1>> $LOGFILE; then
            break
        else
            waitTime=$((i*3))
            log "[WARNING] unable to set public ip, retry in $waitTime minute(s) to ensure server is responsive..."
            sleep "$waitTime""m"
        fi
    done
fi

log 'get api-token'
token=$(wget --http-user=admin --http-password="$initialEnvironmentAdminSecret"  -q https://127.0.0.1:8021/api/v1.0/onpremise/tokens/ --no-check-certificate -O - | grep -o 'tokenId":".[^"]*' | cut -b11-)

if [ -z "$token" ] 
then
    log '[ERROR] could not retrieve api-token'
    exit -1
else
    echo "$token"
    log 'finished successfully'
fi