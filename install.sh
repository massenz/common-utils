set -eu
echo "Installing common-utils Rel. $VERSION to $COMMON_UTILS"

declare -r TARBALL="https://github.com/massenz/common-utils/releases/download/$VERSION/common-utils-$VERSION.tar.gz"
declare -r DEST=$(mktemp -d)

if [[ ! -d ${COMMON_UTILS} ]]
then
  mkdir -p ${COMMON_UTILS}
fi
wget -q -O - ${TARBALL} | tar x -C ${COMMON_UTILS}

source ${COMMON_UTILS}/utils
success "Utilities installed to ${COMMON_UTILS}"

cat <<EOF >${HOME}/.commonrc
export COMMON_UTILS=${COMMON_UTILS}
source ${COMMON_UTILS}/utils
addpath ${COMMON_UTILS}
EOF
msg "Initialization configured to ${HOME}/.commonrc - source it from your .$(basename ${SHELL})rc"
