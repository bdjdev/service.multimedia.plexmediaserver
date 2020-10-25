#!/bin/env bash

declare -r SCRIPT=${0##*/}
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r SRC_DIR="${SCRIPT_DIR}/src"
declare -r ADDON_DIR="${SRC_DIR}/service.multimedia.plexmediaserver"
declare -r OUTPUT_DIR="${SCRIPT_DIR}/output"

# validate SCRIPT_DIR
if [ "${SCRIPT_DIR}" = "" ] || [ ! -e "${SCRIPT_DIR}" ]; then
	echo "ERROR: Unable to dynamically determine the script's directory (${SCRIPT_DIR})."
	echo "       This is dangerous due to some rm -rf commands run later.  Aborting..."
	exit 1
fi

# Download debian 64-bit version from https://www.plex.tv/downloads/
plex_file=$1
if [ "${plex_file}" = "" ] || [ ! -f "${plex_file}" ]; then
	echo "Usage: ${SCRIPT} <plexmediaserver_version_amd64.deb>"
	echo
	echo "Download debian 64-bit version from https://www.plex.tv/downloads/"
	exit 1
fi

echo "Plex Download is: ${plex_file}"
if [ ! -f ${plex_file} ]; then
	echo "ERROR: Plex download file is missing or has bad permissions: ${plex_file}"
	exit 1
fi

version=$(basename "${plex_file}" | sed -e "s|.*_\(.*\)-.*|\\1|")
echo "Plex Version: ${version}"

output_file="${OUTPUT_DIR}/service.multimedia.plexmediaserver-${version}.zip"
if [ -f ${output_file} ]; then
	echo "This will overwrite the existing file: ${output_file}"
	unset input
	while [ "${input}" = "" ]; do
		echo -n "Would you like to proceed? (yes*/no): "
		read input

		# evaluate as lowercase
		case "${input,,}" in 
			yes|y|'')
				input=yes
				/bin/rm -f ${output_file}
				;;
			no|n)
				echo "Exiting..."
				exit 0
				;;
			*)
				unset input
				;;
		esac
	done
fi

# cleanup ADDON_DIR/lib
echo -en "Cleaning up: ${ADDON_DIR}/lib: " && {
	/bin/rm -rf ${ADDON_DIR}/lib
	echo "DONE"
} || exit 1

# Install
echo "Preparing ${ADDON_DIR}/lib" && mkdir -p ${ADDON_DIR}/lib && pushd ${ADDON_DIR}/lib >/dev/null
echo "Creating tmp/ dir" && mkdir tmp && pushd tmp/ >/dev/null

echo -en "Extracting ${plex_file}: " && {
	ar x ${plex_file} &>/dev/null &&
	echo "DONE"
} || exit 1

echo -en "Extracting data.tar.*z: " && {
	tar xvfa data.tar.*z &>/dev/null &&
	echo "DONE"
} || exit 1

echo -en "Installing Plex Libs to ${ADDON_DIR}/lib: " && {
	/bin/mv usr/lib/plexmediaserver/* ${ADDON_DIR}/lib/ &&
	echo "DONE"
} || exit 1
echo "Cleaning up..." && popd > /dev/null && /bin/rm -rf ./tmp && popd >/dev/null

# Change version in 'addon.xml' to match downloaded version
echo -en "Updating: addon.xml: " && {
	sed -i "s|^\(       version\)=\".*\"$|\1=\"${version}\"|" ${ADDON_DIR}/addon.xml
	echo "DONE"
} || exit 1

# Update changelog.txt
echo -en "Updating: changelog.txt: " && {
	if grep "^${version}$" ${ADDON_DIR}/changelog.txt &>/dev/null; then
		echo "SKIPPING (Already Updated)"
	else
		sed -i "1s/^/${version}\n- update to PMS ${version}\n\n/" ${ADDON_DIR}/changelog.txt
		echo "DONE"
	fi
} || exit 1

# Package
echo "Packaging..."
cd ${SRC_DIR}
echo -en "Creating: ${output_file}: " && {
	zip -r ${output_file} $(basename ${ADDON_DIR})/ -x *.git*  &>/dev/null
	echo "DONE"
}

echo "scp ${output_file} to Kodi server and install plugin"

exit 0
