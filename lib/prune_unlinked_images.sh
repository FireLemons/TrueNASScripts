#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/lib/logger"

DELETE_PERMISSION_USER="Admin" # Don't hard code. Use env variable
IS_DRY_RUN=false
LOCAL_WIKI_PORT="8090"
MW_CONTAINER="ix-wiki-wiki-1"
DELETE_REASON="Automated file cleanup"

UNUSED_IMAGE_FILES=$(curl -s "http://localhost:$LOCAL_WIKI_PORT/api.php?action=query&list=querypage&qppage=Unusedimages&qplimit=max&format=json" | jq -r '.query.querypage.results[].title')

for arg in "$@"; do
  case $arg in
    --dry-run) IS_DRY_RUN=true ;;
  esac
done

if $IS_DRY_RUN; then
  log info "Files eligible for deletion:"
  echo "$UNUSED_IMAGE_FILES"
else
  log info "Unused filed to be deleted:"
  echo "$UNUSED_IMAGE_FILES"
fi
