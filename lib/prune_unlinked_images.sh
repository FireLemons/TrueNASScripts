#!/usr/bin/env bash

LOCAL_WIKI_PORT="8090"
MW_CONTAINER="ix-wiki-wiki-1"
DELETE_USER="Admin" # Don't hard code. Use env variable
REASON="Unused file cleanup"

UNUSED_IMAGE_FILES=$(curl -s "http://localhost:$LOCAL_WIKI_PORT/api.php?action=query&list=querypage&qppage=Unusedimages&qplimit=max&format=json" | jq -r '.query.querypage.results[].title')

echo "$UNUSED_IMAGE_FILES"
