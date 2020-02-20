#!/usr/bin/env bash

# Validate definitions.sh

#############
# FUNCTIONS #
#############
# Check if a tag exists on a github repository
# Arguments:
# - first: github repository url,
# - second: tag name
check_if_tag_exist()
{
    local repo=$1
    local tag=$2
    git ls-remote --refs --tag ${repo} | grep -q refs/tags/${tag} > /dev/null
}

# Check if a asset file exist on a tag version on a github repository
# Arguments:
# - first: github repository url,
# - second: tag name,
# - third: asset file name
check_if_asset_exist()
{
    local repo=$1
    local tag=$2
    local file=$3
    curl --head --silent --fail ${repo}/releases/download/${tag}/${file} > /dev/null
}

# Check if file exist on a tag version on a github repository
# Arguments:
# - first: github repository url,
# - second: tag name,
# - third: file name (must be a full path on that repository)
check_if_file_exist()
{
    local repo=$1
    local tag=$2
    local file=$3
    curl --head --silent --fail ${repo}/blob/${tag}/${file} > /dev/null
}

# Exit with an error message, and with return code = 1
exit_on_error()
{
    echo
    echo "Validation failed! The definitions.sh file is incorrect!"
    echo
    exit 1
}

# Exist with a success message and with return core = 0
exit_on_success()
{
    echo
    echo "Success! The definitions.sh file is correct!"
    echo
}

#############
# MAIN BODY #
#############

# Load the user definitions
. definitions.sh

# Other definitions, not defined by the user
docker_org_name=tidair
docker_repo=pysmurf-server

# Validate base docker image
echo "==========================================="
echo "Validating pysmurf-server-base version..."
echo "==========================================="

printf "Checking is tagged release exist...       "
check_if_tag_exist ${pysmurf_repo} ${pysmurf_server_base_version}
if [ $? != 0 ]; then
    echo "Failed!"
    echo
    echo "Release \"${pysmurf_server_base_version}\" does not exist in repository \"${pysmurf_repo}\"!"
    exit_on_error
fi

echo "Release exist!"

# At this point the definition of the MCS file is correct,
# We will use a local file.
echo "Done!"
echo
echo "A correct pysmurf-server-base version was defined. This version will be used"
echo "  tidair/pysmurf-server-base:${pysmurf_server_base_version}"
echo "==========================================="
echo

# Validate MCS file selection
echo "==========================================="
echo "Validating MCS file selection..."
echo "==========================================="

printf "Checking if a tag was defined...          "
if [ -z ${mcs_repo_tag} ]; then
    echo "A tag was not defined."
    printf "Looking for a local file...               "

    local_mcs_files=$(find local_files -name *.mcs -o -name *.mcs.gz)
    num_local_mcs_files=$(echo -n "${local_mcs_files}" | grep -c '^')

    if [ ${num_local_mcs_files} == 0 ]; then
        echo "Failed!"
        echo
        echo "No local MCS file was found!"
        exit_on_error
    elif [ ${num_local_mcs_files} != 1 ]; then
        echo "Failed!"
        echo
        echo "More than one local MCS file was found!"
        exit_on_error
    else
        mcs_file_name=$(basename ${local_mcs_files})

        echo "File \"${mcs_file_name}\" was found!"

        # At this point the definition of the MCS file is correct,
        # We will use a local file.
        echo "Done!"
        echo
        echo "A correct MCS was defined. This local file will be used:"
        echo "  ${local_mcs_file_name}"
        echo "==========================================="
        echo

        # Variables passed to the build.sh script.
        mcs_use_local=1
    fi
else
    echo "Tag \"${mcs_repo_tag}\" was defined."

    printf "Checking is file name was defined...      "
    if [ -z ${mcs_file_name} ]; then
        echo "Failed!"
        echo
        echo "File name was not defined!"
        exit_on_error
    else
        echo "File name \"${mcs_file_name}\" was defined."
    fi

    printf "Checking is tagged release exist...       "
    check_if_tag_exist ${mcs_repo} ${mcs_repo_tag}
    if [ $? == 0 ]; then
        echo "Release exist!"
        printf "Checking if file exist on that release... "
        check_if_asset_exist ${mcs_repo} ${mcs_repo_tag} ${mcs_file_name}
        if [ $? == 0 ]; then
            echo "File exist!"

            # At this point the definition of the MCS file is correct,
            # We will use a file from the git repository.
            echo "Done!"
            echo
            echo "A correct MCS was defined. This remote file will be used:"
            echo "  ${mcs_repo}/releases/download/${mcs_repo_tag}/${mcs_file_name}"
            echo "==========================================="
            echo
        else
            echo "Failed!"
            echo
            echo "File \"${mcs_file_name}\" does not exist in release \"${mcs_repo_tag}\", repository \"${mcs_repo}\"!"
            exit_on_error
        fi

    else
        echo "Failed!"
        echo
        echo "Release \"${mcs_repo_tag}\" does not exist in repository \"${mcs_repo}\"!"
        exit_on_error
    fi
fi

# Validate ZIP file selection
echo "==========================================="
echo "Validating ZIP file selection..."
echo "==========================================="

printf "Checking if a tag was defined...          "
if [ -z ${zip_repo_tag} ]; then
    echo "A tag was not defined."
    printf "Looking for a local file...               "

    local_zip_files=$(find local_files -name *.zip)
    num_local_zip_files=$(echo -n "${local_zip_files}" | grep -c '^')

    if [ ${num_local_zip_files} == 0 ]; then
        echo "Failed!"
        echo
        echo "No local ZIP file was found!"
        exit_on_error
    elif [ ${num_local_zip_files} != 1 ]; then
        echo "Failed!"
        echo
        echo "More than one local ZIP file was found!"
        exit_on_error
    else
        zip_file_name=$(basename ${local_zip_files})

        echo "File \"${zip_file_name}\" was found!"

        # At this point the definition of the ZIP file is correct,
        # We will use a local file.
        echo "Done!"
        echo
        echo "A correct ZIP was defined. This local file will be used:"
        echo "  ${local_zip_file_name}"
        echo "==========================================="
        echo

        # Variables passed to the build.sh script.
        zip_use_local=1
    fi
else
    echo "Tag \"${zip_repo_tag}\" was defined."

    printf "Checking is file name was defined...      "
    if [ -z ${zip_file_name} ]; then
        echo "Failed!"
        echo
        echo "File name was not defined!"
        exit_on_error
    else
        echo "File name \"${zip_file_name}\" was defined."
    fi

    printf "Checking is tagged release exist...       "
    check_if_tag_exist ${zip_repo} ${zip_repo_tag}
    if [ $? == 0 ]; then
        echo "Release exist!"
        printf "Checking if file exist on that release... "
        check_if_asset_exist ${zip_repo} ${zip_repo_tag} ${zip_file_name}
        if [ $? == 0 ]; then
            echo "File exist!"

            # At this point the definition of the ZIP file is correct,
            # We will use a file from the git repository.
            echo "Done!"
            echo
            echo "A correct ZIP was defined. This remote file will be used:"
            echo "  ${zip_repo}/releases/download/${zip_repo_tag}/${zip_file_name}"
            echo "==========================================="
            echo
        else
            echo "Failed!"
            echo
            echo "File \"${zip_file_name}\" does not exist in release \"${zip_repo_tag}\", repository \"${zip_repo}\"!"
            exit_on_error
        fi

    else
        echo "Failed!"
        echo
        echo "Release \"${zip_repo_tag}\" does not exist in repository \"${zip_repo}\"!"
        exit_on_error
    fi
fi

# Validate ZIP file selection
echo "==========================================="
echo "Validating YML file selection..."
echo "==========================================="

printf "Checking if a tag was defined...          "
if [ -z ${yml_repo_tag} ]; then
    echo "A tag was not defined."
    printf "Looking for a local file...               "

    local_yml_files=$(find local_files -name *.yml)
    num_local_yml_files=$(echo -n "${local_yml_files}" | grep -c '^')

    if [ ${num_local_yml_files} == 0 ]; then
        echo "Failed!"
        echo
        echo "No local YML file was found!"
        exit_on_error
    elif [ ${num_local_yml_files} != 1 ]; then
        echo "Failed!"
        echo
        echo "More than one local YML file was found!"
        exit_on_error
    else
        yml_file_name=$(basename ${local_yml_files})

        echo "File \"${yml_file_name}\" was found!"

        # At this point the definition of the ZIP file is correct,
        # We will use a local file.
        echo "Done!"
        echo
        echo "A correct YML was defined. This local file will be used:"
        echo "  ${local_yml_file_name}"
        echo "==========================================="
        echo

        # Variables passed to the build.sh script.
        yml_use_local=1
    fi
else
    echo "Tag \"${yml_repo_tag}\" was defined."

    printf "Checking is file name was defined...      "
    if [ -z ${yml_file_name} ]; then
        echo "Failed!"
        echo
        echo "File name was not defined!"
        exit_on_error
    else
        echo "File name \"${yml_file_name}\" was defined."
    fi

    printf "Checking is tagged release exist...       "
    check_if_tag_exist ${yml_repo} ${yml_repo_tag}
    if [ $? == 0 ]; then
        echo "Release exist!"
        printf "Checking if file exist on that release... "
        check_if_file_exist ${yml_repo} ${yml_repo_tag} "defaults/${yml_file_name}"
        if [ $? == 0 ]; then
            echo "File exist!"

            # At this point the definition of the YML file is correct,
            # We will use a file from the git repository.
            echo "Done!"
            echo
            echo "A correct YML was defined. This remote file will be used:"
            echo "  ${yml_repo}/blob/${yml_repo_tag}/defaults/${yml_file_name}"
            echo "==========================================="
            echo
        else
            echo "Failed!"
            echo
            echo "File \"${yml_file_name}\" does not exist in release \"${yml_repo_tag}\", repository \"${yml_repo}\"!"
            exit_on_error
        fi

    else
        echo "Failed!"
        echo
        echo "Release \"${yml_repo_tag}\" does not exist in repository \"${yml_repo}\"!"
        exit_on_error
    fi
fi

# At this point all definition where correct
exit_on_success
