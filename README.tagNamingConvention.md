# Tag Naming Convention

## Description

This document describe the naming convention use to tag the docker images.

## Naming convention

The tags used on this repository have the following 3-digit format:

```
v<A>.<B>.<C>
```

Where:
- **A**: is incremented when a new pysmurf-server-base image version is used,
- **B**: is incremented when a new firmware mcs, or pyrogue's zip file is used,
- **C**: is incremented when a new configuration file is used, or when defaults server arguments are changed.

Notes:
- All digits start at zero, expect for `A` which starts at one,
- Whenever a digit in incremented, all the rightmost digits are reset to zero.

For example, assume that version `v3.1.0` correspond to a certain release version; if the `pysmurf-server-base` image version is upgraded, then the following release version will be `v4.0.0`. If later, the mcs file is changed, then the following release version will be `v4.1.0`. If later the pyrogue's zip file is changed, the next release version will be `v4.2.0`. Updating the configuration file will generate a release version `v4.2.1`. Finally, modifying the server arguments (like for example adding/removing `--disable-bayX`) will generated a release version `v4.2.2`. And so on.

The file [RELEASES.md](RELEASES.md) contains a list of released version with a description for each one. Similar information can be found in the repository's [releases](https://github.com/slaclab/pysmurf-stable-docker/releases) page.
