#!/usr/bin/env bash
#
# Copyright (c) 2022 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#
set -eu

function usage() {
  echo "Usage: $(basename $0) [BUILD_SETTINGS]

Extracts the 'version' property from the settings

  BUILD_SETTINGS    the optional location of the build properties (uses build.settings by default)
"
}

if [[ ${1:-} == "-h" ]]
then
  usage
  exit 0
fi

properties=${1:-build.settings}
if [[ ! -e ${properties} ]]
then
  usage 1>&2
  echo "ERROR: ${properties} does not exist" 1>&2
  exit 1
fi

version=$(grep -E '^[[:blank:]]*version' ${properties} |\
    sed -E 's/^[[:blank:]]*version[[:blank:]]*=?[[:blank:]]*//' |\
    sed "s/'//g" | sed 's/[[:blank:]]*$//')

echo "v${version}-g$(git rev-parse --short HEAD)"
