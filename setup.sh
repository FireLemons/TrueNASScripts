#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/lib/auth"
source "$REPO_ROOT/lib/interactive"
source "$REPO_ROOT/lib/logger"

verify_non_sudo_user

SCRIPT_PERSISTENT_STORAGE='data/scripts'

does_persistent_dataset_for_scripts_exist() {
  local dataset="$1"
  zfs list "$dataset" &>/dev/null
}

ensure_persisted_dataset_for_scripts () {
  zfs list data/scripts >/dev/null 2>&1 || sudo zfs create data/scripts &&

  sudo chmod 755 /mnt/data/scripts &&
  sudo chown $USER:$USER /mnt/data/scripts
}

set_timezone () {
  local CST='America/Chicago'
  local current_timezone=$(timedatectl | grep "Time zone" | awk '{print $3}')

  if [ "$current_timezone" = "$CST" ]; then
    log okay 'timezone set correctly'
    return 0
  else
    local chronjobs=$(midclt call cronjob.query)

    if [ "$chronjobs" = "[]" ]; then
      log warn "changing timezone to $CST"
      sudo timedatectl set-timezone "$CST"
    else
      log warn 'You have the following cron jobs:'
      log warn "$cronjobs"

      if is_user_approved "change the timezone to $CST?"; then
        sudo timedatectl set-timezone "$CST"
        return 0
      else
        return 1
      fi
    fi
  fi
}

if ensure_persisted_dataset_for_scripts; then
  log okay 'A persistent space to store these scripts has been confirmed'
  # TODO
else
  log fail 'Failed to ensure a persistent space to store these scripts'
  log info 'Exiting'
  exit 1
fi

if set_timezone; then
  log info 'success'
else
  log fail 'nope'
fi
