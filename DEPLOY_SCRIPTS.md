# Deploying WRF Installation Scripts to Cluster

This guide explains how to deploy the WRF installation scripts to the Lengau cluster.

## Option 1: Clone Repository on Cluster

```bash
# On cluster (login node or DTN)
cd /home/apps/chpc/earth/WRF-4.7.1
git clone https://github.com/msovara/wrf-lengau.git
cd wrf-lengau

# Copy scripts to installation directory
cp download_wrf_source.sh ..
cp install_wrf_lengau.sh ..
chmod +x ../download_wrf_source.sh ../install_wrf_lengau.sh
```

## Option 2: Download Individual Scripts

```bash
# On cluster
cd /home/apps/chpc/earth/WRF-4.7.1

# Download scripts directly
wget https://raw.githubusercontent.com/msovara/wrf-lengau/main/download_wrf_source.sh
wget https://raw.githubusercontent.com/msovara/wrf-lengau/main/install_wrf_lengau.sh

chmod +x download_wrf_source.sh install_wrf_lengau.sh
```

## Option 3: Transfer from Local Machine

```bash
# From your local machine
scp download_wrf_source.sh msovara@lengau.chpc.ac.za:/home/apps/chpc/earth/WRF-4.7.1/
scp install_wrf_lengau.sh msovara@lengau.chpc.ac.za:/home/apps/chpc/earth/WRF-4.7.1/

# Then on cluster
ssh msovara@lengau.chpc.ac.za
cd /home/apps/chpc/earth/WRF-4.7.1
chmod +x download_wrf_source.sh install_wrf_lengau.sh
```

## Verification

After deploying, verify scripts are executable:

```bash
ls -la /home/apps/chpc/earth/WRF-4.7.1/*.sh
```

All scripts should show `-rwxr-xr-x` permissions.

## Next Steps

1. Run `download_wrf_source.sh` on DTN node
2. Run `install_wrf_lengau.sh` on compute node
3. See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed instructions

