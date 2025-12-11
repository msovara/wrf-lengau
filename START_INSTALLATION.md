# Starting WRF and WPS Installation on Lengau

## Current Status

You are in: `/home/apps/chpc/earth`
- ✅ MPAS-8.3.1 is installed
- ⏳ WRF-4.7.1 needs to be installed
- ⏳ WPS-4.7.1 needs to be installed

## Step 1: Get Installation Scripts

First, get the scripts from the GitHub repository:

```bash
# Clone or update the repository
cd ~
git clone https://github.com/msovara/wrf-lengau.git
# Or if already cloned:
cd ~/wrf-lengau
git pull
```

## Step 2: Create WRF Installation Directory

```bash
cd /home/apps/chpc/earth
mkdir -p WRF-4.7.1
cd WRF-4.7.1

# Copy scripts
cp ~/wrf-lengau/download_wrf_source.sh .
cp ~/wrf-lengau/download_wps_source.sh .
cp ~/wrf-lengau/install_wrf_lengau.sh .
cp ~/wrf-lengau/install_wps_lengau.sh .

# Make executable
chmod +x *.sh
```

## Step 3: Download Source Code (DTN Node)

**Important**: Must be done on DTN node (has internet access)

```bash
# SSH to DTN node
ssh msovara@dtn.chpc.ac.za

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Download WRF source
./download_wrf_source.sh

# Download WPS source
./download_wps_source.sh

# Exit DTN node
exit
```

## Step 4: Compile WRF (Compute Node)

```bash
# Request interactive compute node
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal

# Once on compute node
cd /home/apps/chpc/earth/WRF-4.7.1

# Run WRF installation
./install_wrf_lengau.sh
```

**Expected time**: 4-8 hours

## Step 5: Compile WPS (Compute Node)

**Important**: Only after WRF is successfully compiled!

```bash
# On compute node (same or new)
cd /home/apps/chpc/earth/WRF-4.7.1

# Run WPS installation
./install_wps_lengau.sh
```

**Expected time**: 30-60 minutes

## Step 6: Verify Installation

```bash
# Load module
module load chpc/earth/wrf-lengau

# Check WRF executables
ls -la $WRF_ROOT/bin/wrf.exe
ls -la $WRF_ROOT/bin/real.exe

# Check WPS executables
ls -la $WPS_ROOT/bin/geogrid.exe
ls -la $WPS_ROOT/bin/ungrib.exe
ls -la $WPS_ROOT/bin/metgrid.exe
```

## Quick Commands Summary

```bash
# 1. Get scripts
cd ~
git clone https://github.com/msovara/wrf-lengau.git

# 2. Setup directory
cd /home/apps/chpc/earth
mkdir -p WRF-4.7.1
cd WRF-4.7.1
cp ~/wrf-lengau/*.sh .
chmod +x *.sh

# 3. On DTN node: Download sources
ssh msovara@dtn.chpc.ac.za
cd /home/apps/chpc/earth/WRF-4.7.1
./download_wrf_source.sh
./download_wps_source.sh
exit

# 4. On compute node: Compile WRF
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal
cd /home/apps/chpc/earth/WRF-4.7.1
./install_wrf_lengau.sh

# 5. On compute node: Compile WPS (after WRF completes)
cd /home/apps/chpc/earth/WRF-4.7.1
./install_wps_lengau.sh
```

## Installation Paths

- **Installation**: `/home/apps/chpc/earth/WRF-4.7.1`
- **WRF Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WRF`
- **WPS Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WPS`
- **Executables**: `/home/apps/chpc/earth/WRF-4.7.1/bin`

## Need Help?

- See [INSTALL_WRF_WPS.md](INSTALL_WRF_WPS.md) for detailed guide
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues
- Check installation logs: `/home/apps/chpc/earth/WRF-4.7.1/install_log.txt`

