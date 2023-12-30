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

BUILD_SETTINGS=${1:-build.settings}
if [[ ! -f ${BUILD_SETTINGS} ]]
then
  echo "ERROR: missing ${BUILD_SETTINGS}" 1>&2
  exit 1
fi

#if [[ ! -x get-version ]]
#then
#  echo "ERROR: cannot find a valid executable get-version in PATH" 1>&2
#  exit 1
#fi
echo "v$(templates/get-version.sh ${BUILD_SETTINGS})-g$(git rev-parse --short HEAD)"
