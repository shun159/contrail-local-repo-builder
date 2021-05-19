#!/bin/sh

DOCKER_USERNAME=${DOCKER_USERNAME:=admin}
DOCKER_PASSWORD=${DOCKER_PASSWORD:=password}
DOCKER_REGISTRY=${DOCKER_REGISTRY:=localhost:2375}
DOCKER_REGISTRY_NAME=${DOCKER_REGISTRY_NAME:=$DOCKER_REGISTRY}
sleep 10
printenv
reg-tool \
  --username $DOCKER_USERNAME \
  --password $DOCKER_PASSWORD \
  --registry $DOCKER_REGISTRY \
  --registry-name $DOCKER_REGISTRY_NAME \
  --targets /images.txt
