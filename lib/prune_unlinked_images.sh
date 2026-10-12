#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/lib/logger"

IS_DRY_RUN=true
LOCAL_WIKI_PORT="8090"
MW_CONTAINER="ix-wiki-wiki-1"

container_exists() {
  [ -n "$(sudo docker ps -a --filter "name=^/${MW_CONTAINER}$" --format '{{.Names}}')" ]
}

delete_unused_images() {
  echo "$1" \
    | sudo docker exec -i -w /var/www/html $MW_CONTAINER \
        php maintenance/run.php deleteBatch -r "Bulk image cleanup"
}

fetch_unused_image_names() {
  local url response titles
  url="http://localhost:${LOCAL_WIKI_PORT}/api.php?action=query&list=querypage&qppage=Unusedimages&qplimit=max&format=json"

  if ! response=$(curl -sSf --connect-timeout 5 --max-time 30 "$url"); then
    log fail "Failed to fetch unused files from wiki api at ${url}" >&2
    return 1
  fi

  if jq -e '.error' <<< "$response" >/dev/null 2>&1; then 
    log fail "wiki API returned error: $(jq -r '.error.info' <<< "$response")" >&2
    return 2
  fi

  if ! titles=$(jq -r '.query.querypage.results[].title' <<< "$response" 2>/dev/null); then
    log fail "Unexpected response from wiki API" >&2
    return 3
  fi

  printf '%s\n' "$titles"
}

if ! UNUSED_IMAGE_FILES=$(fetch_unused_image_names); then
  log info "Exiting"
  exit 2
fi

if ! container_exists; then
  log fail "Failed to find mediawiki docker container. Exiting."
  exit 3
fi

for arg in "$@"; do
  case $arg in
    --disable-dry-run) IS_DRY_RUN=false ;;
  esac
done

if $IS_DRY_RUN; then
  log info "Files eligible for deletion:"
  echo "$UNUSED_IMAGE_FILES"
else
  log info "Unused filed to be deleted:"
  echo "$UNUSED_IMAGE_FILES"

  if ! delete_unused_images "$UNUSED_IMAGE_FILES"; then
    log fail "Failed to delete the images" >&2
    exit 4
  fi
fi
