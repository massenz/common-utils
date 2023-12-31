#!/usr/bin/env bash
#
# Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

set -eu

function usage() {
  echo "Usage: $(basename $0) BUILD

Extracts version from the build settings

  BUILD  either a build.gradle file, or build.settings with a 'VERSION = <version>' line
         or a JSON Manifest with a "version" field.
         The '<version>' field can optionally be surrounded by single or double quotes,
         which will be discarded in the output string.
"
}

if [[ ${1:-} == "-h" ]]
then
  usage
  exit 0
fi

build=${1:-}
if [[ -z ${build} || ! -f ${build} ]]
then
  usage 1>&2
  echo "ERROR: BUILD must be specified, exist, and be a file ('${build}')" 1>&2
  exit 1
fi

# TODO: there are better ways to detect a file extension in Bash.
if [[ $(basename ${build} | cut -f 2 -d '.') == 'json' ]]
then
  echo $(cat ${build} | jq -r ".version")
else
  # Note the use of -E to enable "extended" RegExps syntax (* and ?).
  grep -E '^[[:blank:]]*version' ${build} |\
      sed -E 's/^[[:blank:]]*version[[:blank:]]*=?[[:blank:]]*//' |\
      sed "s/'//g" | sed 's/[[:blank:]]*$//'
fi
