#!/usr/bin/env bash

if [[ -z ${REPO_ROOT:-} ]]; then
  REPO_ROOT=$(git rev-parse --show-toplevel) || {
    echo "FAIL: Failed to get repo root(required for importing libraries)" >&2
    exit 1
  }
fi

source "$REPO_ROOT/lib/init"

import 'auth'
import 'docker'

verify_sudo_user

wait_for_docker_service

if configure_docker_logging; then
  log okay 'docker logging congifured'
fi
