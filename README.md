# Docker image with the pysmurf server for the SMuRF project

## Description

This docker image, named **pysmurf-server** contains pysmurf, firmware files (mcs and pyrogue's zip) and default configuration files (yml) for stable firmware versions.

It is based on the **pysmurf-server-base** docker image.

## Source code

The firmware files are checkout from the SLAC's github repositories https://github.com/slaclab/cryo-det.

The configuration files are checkout from the SMuRF's configuration repository https://github.com/slaclab/smurf_cfg.git.

If needed files are not available on any of the github repositories, then then are added to this repository under the [local_files](local_files) directory.

## Tag naming convention

The naming convention followed for tags is describe in [README.tagNamingConvention.md](README.tagNamingConvention.md).

## Building the image

When a tag is pushed to this github repository, a new Docker image is automatically built and push to its [Dockerhub repository](https://hub.docker.com/r/tidair/pysmurf-server) using travis.

The resulting docker image is tagged with the same git tag string (as returned by `git describe --tags --always`).

The image is built based on a user defined configuration, using the [definitions.sh](definitions.sh) file. In that file, the user can define:
- The `pysmurf-server-base` image version,
- The firmware image (mcs) file,
- The pyrogue definitnion (zip) file,
- The configuration (yml) file, and
- The startup arguments

For more information about how to defined these parameters see [README.buildDefinitions.md](README.buildDefinitions.md).

## How to get the container

To get the docker image, first you will need to install the docker engine in you host OS. Then you can pull a copy by running:

```
docker pull tidair/pysmurf-server:<TAG>
```

Where **TAG** represents the specific tagged version you want to use.

## Running the container

Each docker image defines which it's entry point. By default, the entry point calls the `start_server.sh` (which comes within the `pysmurf-server-base` image) script with some pre-defined arguments. You can however, overwrite any of the arguments and/or adding new one by passing them at the end of the docker run command.

You start the container with a command like this one:

```
docker run -ti --rm \
    -v <local_data_dir>:/data \
    tidair/pysmurf-server:<TAG> \
    <server_arguments>
```

Where:
- **local_data_dir**: is a local directory in the host CPU which contains the directories `smurf_data` where the data is going to be written to,
- **TAG**: is the tagged version of the container your want to run,
- **server_arguments**: additional and/or redefined server arguments.