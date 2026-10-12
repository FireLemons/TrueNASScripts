#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/lib/logger"

DELETE_PERMISSION_USER="Admin" # Don't hard code. Use env variable
IS_DRY_RUN=true
LOCAL_WIKI_PORT="8090"
MW_CONTAINER="ix-wiki-wiki-1"
DELETE_REASON="Automated file cleanup"

container_exists() {
  [ -n "$(sudo docker ps -a --filter "name=^/${MW_CONTAINER}$" --format '{{.Names}}')" ]
}

fetch_unused_images() {
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

UNUSED_IMAGE_FILES=$(fetch_unused_images)

if ! container_exists; then
  log fail "Failed to find mediawiki docker container. Exiting."
  exit 1
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
fi
