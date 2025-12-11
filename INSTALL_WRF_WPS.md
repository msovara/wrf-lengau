# Installing WRF and WPS on Lengau Cluster

This guide provides step-by-step instructions for installing both WRF and WPS on the Lengau cluster.

## Overview

**WRF (Weather Research and Forecasting Model)** and **WPS (WRF Preprocessing System)** work together:
- **WPS** prepares input data for WRF (geographical data, GRIB files)
- **WRF** runs the actual weather simulation

**Important**: WRF must be compiled **before** WPS, as WPS requires the compiled WRF libraries.

## Installation Order

1. **Download WRF source** (DTN node)
2. **Compile WRF** (compute node)
3. **Download WPS source** (DTN node)
4. **Compile WPS** (compute node)

## Step-by-Step Installation

### Step 1: Download WRF Source (DTN Node)

```bash
# SSH to DTN node
ssh msovara@dtn.chpc.ac.za

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy download script
cp ~/wrf-lengau/download_wrf_source.sh .

# Make executable
chmod +x download_wrf_source.sh

# Download WRF source code
./download_wrf_source.sh
```

**Expected time**: 10-15 minutes

### Step 2: Compile WRF (Compute Node)

```bash
# Request interactive compute node
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy installation script
cp ~/wrf-lengau/install_wrf_lengau.sh .

# Make executable
chmod +x install_wrf_lengau.sh

# Run installation
./install_wrf_lengau.sh
```

**Expected time**: 4-8 hours

**Verify WRF installation**:
```bash
# After installation completes
ls -la /home/apps/chpc/earth/WRF-4.7.1/bin/*.exe

# Should see:
# - wrf.exe
# - real.exe
# - ideal.exe
# - etc.
```

### Step 3: Download WPS Source (DTN Node)

```bash
# SSH to DTN node (if not already there)
ssh msovara@dtn.chpc.ac.za

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy download script
cp ~/wrf-lengau/download_wps_source.sh .

# Make executable
chmod +x download_wps_source.sh

# Download WPS source code
./download_wps_source.sh
```

**Expected time**: 5-10 minutes

### Step 4: Compile WPS (Compute Node)

```bash
# Request interactive compute node (if not already on one)
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=02:00:00 -q normal

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy installation script
cp ~/wrf-lengau/install_wps_lengau.sh .

# Make executable
chmod +x install_wps_lengau.sh

# Run installation
./install_wps_lengau.sh
```

**Expected time**: 30-60 minutes

**Verify WPS installation**:
```bash
# After installation completes
ls -la /home/apps/chpc/earth/WRF-4.7.1/bin/*.exe | grep -E "geogrid|ungrib|metgrid"

# Should see:
# - geogrid.exe
# - ungrib.exe
# - metgrid.exe
```

## Quick Installation Script

You can also use this combined script to download both:

```bash
# On DTN node
cd /home/apps/chpc/earth/WRF-4.7.1
./download_wrf_source.sh
./download_wps_source.sh
```

Then compile on compute node:
```bash
# On compute node
./install_wrf_lengau.sh
./install_wps_lengau.sh
```

## Using WRF and WPS

### Load Module

```bash
module load chpc/earth/wrf-lengau
```

### WPS Workflow

1. **geogrid.exe**: Set up domain and geographical data
2. **ungrib.exe**: Extract data from GRIB files
3. **metgrid.exe**: Interpolate meteorological data to WRF grid

### WRF Workflow

1. **real.exe**: Process real atmospheric data (uses WPS output)
2. **wrf.exe**: Run WRF simulation

## Installation Paths

- **Installation Directory**: `/home/apps/chpc/earth/WRF-4.7.1`
- **WRF Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WRF`
- **WPS Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WPS`
- **Executables**: `/home/apps/chpc/earth/WRF-4.7.1/bin`
- **Module File**: `/apps/chpc/scripts/modules/earth/wrf-lengau`

## Troubleshooting

### WPS Compilation Fails

**Error**: "WRF not found" or "configure.wrf not found"

**Solution**: Ensure WRF is compiled first. Check:
```bash
ls -la /home/apps/chpc/earth/WRF-4.7.1/build/WRF/configure.wrf
ls -la /home/apps/chpc/earth/WRF-4.7.1/build/WRF/main/*.exe
```

### WPS Configure Fails

**Error**: "NETCDF not found"

**Solution**: Ensure NetCDF module is loaded:
```bash
module load chpc/netcdf/4.7.4
export NETCDF=/apps/libs/netcdf/4.4.0  # Adjust path as needed
```

## Next Steps

After installation:
1. Download geographical data (GEOG data)
2. Prepare GRIB input files
3. Configure namelist.wps
4. Run WPS workflow (geogrid → ungrib → metgrid)
5. Configure namelist.input for WRF
6. Run WRF workflow (real → wrf)

See [docs/USAGE.md](docs/USAGE.md) for detailed usage instructions.

