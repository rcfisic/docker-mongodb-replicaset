#!/bin/bash

for((i=1; i<=$1; i++))
do
  docker run -d --name mongodb$i mongo mongod --replSet rsmongodb
  MONGODB_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' mongodb$i)
  RS_MEMBERS="$RS_MEMBERS { _id: $i, host: \"$MONGODB_IP:27017\"},"
  echo "Create node: mongodb$i --> $MONGODB_IP"
done

RS_MEMBERS=${RS_MEMBERS:0:-1}
RS_CONFIG_SCRIPT="rsconf = { _id: \"rsmongodb\", members: [$RS_MEMBERS]};rs.initiate(rsconf);"

pause 3

docker exec mongodb1 mongo localhost:27017 --eval "$RS_CONFIG_SCRIPT" 
echo "MongoDB Replicaset initiated"
