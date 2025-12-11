# WRF Lengau Repository Summary

## Overview

This repository contains installation scripts and documentation for building and installing WRF (Weather Research and Forecasting Model) v4.7.1 on the CHPC Lengau cluster.

## Repository Structure

```
wrf-lengau/
├── README.md                    # Main documentation
├── LICENSE                      # MIT License
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # Contribution guidelines
├── .gitignore                   # Git ignore rules
├── install_wrf_lengau.sh       # Main installation script
├── download_wrf_source.sh       # Source download script
├── CREATE_REPO.md              # Instructions for creating GitHub repo
├── SETUP_GITHUB.md             # GitHub setup guide
├── REPOSITORY_SUMMARY.md        # This file
├── docs/                       # Documentation
│   ├── INSTALLATION.md         # Detailed installation guide
│   ├── CONFIGURATION.md        # Configuration options
│   ├── TROUBLESHOOTING.md      # Troubleshooting guide
│   └── USAGE.md                # Usage guide
└── examples/                   # Example files (to be added)
```

## Key Features

- **Automated Installation**: Single-command installation process
- **Cluster-Optimized**: Configured for Lengau cluster architecture
- **Latest Version**: WRF v4.7.1 (December 2025)
- **Intel Compiler Support**: Intel Parallel Studio XE 2016.1.150
- **Module System**: Creates Lengau-compatible module files
- **Comprehensive Documentation**: Detailed guides and troubleshooting

## Installation Paths

- **Installation Directory**: `/home/apps/chpc/earth/WRF-4.7.1`
- **Build Directory**: `/home/apps/chpc/earth/WRF-4.7.1/build`
- **Module File**: `/apps/chpc/scripts/modules/earth/wrf-lengau`

## Quick Start

1. Clone repository
2. Download source code on DTN node: `./download_wrf_source.sh`
3. Install on compute node: `./install_wrf_lengau.sh`
4. Load module: `module load chpc/earth/wrf-lengau`

## Documentation

- [README.md](README.md) - Main documentation
- [docs/INSTALLATION.md](docs/INSTALLATION.md) - Detailed installation steps
- [docs/CONFIGURATION.md](docs/CONFIGURATION.md) - Configuration options
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues and solutions
- [docs/USAGE.md](docs/USAGE.md) - Usage instructions

## Next Steps

1. Create GitHub repository
2. Push to GitHub
3. Add example files (namelist templates, PBS scripts)
4. Test installation on cluster

