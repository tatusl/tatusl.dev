#!/bin/sh
# Build script for Cloudflare Pages.
#
# Pages has no repo-level way to pin the Hugo version (no .tool-versions or
# equivalent), so instead of relying on the HUGO_VERSION dashboard variable we
# download the pinned version here. The version is read from the Makefile so
# local container builds and Pages builds cannot drift apart.
#
# Configure the Pages build command as: sh ./build.sh

set -eu

HUGO_VERSION="$(sed -n 's/^HUGO_VERSION[[:space:]]*:=[[:space:]]*"\([^"]*\)".*/\1/p' Makefile)"

if [ -z "${HUGO_VERSION}" ]; then
	echo "build.sh: could not read HUGO_VERSION from Makefile" >&2
	exit 1
fi

echo "build.sh: using Hugo ${HUGO_VERSION} (extended)"

TARBALL="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
BASE_URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}"

BIN_DIR="$(mktemp -d)"
trap 'rm -rf "${BIN_DIR}"' EXIT

curl -sSfL "${BASE_URL}/${TARBALL}" -o "${BIN_DIR}/${TARBALL}"
curl -sSfL "${BASE_URL}/hugo_${HUGO_VERSION}_checksums.txt" -o "${BIN_DIR}/checksums.txt"

(cd "${BIN_DIR}" && grep " ${TARBALL}\$" checksums.txt | sha256sum -c -)

tar -xzf "${BIN_DIR}/${TARBALL}" -C "${BIN_DIR}" hugo

"${BIN_DIR}/hugo" version

# Pages sets CF_PAGES_URL to the URL this deployment is served from, which
# keeps preview deployments self-contained instead of pointing at production.
# Outside Pages, fall back to the baseURL in hugo.toml.
if [ -n "${CF_PAGES_URL:-}" ]; then
	"${BIN_DIR}/hugo" -b "${CF_PAGES_URL}"
else
	"${BIN_DIR}/hugo"
fi
