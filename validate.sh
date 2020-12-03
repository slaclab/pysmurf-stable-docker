#!/usr/bin/env bash

# Validate definitions.sh

#############
# FUNCTIONS #
#############
# Check if a tag exists on a github public repository
# Arguments:
# - first: github public repository url,
# - second: tag name
check_if_public_tag_exist()
{
    local repo=$1
    local tag=$2
    git ls-remote --refs --tag ${repo} | grep -q refs/tags/${tag} > /dev/null
}

# Check if a asset file exist on a tag version on a github public repository
# Arguments:
# - first: github public repository url,
# - second: tag name,
# - third: asset file name
check_if_public_asset_exist()
{
    local repo=$1
    local tag=$2
    local file=$3
    curl --head --silent --fail ${repo}/releases/download/${tag}/${file} > /dev/null
}

# Check if a tag exists on a github pivate repository.
# It requires the access token to be defined in $GITHUB_TOKEN.
# Arguments:
# - first: github private repository url,
# - second: tag name
check_if_private_tag_exist()
{
    # Need to insert the token in the url
    local repo=$(echo $1 | sed -e "s|https://|https://${GITHUB_TOKEN}@|g")
    local tag=$2
    echo
    echo "-----"
    echo ${tag}
    echo $(git ls-remote --refs --tag ${repo})
    echo "-----"
    git ls-remote --refs --tag ${repo} | grep -q refs/tags/${tag} > /dev/null
}

# Check if a asset file exist on a tag version on a github private repository.
# It requires the access token to be defined in $GITHUB_TOKEN.
# Arguments:
# - first: github private repository url,
# - second: tag name,
# - third: asset file name
check_if_private_asset_exist()
{
    local repo=$(echo $1 | sed -e "s|https://github.com|https://api.github.com/repos|g")
    local tag=$2
    local file=$3

    # Search the asset ID in the specified release
    local r=$(curl --silent --header "Authorization: token ${GITHUB_TOKEN}" "${repo}/releases/tags/${tag}")
    eval $(echo "${r}" | grep -C3 "name.:.\+${file}" | grep -w id | tr : = | tr -cd '[[:alnum:]]=')

    # return is the asset tag was found
    [ "${id}" ]
}

# Download the asset file on a tagged version on a github private repository.
# It requires the access token to be defined in $GITHUB_TOKEN.
# Arguments:
# - first: github private repository url,
# - second: tag name,
# - third: asset file name
get_private_asset()
{
    local repo=$(echo $1 | sed -e "s|https://github.com|https://api.github.com/repos|g")
    local tag=$2
    local file=$3

    # Check if the asset exist, and get it's ID
    check_if_private_asset_exist ${repo} ${tag} ${file} || exit 1

    echo "Downloading ${file}..."

    # Try to download the asset
    curl --fail --location --remote-header-name --remote-name --progress-bar \
         --header "Authorization: token ${GITHUB_TOKEN}" \
         --header "Accept: application/octet-stream" \
         "${repo}/releases/assets/${id}"
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

# Validate base docker image
echo "==========================================="
echo "Validating pysmurf-server-base version..."
echo "==========================================="

printf "Checking is tagged release exist...       "
check_if_public_tag_exist ${pysmurf_repo} ${pysmurf_server_base_version}
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
        echo "  ${mcs_file_name}"
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
    check_if_private_tag_exist ${mcs_repo} ${mcs_repo_tag}
    if [ $? == 0 ]; then
        echo "Release exist!"
        printf "Checking if file exist on that release... "
        check_if_private_asset_exist ${mcs_repo} ${mcs_repo_tag} ${mcs_file_name}
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
        echo "  ${zip_file_name}"
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
    check_if_private_tag_exist ${zip_repo} ${zip_repo_tag}
    if [ $? == 0 ]; then
        echo "Release exist!"
        printf "Checking if file exist on that release... "
        check_if_private_asset_exist ${zip_repo} ${zip_repo_tag} ${zip_file_name}
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
        echo "  ${yml_file_name}"
        echo "==========================================="
        echo

        # Variables passed to the build.sh script.
        yml_use_local=1
    fi
else
    echo "Tag \"${yml_repo_tag}\" was defined."
fi

printf "Checking is tagged release exist...       "
check_if_public_tag_exist ${yml_repo} ${yml_repo_tag}
if [ $? == 0 ]; then
    echo "Release exist!"
else
    echo "Failed!"
    echo
    echo "Release \"${yml_repo_tag}\" does not exist in repository \"${yml_repo}\"!"
    exit_on_error
fi

printf "Checking is file name was defined...      "
if [ -z ${yml_file_name} ]; then
    echo "An specific file was not defined."

    # At this point the definition of the YML file is correct.
    # We are not going to use an specific file name from the repository.
    echo "Done!"
    echo
    echo "A correct YML repository and tag were defined. An specific YML will not be used."
    echo "We will use the repository ${yml_repo}, tagged version ${yml_repo_tag}"
    echo "==========================================="
    echo
else
    echo "File name \"${yml_file_name}\" was defined."

    printf "Checking if file exist on that release... "
    check_if_file_exist ${yml_repo} ${yml_repo_tag} "defaults/${yml_file_name}"
    if [ $? == 0 ]; then
        echo "File exist!"

        # At this point the definition of the YML file is correct,
        # We will use a file from the git repository.
        echo "Done!"
        echo
        echo "A correct YML repository, tag, and specific file were defined."
        echo "This remote file will be used:"
        echo "  ${yml_repo}/blob/${yml_repo_tag}/defaults/${yml_file_name}"
        echo "==========================================="
        echo
    else
        echo "Failed!"
        echo
        echo "File \"${yml_file_name}\" does not exist in release \"${yml_repo_tag}\", repository \"${yml_repo}\"!"
        exit_on_error
    fi
fi

# At this point all definition where correct
exit_on_success
