HUGO_VERSION := "0.142.0"
CONTAINER_NAME := "tatusl.dev-hugo-dev"
CONTAINER_IMAGE_TAG := "hugomods/hugo:base-non-root"
HUGO_PORT := "8080"

.PHONY: run-in-container new-post

run-in-container:
	docker run --rm \
		--name "${CONTAINER_NAME}" \
		-p "${HUGO_PORT}":"${HUGO_PORT}" \
		-v "$${PWD}:/src" \
		"${CONTAINER_IMAGE_TAG}-${HUGO_VERSION}" \
		server -p "${HUGO_PORT}" --buildDrafts

new-post:
	@read -p "Enter post filename: " post_filename; \
	docker run --rm \
		--name "${CONTAINER_NAME}-create-post" \
		-v "$${PWD}:/src" \
		"${CONTAINER_IMAGE_TAG}-${HUGO_VERSION}" \
		new content/posts/"$$post_filename"

refresh-post-date:
	@read -p "Enter post filename: " post_filename; \
  ./helpers/refresh_post_date.py "content/posts/$$post_filename"
