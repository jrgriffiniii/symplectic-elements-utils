#!/bin/bash

/usr/bin/env docker run \
  --name sqlenterprise \
  --hostname sqlenterprise \
  --publish 1433:1433 \
  --env 'ACCEPT_EULA=Y' \
  --env 'SA_PASSWORD=<YourStrong!Passw0rd>' \
  --env 'MSSQL_PID=Enterprise' \
  --detach mcr.microsoft.com/mssql/server:2017-latest
