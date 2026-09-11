#!/bin/sh
# Print the newest Hugo version this repo can actually move to.
#
# That is not simply the latest Hugo release: local development runs the
# hugomods/hugo container image, which trails Hugo releases by a few days. A
# version is usable only once both the Hugo release and the matching image tag
# exist, so walk the releases newest-first and print the first one that has
# both.
#
# Set GH_TOKEN to lift the unauthenticated GitHub API rate limit.

set -eu

RELEASES_URL="https://api.github.com/repos/gohugoio/hugo/releases?per_page=30"
IMAGE_TAGS_URL="https://hub.docker.com/v2/repositories/hugomods/hugo/tags"
IMAGE_TAG_PREFIX="base-non-root"

if [ -n "${GH_TOKEN:-}" ]; then
	set -- -H "Authorization: Bearer ${GH_TOKEN}"
else
	set --
fi

versions="$(curl -sSfL -H "Accept: application/vnd.github+json" "$@" "${RELEASES_URL}" \
	| jq -r '.[] | select(.draft == false and .prerelease == false) | .tag_name | ltrimstr("v")')"

if [ -z "${versions}" ]; then
	echo "latest_hugo_version.sh: no Hugo releases returned" >&2
	exit 1
fi

for version in ${versions}; do
	if curl -sfL -o /dev/null "${IMAGE_TAGS_URL}/${IMAGE_TAG_PREFIX}-${version}"; then
		echo "${version}"
		exit 0
	fi
done

echo "latest_hugo_version.sh: no recent Hugo release has a ${IMAGE_TAG_PREFIX} image" >&2
exit 1
