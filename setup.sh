#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
source "$REPO_ROOT/lib/auth"
source "$REPO_ROOT/lib/interactive"
source "$REPO_ROOT/lib/logger"

verify_non_sudo_user

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

if set_timezone; then
  log info 'success'
else
  log fail 'nope'
fi
