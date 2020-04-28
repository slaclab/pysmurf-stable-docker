#!/usr/bin/env bash

# Load the user definitions
. definitions.sh

# Call the validation script
. validate.sh

# Check if the TRAVIS_TAG variable is defined.
if [ -z ${TRAVIS_TAG+x} ]; then
    echo "ERROR: TRAVIS_TAG environmental variable not defined!"
    exit 1
fi

# Other definitions, not defined by the user
docker_org_name=tidair
docker_repo=pysmurf-server
this_repo=https://github.com/slaclab/pysmurf-stable-docker

# Get mcs file
if [ -z ${mcs_use_local+x} ]; then
    echo "Getting mcs file from ${mcs_repo}"

    # Get the mcs file assent
    wget -O local_files/${mcs_file_name} ${mcs_repo}/releases/download/${mcs_repo_tag}/${mcs_file_name} || exit 1
else
    echo "Using local mcs file..."
fi

# Get zip file
if [ -z ${zip_use_local+x} ]; then
    echo "Getting zip file from ${zip_repo}"

    # Get the zip file asset
    wget -O local_files/${zip_file_name} ${zip_repo}/releases/download/${zip_repo_tag}/${zip_file_name} || exit 1
else
    echo "Using local zip file..."
fi

# Get yml file
if [ -z ${yml_use_local+x} ]; then
    echo "Getting yml file from ${yml_repo}"

    if [ -z ${yml_file_name} ]; then
        # If an specific file was not define, clone the whole repository
        git -C local_files clone ${yml_repo} -b ${yml_repo_tag} || exit 1
    else
        # If an specific file was defined, copy it
        git clone ${yml_repo} -b ${yml_repo_tag} yml_repo || exit 1
        mv yml_repo/defaults/${yml_file_name} local_files || exit 1
        rm -rf yml_repo

        # Additionally, when an specific YML file is defined, add the '--disable-hw-detect'
        # option to the list of server arguments as well as the specified YML file using the
        # '-d' option.
        server_args+=" --disable-hw-detect -d /tmp/fw/${yml_file_name}"
    fi

else
    echo "Using local yml file..."
fi

# Remove any white spaces and the beginning or end of the server argument string.
server_args=$(echo ${server_args} | sed 's/^\s//g'| sed 's/\s$//g')

# Then divide it into a list of quoted substring, divided by comas.
# This is the format that the Dockerfile uses
if [ -z "${server_args}" ]; then
    # If the server argument is empty, then the list will be empty
    server_args_list=""
else
    # Otherwise, generate the list.
    server_args_list=$(echo ,\"${server_args}\" | sed 's/\s/","/g')
fi

# Generate the Dockerfile from the template
cat Dockerfile.template \
        | sed "s|%%SERVER_ARGS%%|"${server_args_list}"|g" \
        | sed "s|%%SERVER_ARGS_ENV%%|${server_args}|g" \
        | sed "s|%%PYSMURF_SERVER_BASE_VERSION%%|${pysmurf_server_base_version}|g" \
        > Dockerfile

# Build the docker image and push it to Dockerhub
docker build -t ${docker_org_name}/${docker_repo} . || exit 1
docker tag ${docker_org_name}/${docker_repo} ${docker_org_name}/${docker_repo}:${TRAVIS_TAG} || exit 1
docker push ${docker_org_name}/${docker_repo}:${TRAVIS_TAG} || exit 1

echo "Docker image '${docker_org_name}/${docker_repo}:${TRAVIS_TAG}' pushed"

# Update the release information
. scripts/generate_release_info.sh