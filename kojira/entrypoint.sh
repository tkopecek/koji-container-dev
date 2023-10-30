#!/bin/bash

# No need to edit this file if using docker compose v2
if [ "${ENTRYPOINT_SKIP_CONFIG}" != "True" ]
then
    sed -e "s/server=.*/server=https:\/\/$HOSTIP:8081\/kojihub/" -i /opt/cfg/kojira.conf
    sed -e "s/topurl=.*/topurl=http:\/\/$HOSTIP:8080\/kojifiles/" -i /opt/cfg/kojira.conf
fi

cd /opt/koji/util
python3 kojira --debug --fg --force-lock -c /opt/cfg/kojira.conf
