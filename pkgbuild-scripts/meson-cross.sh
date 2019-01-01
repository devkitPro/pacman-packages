#!/usr/bin/env bash
SCRIPTDIR="${BASH_SOURCE%/*}"

if [ -z "$1" ]; then
	echo "No platform specified." 1>&2
	exit 1
fi

if [ -z "$2" ]; then
	echo "No cross file output filename specified." 1>&2
	exit 1
fi

PLATFORM="$1"
CROSSFILE="$2"
shift 2

PORTLIBS_PREFIX=$(${SCRIPTDIR}/portlibs_prefix.sh ${PLATFORM})
${SCRIPTDIR}/meson-toolchain.sh ${PLATFORM} > ${CROSSFILE} || exit 1
meson --buildtype=plain --cross-file="${CROSSFILE}" --default-library=static --prefix="${PORTLIBS_PREFIX}" --libdir=lib "$@"
