#!/usr/bin/env bash

# Define the pysmurf-server-base version
pysmurf_server_base_version=v4.0.0-rc15

# Define the MCS file location
# - Set 'mcs_use_local' to 'y' if you provide a local copy of the
#   mcs file in the 'local_files' directory. All others definitions
#   will be ignored.
# - Set 'mcs_use_local' to 'n' if you want to get the mcs file
#   from github's assets. You can define the repository, tag, and
#   file name.
mcs_use_local=n
mcs_repo=https://github.com/slaclab/cryo-det
mcs_repo_tag=MicrowaveMuxBpEthGen2_v1.2.14
mcs_file_name=MicrowaveMuxBpEthGen2-0x00000016-20190724191903-mdewart-8234f45.mcs.gz

# Define the ZIP file location
# - Set 'zip_use_local' to 'y' if you provide a local copy of the
#   zip file in the 'local_files' directory. All others definitions
#   will be ignored.
# - Set 'zip_use_local' to 'n' if you want to get the zip file
#   from github's assets. You can define the repository, tag, and
#   file name.
zip_use_local=n
zip_repo=${mcs_repo}
zip_repo_tag=${mcs_repo_tag}
zip_file_name=rogue_MicrowaveMuxBpEthGen2_v1.2.14.zip

# Define the YML file location
# - Set 'yml_use_local' to 'y' if you provide a local copy of the
#   yml file in the 'local_files' directory. All others definitions
#   will be ignored.
# - Set 'yml_use_local' to 'n' if you want to get the yml file
#   from its github repository. You can define the repository, tag, and
#   file name.
yml_use_local=n
yml_repo=https://github.com/slaclab/smurf_cfg
yml_repo_tag=v0.0.2
yml_file_name=defaults_lbonly_c03_bay0.yml

# Define server startup arguments
# - Add here a string with all the wanted startup arguments
server_args="--disable-bay1"


