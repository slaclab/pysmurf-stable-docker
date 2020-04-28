#!/usr/bin/env bash

# Define the pysmurf-server-base version
# ======================================
# - Set the 'pysmurf_server_base_version' variable to the
#   pysmurf-server-base docker image version you want to use
#   as a base.
# - Normally, you should need to change the repository URL.
pysmurf_repo=https://github.com/slaclab/pysmurf
pysmurf_server_base_version=v4.0.0

# Define the MCS file location:
# =============================
# - Set the repository, tag, and name of the MCS file you want to
#   use. It will be downloaded from github repository's assets.
# - You can use a local file instead. In this case you must leave
#   the 'mcs_repo_tag' variable empty, and provide a local copy of
#   the MCS file in the 'local_files' directory.
# - If more that one local file is provided, the building process will
#   failed, so make sure only one MCS file exist in that directory.
# - Valid MCS file have extension '.mcs' or '.mcs.gz'.
# - If 'mcs_repo_tag' is defined, local files will be ignored.
# - Normally, you should need to change the repository URL.
mcs_repo=https://github.com/slaclab/cryo-det
mcs_repo_tag=MicrowaveMuxBpEthGen2_v0.0.5
mcs_file_name=MicrowaveMuxBpEthGen2-0x00000020-20191203110805-mdewart-83947a3.mcs.gz

# Define the ZIP file location:
# =============================
# - Set the repository, tag, and name of the ZIP file you want to
#   use. It will be downloaded from the github repository's assets.
# - You can use a local file instead. In this case you must leave
#   the 'zip_repo_tag' variable empty, and provide a local copy of
#   the ZIP file in the 'local_files' directory.
# - If more that one local file is provided, the building process will
#   failed, so make sure only one ZIP file exist in that directory.
# - Valid ZIP file have extension '.zip'.
# - If 'zip_repo_tag' is defined, local files will be ignored.
# - This file usually comes from the same repository and the same tag
#   as the MCS file.
# - Normally, you should need to change the repository URL.
zip_repo=${mcs_repo}
zip_repo_tag=${mcs_repo_tag}
zip_file_name=rogue_MicrowaveMuxBpEthGen2_v0.0.5.zip

# Define the YML file location:
# =============================
# - Set the repository and tag you want to use. The repository
#   will be cloned from github.
# - You can also defined an specific YAML file name, If so, it
#   will be added to the server startup argument list.
# - You can use a local file instead. In this case you must leave
#   the 'yml_repo_tag' variable empty, and provide a local copy of
#   the YML file in the 'local_files' directory.
# - If more that one local file is provided, the building process will
#   failed, so make sure only one YML file exist in that directory.
# - Valid YML file have extension '.yml'.
# - If 'yml_repo_tag' is defined, local files will be ignored.
# - Normally, you should need to change the repository URL.
yml_repo=https://github.com/slaclab/smurf_cfg
yml_repo_tag=v1.0.0
yml_file_name=

# Define server startup arguments
# ===============================
# - Add here a string with all the wanted startup arguments.
#   Note that if you defined an specific YML file, then the arguments
#   '--disable-hw-detect' as well as '-d' pointing to that file will be
#   automatically added. So, you don't need to added then here.
server_args=""
