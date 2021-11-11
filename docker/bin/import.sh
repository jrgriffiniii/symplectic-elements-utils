#!/bin/bash

export DOCKER_CONTAINER=sqlenterprise
export SA_PASSWORD="<YourStrong!Passw0rd>"
export IMPORT_DB=elements

export IMPORT_DIR=imports/data
for IMPORT in `ls $IMPORT_DIR/*bcp | sed 's/imports\///' | sed 's/data\///' | sed 's/\.bcp//'`
do
  IMPORT_SCHEMA="${IMPORT}_schema.xml"
  IMPORT_FILE="${IMPORT}.bcp"
  IMPORT_TABLE="${IMPORT//elements_dbo_/}"

  echo "Importing the table ${IMPORT_TABLE} from ${IMPORT_FILE} using ${IMPORT_SCHEMA}..."

  /usr/bin/env docker exec \
    --interactive \
    --tty \
    $DOCKER_CONTAINER \
    /opt/mssql-tools/bin/bcp \
    $IMPORT_TABLE in "/imports/data/$IMPORT_FILE" \
    -f "/imports/data/$IMPORT_SCHEMA" \
    -d $IMPORT_DB \
    -S localhost \
    -U SA \
    -P $SA_PASSWORD

done
