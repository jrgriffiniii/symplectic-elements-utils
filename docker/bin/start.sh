#!/bin/bash

DOCKER_IMAGE=mcr.microsoft.com/mssql/server:2017-latest
SA_PASSWORD="<YourStrong!Passw0rd>"
MSSQL_PID=Enterprise
DOCKER_CONTAINER=sqlenterprise
DOCKER_HOSTNAME=sqlenterprise

/usr/bin/env docker pull \
  $DOCKER_IMAGE

/usr/bin/env docker run \
  --name $DOCKER_CONTAINER \
  --hostname $DOCKER_HOSTNAME \
  --publish 1433:1433 \
  --env 'ACCEPT_EULA=Y' \
  --env "SA_PASSWORD=$SA_PASSWORD" \
  --env "MSSQL_PID=$MSSQL_PID" \
  --detach \
  --mount type=bind,source="$(pwd)"/imports,target=/imports \
  $DOCKER_IMAGE
