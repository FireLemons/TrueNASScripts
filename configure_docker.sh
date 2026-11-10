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

configure_docker_logging () {
  local current_config new_config

  log info 'configuring docker logging'

  if ! current_config=$(get_daemon_config); then
    log fail 'failed to get daemon.json'
    return 1
  fi

  if ! new_config=$(make_logging_config "$current_config"); then
    log fail 'failed to build config'
    return 1
  fi

  if ! apply_daemon_config "$new_config"; then
    log fail 'failed to apply config'
    return 1
  fi
}

verify_sudo_user

wait_for_docker_service

if configure_docker_logging; then
  log okay 'docker logging congifured'
fi
