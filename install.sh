set -eu

declare -r TARBALL="https://github.com/massenz/common-utils/releases/download/$VERSION/common-utils-$VERSION.tar.gz"

echo "Installing common-utils Rel. $VERSION to $UTILS_DIR"
if [[ ! -d ${UTILS_DIR} ]]
then
  mkdir -p ${UTILS_DIR}
fi
curl -s -L ${TARBALL} | tar x -C ${UTILS_DIR}

source ${UTILS_DIR}/utils
success "Utilities installed to ${UTILS_DIR}"

cat <<EOF >${HOME}/.commonrc
export UTILS_DIR=${UTILS_DIR}
source ${UTILS_DIR}/utils
addpath ${UTILS_DIR}
EOF
msg "Initialization configured to ${HOME}/.commonrc - source it from your .$(basename ${SHELL})rc"
