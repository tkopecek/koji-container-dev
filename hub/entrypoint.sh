#!/bin/bash

# No need to edit these files if using docker compose v2
if [ "${ENTRYPOINT_SKIP_CONFIG}" != "True" ]
then
    sed -e "s/DBHost.*/DBHost = $HOSTIP/" -i /etc/koji-hub/hub.conf
    sed -e "s/KojiHubURL.*/KojiHubURL = http:\/\/$HOSTIP:8080\/kojihub/" -i /etc/kojiweb/web.conf
    sed -e "s/KojiFilesURL.*/KojiFilesURL = http:\/\/$HOSTIP:8080\/kojifiles/" -i /etc/kojiweb/web.conf
fi

httpd &
sleep 1
tail -f /var/log/httpd/ssl_error_log
