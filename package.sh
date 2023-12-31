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

pushd ${BASE}
for f in build get-version parse-args runtests utils ; do
  cp scripts/$f.sh ${DEST}/$f
  chmod +x $DEST/$f
done
cp -r templates/ $DEST/
cp parse-args/parse_args.py $DEST/

# Generate HTML instructions.
pandoc README.md -t html -o /tmp/README.html
cat head.html /tmp/README.html tail.html >${DEST}/README.html
popd

tar cf ${TARBALL} -C ${DEST} .
success "Release tarball in ${TARBALL}"
