#!/bin/bash

scriptDir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

# Start via Ambari
echo "Starting the Kafka service"
curl -u admin:admin -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo": {"context" :"Start Kafka"}, "Body": {"ServiceInfo": {"state": "STARTED"}}}' http://gcs-ambari-c02n01.local.griffin-nc.com:8080/api/v1/clusters/gcscluster02/services/KAFKA | python $scriptDir/wait-until-done.py

# Start via local package
#$(find / -type f -wholename '/usr/hd*/kafka' -print -quit 2> /dev/null) start

ssh root@gcs-kafka-c02n01.local.griffin-nc.com

kafkaTopicsSh=$(find / -type f -wholename '/usr/hd*/kafka-topics.sh' -print -quit 2> /dev/null)

#echo "Deleting existing Kafka topics"
$kafkaTopicsSh --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --delete --topic trucking_data_truck 2> /dev/null
$kafkaTopicsSh --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --delete --topic trucking_data_traffic 2> /dev/null
$kafkaTopicsSh --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --delete --topic trucking_data_joined 2> /dev/null
$kafkaTopicsSh --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --delete --topic trucking_data_driverstats 2> /dev/null

echo "Creating Kafka topics"
$kafkaTopicsSh --create --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --replication-factor 1 --partitions 1 --topic trucking_data_truck
$kafkaTopicsSh --create --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --replication-factor 1 --partitions 1 --topic trucking_data_traffic
$kafkaTopicsSh --create --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --replication-factor 1 --partitions 1 --topic trucking_data_joined
$kafkaTopicsSh --create --zookeeper gcs-zoo-c02n01.local.griffin-nc.com:2181,gcs-zoo-c02n02.local.griffin-nc.com:2181,gcs-zoo-c02n03.local.griffin-nc.com:2181 --replication-factor 1 --partitions 1 --topic trucking_data_driverstats

exit
