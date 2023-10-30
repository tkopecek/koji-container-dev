# Crude non-root [koji](https://pagure.io/koji) dev environment with podman

## Limitations

This is good environment for testing most of the functionalities. Nevertheless,
specially those capabilities related to image building (oz/imagefactory/kiwi)
are quite limited or not working at all due to need to run libvirt, etc.

## Prerequisities

It is being used on latest fedora, but that shouldn't be a stopper.
Basically, podman and make are needed. Optionally, podman-compose could be also used.

## Building

* If you want to use self-signed certification authorities (e.g. for testing builds
  from your https+git SCM), copy those CA certs to ca-certs directory first. They'll
  get propagated to the container during next step.
* run `./build` (which just runs `podman build` for one-fit-for-all base image)
* run `./create_dirs` which will populate basedir (for hub directories) and
  `hub/data` for DB
* run `cp config config.local` for create your own config file and update `CODEDIR`
  path there manually to match your koji code checkout
* run `cd certs; make build gen-certs` for creating ssl certificates for hub/web,
  builder and admin accounts.

## Using

* run `./run-hub` - it will spawn postgres container `koji-postgres` and hub `koji-hub`.
  If you don't have any database dump or older db, basic database will be created.
* If you need to spawn also the builder, run `./run-builder`
* for CLI access you can directly use `./koji` in `cli` directory
* run `./run-kojira` - it will spawn separate container for debugging kojira
* Everything use code from `CODEDIR` from `config.local` file

## Tools

* `scripts` directory contain some helper scripts
* `setup_fedora_buildroot` - will create basic tags and external repo for
  fedora target. It is highly suggested to replace repo URL in the script with
  local mirror.

## Podman/docker compose v2

If you are using a recent version of Docker/Podman, you may be interested in using
the Docker Compose v2 compatible definition in `compose.yaml`

* run steps from the Building section.
* run `export KOJI_SRC_DIR=<your koji source code repo checkout>`
* run `podman-compose up` to start a database, hub, builder and kojira containers
