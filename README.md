# Docker image with the pysmurf server for the SMuRF project

## Description

This docker image, named **pysmurf-server** contains pysmurf, firmware files (mcs and pyrogue's zip) and default configuration files (yml) for stable firmware versions.

It is based on the **pysmurf-server-base** docker image.

## Source code

The firmware files are checkout from the SLAC's github repositories https://github.com/slaclab/cryo-det.

The configuration files are checkout from the SMuRF's configuration repository https://github.com/slaclab/smurf_cfg.git.

If needed files are not available on any of the github repositories, then then are added to this repository under the [local_files](local_files) directory.

## Tag convention

The tags used on this repository have the following 3-digit format:

```
R<A>.<B>.<C>
```

Where:
- **A**: is incremented when a new pysmurf-server-base image version is used,
- **B**: is incremented when a new firmware mcs, or pyrogue's zip file is used,
- **C**: is incremented when a new configuration file is used, or when defaults server arguments are changed.

Notes:
- All digits start at zero, expect for `A` which starts at one,
- Whenever a digit in incremented, all the rightmost digits are reset to zero.

For example, assume that version `R3.1.0` correspond to a certain release version; if the `pysmurf-server-base` image version is upgraded, then the following release version will be `R4.0.0`. If later, the mcs file is changed, then the following release version will be `R4.1.0`. If later the pyrogue's zip file is changed, the next release version will be `R4.2.0`. Updating the configuration file will generate a release version `R4.2.1`. Finally, modifying the server arguments (like for example adding/removing `--disable-bayX`) will generated a release version `R4.2.2`. And so on.

The file [RELEASES.md](RELEASES.md) contains a list of released version with a description for each one. Similar information can be found in the repository's [releases](https://github.com/slaclab/pysmurf-stable-docker/releases) page.

## Building the image

When a tag is pushed to this github repository, a new Docker image is automatically built and push to its [Dockerhub repository](https://hub.docker.com/r/tidair/pysmurf-server) using travis.

The resulting docker image is tagged with the same git tag string (as returned by `git describe --tags --always`).

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