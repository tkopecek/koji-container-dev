IMAGE_NAME = koji-cert-generator
CERTS_DIR_LOCAL = $(shell pwd)/certs
HUB_HOSTNAMES = localhost
FORCE = false
BUILD_ARGS = -t ${IMAGE_NAME}
CONTAINER_CMD ?= podman

ifeq (${FORCE}, true)
BUILD_ARGS := --no-cache ${BUILD_ARGS}
endif

.PHONY: build
build:
	${CONTAINER_CMD} build ${BUILD_ARGS} .

.PHONY: run
run:
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z -it ${IMAGE_NAME} /bin/bash

.PHONY: gen-certs
gen-certs:
	mkdir -p -m 777 $(CERTS_DIR_LOCAL)
	chmod -fR a+rw $(CERTS_DIR_LOCAL)
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z -e GEN_ROOT_CA=true -it ${IMAGE_NAME}
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z \
	           -e IS_HOST=true \
	           -e KOJI_USER="${HUB_HOSTNAMES}" \
	           -it ${IMAGE_NAME}
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z \
	           -e KOJI_USER="kojibuilder" \
	           -it ${IMAGE_NAME}
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z \
	           -e KOJI_USER="kojira" \
	           -it ${IMAGE_NAME}
	${CONTAINER_CMD} run --rm -v $(CERTS_DIR_LOCAL):/opt/certs:z \
	           -e KOJI_USER="kojiadmin" \
	           -it ${IMAGE_NAME}
	${CONTAINER_CMD} unshare chmod -fR a+rw $(CERTS_DIR_LOCAL)
	mkdir -p ../hub/certs
	rm -f ../hub/certs/*
	ln $(CERTS_DIR_LOCAL)/root-ca/koji-ca.crt ../hub/certs/koji-ca.crt
	ln $(CERTS_DIR_LOCAL)/localhost/localhost.crt ../hub/certs/koji-hub.crt
	ln $(CERTS_DIR_LOCAL)/localhost/localhost.key ../hub/certs/koji-hub.key
	mkdir -p ../builder/certs
	rm -f ../builder/certs/*
	ln $(CERTS_DIR_LOCAL)/kojibuilder/kojibuilder.pem ../builder/certs/kojibuilder.pem
	mkdir -p ../kojira/certs
	rm -f ../kojira/certs/*
	ln $(CERTS_DIR_LOCAL)/kojira/kojira.pem ../kojira/certs/kojira.pem

clean: clean-certs clean-image

clean-image:
	${CONTAINER_CMD} rmi -i ${IMAGE_NAME}

clean-certs:
	rm -rf $(CERTS_DIR_LOCAL)
	rm -f ../hub/certs/koji-ca.crt
	rm -f ../hub/certs/koji-hub.crt
	rm -f ../hub/certs/koji-hub.key
	rm -f ../builder/certs/kojibuilder.pem
