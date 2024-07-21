#
# Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

set -eu

if [[ -z ${VERSION:-} || -z ${COMMON_UTILS} ]]
then
    echo "A release version must be defined via the \$VERSION env var, and"
    echo "a destination folder via \$COMMON_UTILS (it will be created if it doesn't exist)"
    exit 1
fi

echo "Installing common-utils Rel. $VERSION to $COMMON_UTILS"
declare -r TARBALL="https://github.com/massenz/common-utils/releases/download/$VERSION/common-utils-$VERSION.tar.gz"
if [[ ! -d ${COMMON_UTILS} ]]
then
  mkdir -p ${COMMON_UTILS}
fi
curl -s -L ${TARBALL} | tar x -C ${COMMON_UTILS}

source ${COMMON_UTILS}/utils.sh
success "Utilities installed to ${COMMON_UTILS}"

cat <<EOF >${HOME}/.commonrc
export COMMON_UTILS=${COMMON_UTILS}
source ${COMMON_UTILS}/utils
addpath ${COMMON_UTILS}
EOF
msg "Initialization configured to ${HOME}/.commonrc - source it from your .$(basename ${SHELL})rc"
