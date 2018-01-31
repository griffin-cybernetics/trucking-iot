#!/bin/bash

echo "Starting the Registry service"

scriptDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

# Restart via Ambari
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo": {"context" :"Start Registry"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/REGISTRY | python $scriptDir/wait-until-done.py

# Restart via local binary
#registry=$(find / -type f -wholename '/usr/hd*/registry' -print -quit 2> /dev/null)
#$registry stop
#$registry clean
#$registry start
