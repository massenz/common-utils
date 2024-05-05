#!/usr/bin/env zsh
# Copyright (c) 2020-2024 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
set -eu
source scripts/utils.sh

declare -r TARBALL=${1:-}
if [[ -z ${TARBALL} ]]
then
  echo "Usage: $(basename $0) TARBALL"
  fatal "Destination TARBALL filename MUST be defined"
  exit 1
fi

declare -r DEST=$(mktemp -d)
declare -r BASE=$(abspath $(dirname $0))
declare -r MISC=(scripts/utils.sh templates/ parse-args/parse_args.py)

pushd ${BASE}
for f in $(ls scripts/) ; do
  # utils.sh is sourced by other scripts, so it should
  # retain its .sh extension and will not be made executable.
  [[ ${f} == 'utils.sh' ]] && continue
  # Removes the .sh extension
  cp scripts/${f} ${DEST}/${f:r}
  chmod +x $DEST/${f:r}
done
for f in ${MISC[@]} ; do
  cp -r ${f} ${DEST}/
done

# Generate HTML instructions.
version=$(./scripts/get-version.sh manifest.json)
echo "<br/>
      <img src=\"https://img.shields.io/badge/Version-${version}-red\" alt=\"Version ${version}\">
      <br/>" > /tmp/version.html
pandoc README.md -t html -o /tmp/README.html
cat head.html /tmp/version.html /tmp/README.html tail.html >${DEST}/README.html
popd

tar cf ${TARBALL} -C ${DEST} .
success "Release tarball in ${TARBALL}"
