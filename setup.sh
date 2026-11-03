#!/usr/bin/env bash

if [[ -z ${REPO_ROOT:-} ]]; then
  REPO_ROOT=$(git rev-parse --show-toplevel) || {
    echo "FAIL: Failed to get repo root(required for importing libraries)" >&2
    exit 1
  }
fi

source "$REPO_ROOT/lib/init"

import 'auth'
import 'cron'
import 'git'
import 'interactive'

verify_non_sudo_user

SCRIPT_PERSISTENT_STORAGE_DIR_PATH='/mnt/data/scripts/TrueNASScripts/'

does_persistent_dataset_for_scripts_exist () {
  local dataset="$1"
  zfs list "$dataset" &>/dev/null
}

does_persistent_dataset_have_scripts_installed () {
  does_git_repo_exist $SCRIPT_PERSISTENT_STORAGE_DIR_PATH
}

ensure_persisted_dataset_for_scripts () {
  zfs list data/scripts >/dev/null 2>&1 || sudo zfs create data/scripts &&

  sudo chmod 755 /mnt/data/scripts &&
  sudo chown $USER:$USER /mnt/data/scripts
}

if set_central_timezone; then
  log info 'success'
else
  log fail 'nope'
fi

if ensure_persisted_dataset_for_scripts; then
  log okay 'A persistent space to store these scripts has been confirmed'
  
  if does_git_repo_exist $SCRIPT_PERSISTENT_STORAGE_DIR_PATH; then
    log info "Scripts already installed. Updating..."
    cd $SCRIPT_PERSISTENT_STORAGE_DIR_PATH
    git fetch origin
    git reset --hard origin/main
    git clean -fd
  else
    log info "installing scripts to $SCRIPT_PERSISTENT_STORAGE_DIR_PATH"
    cd '/mnt/data/scripts/'
    git clone https://github.com/FireLemons/TrueNASScripts.git
  fi

  truenas_cron_create '*/2 * * * *' "bash $SCRIPT_PERSISTENT_STORAGE_DIR_PATH/prune_unlinked_images.sh" 'Backup' 
else
  log fail 'Failed to ensure a persistent space to store these scripts'
  log info 'Exiting'
  exit 1
fi
