#!/bin/bash

# Jump to the project directory for executing SBT commands
projDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd)"
cd $projDir

# Variables
projVer=$(cat version.sbt | grep '".*"' -o | sed 's/"//g')
#nifiLibDir=$(find / -type d -path "/usr/*/nifi/lib" -print -quit 2> /dev/null)

echo "Building the trucking-nifi-bundle project"
sbt nifiBundle/compile

echo "Installing the NiFi nar to NiFi.  NiFi will be restarted"
scp -f $projDir/trucking-nifi-bundle/nifi-trucking-nar/target/nifi-trucking-nar-$projVer.nar gcs-nifi-c02n01.local.griffin-nc.com:/usr/hdf/current/nifi/lib
scp -f $projDir/trucking-nifi-bundle/nifi-trucking-nar/target/nifi-trucking-nar-$projVer.nar gcs-nifi-c02n02.local.griffin-nc.com:/usr/hdf/current/nifi/lib
scp -f $projDir/trucking-nifi-bundle/nifi-trucking-nar/target/nifi-trucking-nar-$projVer.nar gcs-nifi-c02n03.local.griffin-nc.com:/usr/hdf/current/nifi/lib
scp -f $projDir/trucking-nifi-bundle/nifi-trucking-nar/target/nifi-trucking-nar-$projVer.nar gcs-nifi-c02n04.local.griffin-nc.com:/usr/hdf/current/nifi/lib

echo "Restarting NiFi via Ambari"
curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context": "Stop NIFi"}, "ServiceInfo": {"state": "INSTALLED"}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/NIFI | python $projDir/scripts/wait-until-done.py
curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context": "Start NIFi"}, "ServiceInfo": {"state": "STARTED"}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/NIFI | python $projDir/scripts/wait-until-done.py

# Restart via local binaries
#nifiSh=$(find / -type f -wholename "/usr/*/nifi.sh" -print -quit 2> /dev/null)
#$nifiSh restart
