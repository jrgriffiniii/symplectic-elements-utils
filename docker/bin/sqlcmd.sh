#!/bin/bash

/usr/bin/env docker exec \
  --interactive \
  --tty \
  sqlenterprise \
  /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U SA \
  -P '<YourStrong!Passw0rd>'
