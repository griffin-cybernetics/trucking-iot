#!/bin/bash

# Root project directory
projDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd)"

echo "Stopping NiFi"
curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context": "Stop NIFi"}, "ServiceInfo": {"state": "INSTALLED"}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/NIFI | python $projDir/scripts/wait-until-done.py

# Built-in flows that can be used are:
#
# nifi-to-nifi.xml.gz
# nifi-to-nifi-with-schema.xml.gz
# kafka-to-kafka.xml.gz
# kafka-to-kafka-with-schema.xml.gz
# kafka-to-kafka-with-schema-2.xml.gz
scp -f $projDir/trucking-nifi-templates/flows/kafka-to-kafka-with-schema-2.xml.gz gcs-nifi-c02n01.local.griffin-nc.com:/tmp
ssh root@gcs-nifi-c02n01.local.griffin-nc.com

echo "Importing NiFi flow.  Existing flow backed up to flow.xml.gz.bak"
mv /var/lib/nifi/conf/flow.xml.gz /var/lib/nifi/conf/flow.xml.gz.bak
cp -f /tmp/kafka-to-kafka-with-schema-2.xml.gz /var/lib/nifi/conf/flow.xml.gz

echo "Starting NiFi via Ambari"
curl -u admin:admin -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context": "Start NIFi"}, "ServiceInfo": {"state": "STARTED"}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/NIFI | python $projDir/scripts/wait-until-done.py
