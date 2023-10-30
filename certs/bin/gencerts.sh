#!/bin/bash -x
#
# generate ssl certificates for koji
FORCE=${FORCE:-false}
GEN_ROOT_CA=${GEN_ROOT_CA:-false}
ROOT_CN=${ROOT_CN:-Koji CA}
KOJI_USER=${KOJI_USER:-koji}
IS_HOST=${IS_HOST:-false}
ARGS=""
SUB_CMD=--help
CMD=koji-ssl-admin
CERT_DIR=$(pwd)/certs

mkdir -p -m 777 $CERT_DIR

if ${FORCE}; then
    echo "-> FORCE run..."
    ARGS="--force"
fi

if ${GEN_ROOT_CA}; then
    echo "-> generate root CA..."
    SUB_CMD="new-ca"
    $CMD $SUB_CMD $ARGS --common-name "${ROOT_CN}"
    chmod 666 koji-ca.key
    mkdir -p -m 777 $CERT_DIR/root-ca
    cp koji-ca.* $CERT_DIR/root-ca
    exit 0
fi

if ${IS_HOST}; then
    echo "-> This is a HOST..."
    SUB_CMD="server-csr"
elif [[ $KOJI_USER = *" "* ]]; then
    echo "ERROR: multiple values in KOJI_USER is not allowed when it is not a host." 1>&2
    exit 1
else
    echo "-> This is a CLIENT."
    SUB_CMD="user-csr"
fi

echo "-> generate certificate request..."
$CMD $SUB_CMD $ARGS ${KOJI_USER}


echo "-> sign certificate ..."
SUB_CMD="sign"
$CMD $SUB_CMD $ARGS --ca-key=${CERT_DIR}/root-ca/koji-ca.key --ca-cert=${CERT_DIR}/root-ca/koji-ca.crt ${KOJI_USER%% *}.csr

mkdir -p -m 777 $CERT_DIR/${KOJI_USER%% *}
cat ${KOJI_USER%% *}.crt ${KOJI_USER%% *}.key > ${KOJI_USER%% *}.pem
cp ${KOJI_USER%% *}.* ${CERT_DIR}/${KOJI_USER%% *}

if [ ${IS_HOST} != true ]; then
    cp ${KOJI_USER%% *}_browser_cert.p12 ${CERT_DIR}/${KOJI_USER%% *}
    cp ${CERT_DIR}/root-ca/koji-ca.crt ${CERT_DIR}/${KOJI_USER%% *}/server-ca.crt
else
    cat ${KOJI_USER%% *}.crt ${CERT_DIR}/root-ca/koji-ca.crt > ${CERT_DIR}/${KOJI_USER%% *}/${KOJI_USER%% *}.bundle.crt
fi
