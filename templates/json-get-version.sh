#!/usr/bin/env zsh
#
# Copyright (c) 2022 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)

set -eu

function usage() {
  echo "Usage: $(basename $0) [MANIFEST]

Extracts the 'revision' key from the manifest

  MANIFEST    the optional location of the JSON Manifest (uses manifest.json by default)
"
}

if [[ ${1:-} == "-h" ]]
then
  usage
  exit 0
fi

manifest=${1:-manifest.json}
if [[ ! -e ${manifest} ]]
then
  usage 1>&2
  echo "ERROR: ${manifest} does not exist" 1>&2
  exit 1
fi
version=$(cat ${manifest} | jq -r ".revision")
echo ${version}
