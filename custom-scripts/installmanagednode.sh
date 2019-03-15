#!/bin/bash

managedLicenseKey="$1"
seedIp="$2"
seedAuthToken="$3"
initialEnvironmentAdminSecret="$4"
nodeId="$5"
fqdn="$6"
installerDownloadUrl="$7"

LOGFILE='/tmp/install-managed-extension.log'
log() {
    echo $1 >> $LOGFILE
}


log "run installmanagednode.sh"

log 'prepare datadisks'
sudo bash prepare_vm_disks.sh 1>> $LOGFILE

log 'download latest installer'
wget "$installerDownloadUrl" -O /tmp/dt-mgd-install.sh 1>> $LOGFILE

log 'execute installer'
sudo sh /tmp/dt-mgd-install.sh --install-silent --license "$managedLicenseKey" --seed-ip "$seedIp" --seed-auth "$seedAuthToken" --datastore-dir /datadisks/disk1/dynatrace --svr-datastore-dir /datadisks/disk2/dynatrace  1>> $LOGFILE

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
            log "[WARNING] retry in $waitTime minute(s) to ensure server is responsive..."
            sleep "$waitTime""m"
        fi
    done
  
fi

log 'finished successful'
echo "success"