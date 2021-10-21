#!/bin/bash

export DOCKER_IMAGE=mcr.microsoft.com/mssql/server:2017-latest
export SA_PASSWORD="<YourStrong!Passw0rd>"
export MSSQL_PID=Enterprise
export DOCKER_CONTAINER=sqlenterprise
export DOCKER_HOSTNAME=sqlenterprise

/usr/bin/env docker exec \
  --interactive \
  --tty \
  $DOCKER_CONTAINER \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P $SA_PASSWORD
