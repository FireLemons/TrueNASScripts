# Installation

```
# create a zfs dataset to save scripts from auto deletion
zfs list data/scripts >/dev/null 2>&1 || sudo zfs create data/scripts

# set the permissions for the dataset
sudo chmod 755 /mnt/data/scripts
sudo chown $USER:$USER /mnt/data/scripts

# download the scripts
cd /mnt/data/scripts && git clone https://github.com/FireLemons/TrueNASScripts.git

cd TrueNASScripts
```

# Scripts
`setup.sh` set up the environment
