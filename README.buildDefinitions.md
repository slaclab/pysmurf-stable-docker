# How to define the docker image parameters

## Description

The docker image generated from this repository built based on a user defined configuration, using the [definitions.sh](definitions.sh) file. In that file, the user can define:
- The `pysmurf-server-base` image version,
- The firmware image (`mcs`) file,
- The pyrogue definitnion (`zip`) file,
- The configuration (`yml`) file, and
- The startup arguments

So, the flow to release a new image is:
- Update the [definitions.sh](definitions.sh) file and push it.
- Run the [validate.sh](validate.sh) script to verify that you definition file is correct. If there are errors, fix them before moving on.
- Push a new tag (see [README.tagNamingConvention.md](README.tagNamingConvention.md) for tag naming convention).

A new docker image will be automatically generated (using travis) following the given definitions. The resulting image will be pushed to its [Dockerhub repository](https://hub.docker.com/r/tidair/pysmurf-server). Also, at the end of this process:
- the release table located [here](RELEASES.md) will be automatically updated,
- a new release will be generated [here](https://github.com/slaclab/pysmurf-stable-docker/releases).

## Definition structure

The the [definitions.sh](definitions.sh) file contains a series of variables that define all the docker image parameters:

### The `pysmurf-server-base` image version

The variable `pysmurf_server_base_version` defines the version of the `pysmurf-server-base` image to be used.

For example, to use version `v4.0.0` it must be defined like this:
```
pysmurf_server_base_version=v4.0.0
```

Additionally, the variable `pysmurf_repo` points to the pysmurf repository. Normally, you won't need to modify this variable.

### The firmware image (`mcs`) file

The `mcs` file if downloaded from the firmware's github repository, from the assets of a given tagged release. These three variables are used to defined which file to use

- `mcs_repo`: points to the firmware's github repository,
- `mcs_repo_tag`: points to the specific tagged release version to use, and
- `mcs_file_name`: defines the name of the `mcs` file.

For example:
```
mcs_repo=https://github.com/slaclab/cryo-det
mcs_repo_tag=MicrowaveMuxBpEthGen2_v1.2.14
mcs_file_name=MicrowaveMuxBpEthGen2-0x00000016-20190724191903-mdewart-8234f45.mcs.gz
```

A local `mcs` can be used, instead of downloading it from github. In that case, the file must be added to the [local_files](local_files) directory of this repository, and the variable `mcs_repo_tag` must be empty.

### The pyrogue definitnion (`zip`) file

The `zip` file if downloaded from the firmware's github repository, from the assets of a given tagged release. These three variables are used to defined which file to use

- `zip_repo`: points to the firmware's github repository,
- `zip_repo_tag`: points to the specific tagged release version to use, and
- `zip_file_name`: defines the name of the `zip` file.

In general, this zip file will come from the same repository and tag version as the `mcs` file. In that case, the user can define these variables in this way (they must be define after the `mcs` file definitions)
```
zip_repo=${mcs_repo}
zip_repo_tag=${mcs_repo_tag}
zip_file_name=rogue_MicrowaveMuxBpEthGen2_v1.2.14.zip
```

A local `zip` can be used, instead of downloading it from github. In that case, the file must be added to the [local_files](local_files) directory of this repository, and the variable `zip_repo_tag` must be empty.

### The configuration (`yml`) file

The `yml` file if downloaded from the SMuRF configuration github repository, from a given tagged release. These three variables are used to defined which file to use

- `yml_repo`: points to the SMuRF configuration github repository,
- `yml_repo_tag`: points to the specific tagged release version to use, and
- `yml_file_name`: defines the name of the `mcs` file.

For example:
```
yml_repo=https://github.com/slaclab/smurf_cfg
yml_repo_tag=v0.0.2
yml_file_name=defaults_lbonly_c03_bay0.yml
```

A local `yml` can be used, instead of downloading it from github. In that case, the file must be added to the [local_files](local_files) directory of this repository, and the variable `yml_repo_tag` must be empty.

### The startup arguments

Custom startup arguments can be defined using the variable `server_args`. These arguments will be added as defaults startup arguments to the docker image entrypoint. The arguments must be defined as a single string, with argument separated by spaces.

For example:
```
server_args="--disable-bay1"
```
