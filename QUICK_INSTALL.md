# Quick Installation Guide: WRF and WPS

Quick reference for installing WRF and WPS on Lengau cluster.

## Prerequisites

- Access to Lengau cluster
- SSH access to DTN node
- ~15 GB disk space
- PBS job allocation

## Installation Steps

### 1. Download Sources (DTN Node)

```bash
ssh msovara@dtn.chpc.ac.za
cd /home/apps/chpc/earth/WRF-4.7.1

# Download WRF
cp ~/wrf-lengau/download_wrf_source.sh .
chmod +x download_wrf_source.sh
./download_wrf_source.sh

# Download WPS
cp ~/wrf-lengau/download_wps_source.sh .
chmod +x download_wps_source.sh
./download_wps_source.sh
```

### 2. Compile WRF (Compute Node)

```bash
# Request interactive node
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal

cd /home/apps/chpc/earth/WRF-4.7.1
cp ~/wrf-lengau/install_wrf_lengau.sh .
chmod +x install_wrf_lengau.sh
./install_wrf_lengau.sh
```

**Time**: 4-8 hours

### 3. Compile WPS (Compute Node)

```bash
# On same or new compute node
cd /home/apps/chpc/earth/WRF-4.7.1
cp ~/wrf-lengau/install_wps_lengau.sh .
chmod +x install_wps_lengau.sh
./install_wps_lengau.sh
```

**Time**: 30-60 minutes

**Important**: WRF must be compiled before WPS!

### 4. Verify Installation

```bash
module load chpc/earth/wrf-lengau

# Check WRF executables
ls -la $WRF_ROOT/bin/wrf.exe
ls -la $WRF_ROOT/bin/real.exe

# Check WPS executables
ls -la $WPS_ROOT/bin/geogrid.exe
ls -la $WPS_ROOT/bin/ungrib.exe
ls -la $WPS_ROOT/bin/metgrid.exe
```

## Installation Paths

- **Installation**: `/home/apps/chpc/earth/WRF-4.7.1`
- **WRF Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WRF`
- **WPS Source**: `/home/apps/chpc/earth/WRF-4.7.1/build/WPS`
- **Executables**: `/home/apps/chpc/earth/WRF-4.7.1/bin`

## Expected Executables

**WRF**:
- `wrf.exe` - Main WRF model
- `real.exe` - Real data processor
- `ideal.exe` - Idealized case

**WPS**:
- `geogrid.exe` - Geographical data processor
- `ungrib.exe` - GRIB file extractor
- `metgrid.exe` - Meteorological data interpolator

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed troubleshooting.

## Next Steps

1. Download geographical data (GEOG)
2. Prepare GRIB input files
3. Configure and run WPS (geogrid → ungrib → metgrid)
4. Configure and run WRF (real → wrf)

See [docs/USAGE.md](docs/USAGE.md) for usage instructions.

