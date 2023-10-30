#!/bin/bash

BODY='<?xml version="1.0" encoding="utf-8"?><methodCall><methodName>hello</methodName><params></params></methodCall>'

response=$(curl \
--no-progress-meter \
-X POST \
-H 'Content-Type: text/xml' \
-d "${BODY}" \
http://127.0.0.1:80/kojihub/)

returnCode=$?

if [ "${returnCode}" -ne 0 ]
then
    echo "curl exited with error: '${returnCode}'"
    exit ${returnCode}
fi

if [[ "${response}" =~ '<fault>' ]]
then
   echo "FAULT ENCOUNTERED:"
   echo ${response}
   exit 1
fi

if [[ "${response}" =~ 'Hello World' ]]
then
    echo "Koji Hub says, 'Hello World'..."
    exit 0
else
    echo ${response}
    exit 1
fi