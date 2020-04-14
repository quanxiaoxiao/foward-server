#!/bin/bash

set -euo pipefail

BASE_URL="https://nodejs.org/dist"
VERSION="latest"
PLATFORM="linux"
ARCH="x64"
FORWARD_SERVER_URL="https://github.com/quanxiaoxiao/foward-server/archive/0.0.1.tar.gz"
TARGET="${HOME}/foward-server"
PREFIX="${HOME}/.local"


resolve_node_version() {
  local tag="$1"
  if [ "${tag}" = "latest" ]; then
    tag=
  fi
  curl -s "https://resolve-node.now.sh/$tag"
}

RESOLVED="$(resolve_node_version "$VERSION")"

URL="${BASE_URL}/${RESOLVED}/node-${RESOLVED}-${PLATFORM}-${ARCH}.tar.gz"

PREFIX_LIB="${PREFIX}/lib/node-${RESOLVED}"

if [ ! -d "${PREFIX_LIB}" ]; then
  mkdir -p "${PREFIX_LIB}"
fi

if [ ! -d "${PREFIX}/bin" ]; then
  mkdir "${PREFIX}/bin"
fi

if [ ! -d "${TARGET}" ]; then
  mkdir "${TARGET}"
fi

curl -s "${URL}" \
  | tar -xzf - \
  --exclude CHANGELOG.md \
  --exclude LICENSE \
  --exclude README.md \
  --strip-components 1 \
  -C "${PREFIX_LIB}"

echo "install node at ${PREFIX_LIB}"

curl -sL "${FORWARD_SERVER_URL}" \
  | tar -xzf - \
  --exclude .editorconfig \
  --exclude .eslintrc \
  --exclude .gitignore \
  --exclude .install.sh \
  --strip-components 1 \
  --exclude README.md \
  -C "${TARGET}"

ln -s "${PREFIX_LIB}/bin/node" "${PREFIX}/bin"
ln -s "${PREFIX_LIB}/bin/npm" "${PREFIX}/bin"
ln -s "${PREFIX_LIB}/bin/npx" "${PREFIX}/bin"

export PATH=$PREFIX/bin:$PATH

echo "install forward-server at ${TARGET}"
