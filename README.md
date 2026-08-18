# Installation

```
# create a zfs dataset to save scripts from auto deletion
zfs list data/scripts >/dev/null 2>&1 || sudo zfs create data/scripts
```