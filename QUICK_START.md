# WRF Quick Start Guide

Quick start guide for installing WRF on Lengau cluster.

## Prerequisites

- Access to Lengau cluster
- SSH access to DTN node
- ~15 GB disk space

## Quick Installation

### 1. Clone Repository

```bash
git clone https://github.com/msovara/wrf-lengau.git
cd wrf-lengau
```

### 2. Download Source (DTN Node)

```bash
ssh msovara@dtn.chpc.ac.za
cd /home/apps/chpc/earth/WRF-4.7.1
cp ~/wrf-lengau/download_wrf_source.sh .
chmod +x download_wrf_source.sh
./download_wrf_source.sh
```

### 3. Install (Compute Node)

```bash
# Request interactive node
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal

cd /home/apps/chpc/earth/WRF-4.7.1
cp ~/wrf-lengau/install_wrf_lengau.sh .
chmod +x install_wrf_lengau.sh
./install_wrf_lengau.sh
```

### 4. Use WRF

```bash
module load chpc/earth/wrf-lengau
wrf.exe --help
```

## Expected Time

- Download: 10-15 minutes
- Compilation: 4-8 hours
- Total: ~8 hours

## Next Steps

See [docs/USAGE.md](docs/USAGE.md) for usage instructions.

