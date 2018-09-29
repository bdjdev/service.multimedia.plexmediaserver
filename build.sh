#!/bin/env bash

declare -r SCRIPT=${0##*/}
declare -r SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# validate SCRIPT_DIR
if [ "${SCRIPT_DIR}" = "" ] || [ ! -e "${SCRIPT_DIR}" ]; then
	echo "ERROR: Unable to dynamically determine the script's directory (${SCRIPT_DIR})."
	echo "       This is dangerous due to some rm -rf commands run later.  Aborting..."
	exit 1
fi

# Download debian 64-bit version from https://www.plex.tv/downloads/
plex_file=~/Downloads/plexmediaserver_1.13.8.5395-10d48da0d_amd64.deb
echo "Plex Download is: ${plex_file}"
if [ ! -f ${plex_file} ]; then
	echo "ERROR: Plex download file is missing or has bad permissions: ${plex_file}"
	exit 1
fi

version=$(basename "${plex_file}" | sed -e "s|.*_\(.*\)-.*|\\1|")
echo "Plex Version: ${version}"

# Change version in `addon.xml` to match downloaded version
echo -en "Updating: addon.xml: " && {
	sed -i "s|^\(       version\)=\".*\"$|\1=\"${version}\"|" ${SCRIPT_DIR}/addon.xml
	echo "DONE"
}

# Update changelog.txt
echo -en "Updating: changelog.txt: " && {
	sed -i "1s/^/${version}\n- update to PMS ${version}\n\n/" ${SCRIPT_DIR}/changelog.txt
	echo "DONE"
}

# cleanup SCRIPT_DIR/lib/*
echo -en "Cleaning up: ${SCRIPT_DIR}/lib/*: " && {
	/bin/rm -rf ${SCRIPT_DIR}/lib/*
	echo "DONE"
}

# Install
echo "Preparing ${SCRIPT_DIR}/lib" && pushd ${SCRIPT_DIR}/lib >/dev/null
echo "Creating tmp/ dir" && mkdir tmp && pushd tmp/ >/dev/null
echo -en "Extracting ${plex_file}: " && {
	ar x ${plex_file} &>/dev/null
	echo "DONE"
}
echo -en "Extracting data.tar.gz: " && {
	tar xvfx data.tar.gz &>/dev/null
	echo "DONE"
}
echo "Installing Plex Libs to ${SCRIPT_DIR}/lib" && /bin/mv usr/lib/plexmediaserver/* ${SCRIPT_DIR}/lib/
echo "Cleaning up..." && popd > /dev/null && /bin/rm -rf tmp && popd >/dev/null

# Package
echo "Packaging..."
cd ${SCRIPT_DIR}/..
output_file=service.multimedia.plexmediaserver-${version}.zip
echo -en "Creating: ${output_file}: " && {
	zip -r ${output_file} service.multimedia.plexmediaserver/ -x *.git* &>/dev/null
	echo "DONE"
}

echo "scp ${output_file} to Kodi server and install plugin"

exit 0
