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

function get_url_prom {
    echo "${PROM_PUSHGATEWAY_URL}/metrics/job/pg_dump/instance/`hostname`${PROM_PUSHGATEWAY_LABELS}"
}

function log_start_backup {
    echo $(log_format "Start backup") >> ${LOG_PATH}

    if ! [ -z "${PROM_PUSHGATEWAY_URL}" ]; then
        cat <<EOF | curl --data-binary @- $(get_url_prom)
# HELP pg_dump_process The script works or not
# TYPE pg_dump_process gauge
pg_dump_process 1
EOF
    fi
}

function log_stop_backup {
    if ! [ -z "${PROM_PUSHGATEWAY_URL}" ]; then
        cat <<EOF | curl --data-binary @- $(get_url_prom)
# HELP pg_dump_process The script works or not
# TYPE pg_dump_process gauge
pg_dump_process 0
# HELP pg_dump_last_state The last status code of exit
# TYPE pg_dump_last_state gauge
pg_dump_last_state ${STATE_ERROR}
EOF
    fi

    echo $(log_format "Stop backup. Status: ${STATE_ERROR}; Duration: ${TIME_DURATION} sec; Size: ${SIZE_BACKUP} bytes;") >> ${LOG_PATH}
}

function log_format {
    echo "[`date --rfc-3339=seconds`] $1"
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

if ! [ -z "${LOG_DISABLE}" ]; then
    LOG_PATH=/dev/null
else
    LOG_PATH=/var/log/pg_backup/${LOG_FILE:=pg_backup.log}
fi

log_start_backup

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

#  Process
## The status code for all backup operation
STATE_ERROR=0

db_list=$(psql --no-align --quiet --tuples-only ${PG_CONFIG_STRING} -c "${query}" 2>>${LOG_PATH})
STATE_ERROR=`expr $STATE_ERROR + $?`

## Clear backup dir
rm -rf ${DIR_TO_BACKUP}/*

for db_name in $db_list
do
    pg_dump -Fd -j 10 -f ${DIR_TO_BACKUP}/$db_name ${PG_CONFIG_STRING} 2>>${LOG_PATH}
    STATE_ERROR=`expr $STATE_ERROR + $?`
done

## Roles
if [ -z "${IS_NOT_ROLES}" ]; then
    pg_dumpall -r ${PG_CONFIG_STRING} 2>>${LOG_PATH} | gzip - > ${DIR_TO_BACKUP}/roles.sql.gz
    STATE_ERROR=`expr $STATE_ERROR + $?`
fi

# Logs
TIME_DURATION=`expr $(date +%s) - ${TIME_START}`
SIZE_BACKUP=`du -sb ${DIR_TO_BACKUP} | cut -f1`

log_stop_backup

exit ${STATE_ERROR}
