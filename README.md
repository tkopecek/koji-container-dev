# Crude non-root [koji](https://pagure.io/koji) dev environment with podman

## Description

[Koji](https://pagure.io/koji) is the software that builds RPM packages
for the Fedora project.

The contents of this repository supplies the user with an environment that
can be used to test Koji builds locally, without using the production
Koji build system. It is implemented with podman.

## Limitations

This is a good environment for testing most of the functionality. Nevertheless,
those capabilities related to image building (oz/imagefactory/kiwi) are quite
limited or not working at all due to the need to run libvirt, etc.

## Prerequisities

This is intended to be used on the latest fedora, but that shouldn't be a stopper.
Basically, podman and make are needed. Optionally, podman-compose could be also used.
The Apache HTTP Server is also needed, which if necessary, can be installed with:

```bash
sudo dnf install httpd -y
```

## Installing the Needed Code

This repositry uses the code in the Koji repository found here: https://pagure.io/koji. In order
to use this **Koji Container Development Tool** two GitHub repositories need to be obtained.

**Create MY_WORKING_DIR environment variable:**

The below examples expect the shell environment variable `MY_WORKING_DIR` to be set
to path of your working directory.

```bash
export MY_WORKING_DIR="${HOME}/my_working_directory"
```
**Clone the needed code:**

```bash
cd ${MY_WORKING_DIR}
git clone git@github.com:tkopecek/koji-container-dev.git
git clone https://pagure.io/koji.git
```

## Building

* If you want to use self-signed certification authorities (e.g. for testing builds
  from your https+git SCM), copy those CA certs to ca-certs directory first. They'll
  get propagated to the container during next step.
* Build the podman image:

  Use the `koji-container-dev/build` bash script, which just runs `podman build` for one-fit-for-all base image)

```bash
cd ${MY_WORKING_DIR}/koji-container-dev
./build
```

* Populate the `basedir` directory, for hub directories, and the `db/data`, for DB.

  Use the `koji-container-dev/create_dirs` bash script to create the needed directories.

```bash
cd ${MY_WORKING_DIR}/koji-container-dev
./create_dirs
```

* Create your own config file and update `CODEDIR`

Set the CODEDIR to match where you cloned the koji repository.

```bash
cd ${MY_WORKING_DIR}/koji-container-dev
cp config config.local
sed -i "s|your-path-to-directory|${MY_WORKING_DIR}/koji|g" config.local
```
* Create the ssl certificates for hub/web, builder and admin accounts.

```bash
cd ${MY_WORKING_DIR}/koji-container-dev/certs
make build gen-certs
```

## Using

* Spawn koji-dev pod which contains koji-postgres and koji-hub contianers

  Use the `koji-container-dev/run-hub` bash script to create the needed podman containers.

  If you don't have any database dump or older db a basic database will be created.

  **Note:** This command will not return to the CLI prompt. It will continue to log output
  to this terminal.

```bash
cd ${MY_WORKING_DIR}/koji-container-dev
./run-hub
```

* If you need to spawn also the builder, run `./run-builder`
* run `./run-kojira` - it will spawn separate container for debugging kojira
* Everything use code from `CODEDIR` from `config.local` file

## Run Koji CLI Commands

  While the `run-hub` script is running in one terminal open another terminal and
  use the `koji-container-dev/cli/koji` bash script to execute Koji commands including
  testing things are set up properly run `./koji hello`.

```bash
cd ${MY_WORKING_DIR}/koji-container-dev/cli
./koji hello
    yo, kojiadmin!

    You are using the hub at https://localhost:8081/kojihub (Koji 1.35.3)
    Authenticated via client certificate client.pem
```

## Tools

* `scripts` directory contain some helper scripts
* `setup_fedora_buildroot` - will create basic tags and external repo for
  fedora target. It is highly suggested to replace repo URL in the script with
  local mirror.

## Podman/docker compose v2

If you are using a recent version of Docker/Podman, you may be interested in using
the Docker Compose v2 compatible definition in `compose.yaml`

* run steps from the Building section.
* run `export KOJI_SRC_DIR=${MY_WORKING_DIR}/koji
* run `podman-compose up` to start a database, hub, builder and kojira containers

