#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "No platform specified." 1>&2
	exit 1
fi

PLATFORM="$1"
source ${DEVKITPRO}/${PLATFORM}vars.sh
echo "${PORTLIBS_PREFIX}"
