#!/usr/bin/env bash

zfs list /mnt/tank/scripts/mediawiki-maintenance >/dev/null 2>&1 || zfs create /mnt/tank/scripts/mediawiki-maintenance
