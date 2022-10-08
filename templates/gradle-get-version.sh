#!/usr/bin/env bash
#
# Copyright (c) 2022 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

#
# Usage: get-version [build]
# Extracts version from build.gradle
#
# build is the path to the build.gradle file, defaults to ./build.gradle

set -eu

function usage() {
  echo "Usage: $(basename $0) [BUILD]

Extracts the 'revision' key from the manifest

  BUILD    the optional location of the build.gradle file, if not in the current directory
"
}

if [[ ${1:-} == "-h" ]]
then
  usage
  exit 0
fi

build=${1:-build.gradle}
if [[ ! -f ${build} ]]
then
  usage 1>&2
  echo "ERROR: ${build} does not exist or is not a file" 1>&2
  exit 1
fi

# Note the use of -E to enable "extended" RegExps syntax (* and ?).
grep -E '^[[:blank:]]*version' ${build} |\
    sed -E 's/^[[:blank:]]*version[[:blank:]]*=?[[:blank:]]*//' |\
    sed "s/'//g" | sed 's/[[:blank:]]*$//'
