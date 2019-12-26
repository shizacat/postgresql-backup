#!/bin/bash

# Backup postgresql
# Version: 1.0

function quote_string_by_element {
    result=""
    while IFS=', ' read -ra LIST; do
        for i in "${LIST[@]}"; do
            if [ -z "${result}" ]; then
                result="'${i}'"
            else
                result="${result}, '${i}'"
            fi
        done
    done <<< "$1"
    echo ${result}
}

# Include config
CONFIG_PATH=${CONFIG_PATH:-${1:-config}}

if ! [ -f "${CONFIG_PATH}" ]; then
    echo "Config file '${CONFIG_PATH}' not found"
    exit 1
fi

source ${CONFIG_PATH}

# Setup
TIME_START=$(date +%s)

if ! [ -d ${DIR_TO_BACKUP} ]; then
    echo "Directory for backup not exists"
    exit 1
fi

PG_CONFIG_STRING=""

if ! [ -z "${DB_URL}" ]; then
    PG_CONFIG_STRING="--dbname=${DB_URL}"
else
    echo "Need setup the DB_URL for access to host"
    exit 1
fi

query="SELECT datname FROM pg_database"
if ! [ -z "${ONLY_INCLUDE}" ]; then
    ONLY_INCLUDE_QUOTE=$(quote_string_by_element "${ONLY_INCLUDE}")
    query="${query} WHERE datname IN (${ONLY_INCLUDE_QUOTE})"
else
    if ! [ -z "${EXCLUDE}" ]; then
        EXCLUDE_QUOTE=$(quote_string_by_element "${EXCLUDE}")
        query="${query} WHERE datname NOT IN (${EXCLUDE_QUOTE})"
    fi
fi
db_list=$(psql --no-align --quiet --tuples-only ${PG_CONFIG_STRING} -c "${query}")

#  Process
## The status code for all backup operation
STATE_ERROR=0
## The buffer for log
STATE_LOG=""

## Clear backup dir
rm -rf ${DIR_TO_BACKUP}/*

for db_name in $db_list
do
    pg_dump -Fd -j 10 -f ${DIR_TO_BACKUP}/$db_name ${PG_CONFIG_STRING}
    STATE_ERROR=`expr $STATE_ERROR + $?`
done

## Roles
if [ -z "${IS_NOT_ROLES}" ]; then
    pg_dumpall -r ${PG_CONFIG_STRING} | gzip - > ${DIR_TO_BACKUP}/roles.sql.gz
    STATE_ERROR=`expr $STATE_ERROR + $?`
fi

# Logs
TIME_DURATION=`expr $(date +%s) - ${TIME_START}`

exit ${STATE_ERROR}
