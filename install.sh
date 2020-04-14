#!/bin/bash

set -euo pipefail

BASE_URL="https://nodejs.org/dist"
VERSION="latest"
PLATFORM="linux"
ARCH="x64"
FORWARD_SERVER_URL="https://github.com/quanxiaoxiao/foward-server/archive/0.0.1.tar.gz"
TARGET="${HOME}/foward-server"


resolve_node_version() {
  local tag="$1"
  if [ "${tag}" = "latest" ]; then
    tag=
  fi
  curl -s "https://resolve-node.now.sh/$tag"
}

RESOLVED="$(resolve_node_version "$VERSION")"

URL="${BASE_URL}/${RESOLVED}/node-${RESOLVED}-${PLATFORM}-${ARCH}.tar.gz"

PREFIX="${HOME}/.local/bin/node-${RESOLVED}"

if [ ! -d "${PREFIX}" ]; then
  mkdir -p "${PREFIX}"
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
  -C "${PREFIX}"

echo "install node at ${PREFIX}"

curl -sL "${FORWARD_SERVER_URL}" \
  | tar -xzf - \
  --exclude .editorconfig \
  --exclude .eslintrc \
  --exclude .gitignore \
  --exclude .install.sh \
  --strip-components 1 \
  --exclude README.md \
  -C "${TARGET}"

echo "install forward-server at ${FORWARD_SERVER_URL}"
