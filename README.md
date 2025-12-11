# WRF Installation for Lengau Cluster

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![CHPC Lengau](https://img.shields.io/badge/Cluster-Lengau-blue)](https://www.chpc.ac.za/)

Comprehensive installation guide and scripts for building and installing **WRF (Weather Research and Forecasting Model)** on the Centre for High Performance Computing (CHPC) Lengau cluster.

## 📋 Table of Contents

- [Overview](#-overview)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Installation Guide](#-installation-guide)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Usage](#-usage)
- [Repository Structure](#-repository-structure)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)
- [Contact](#-contact)
- [References](#-references)
- [Version History](#-version-history)

## 🎯 Overview

This repository provides automated installation scripts for **WRF v4.7.1** and **WPS v4.7.1** on the Lengau HPC cluster. The installation process handles:

- **Compiler Compatibility**: Intel Parallel Studio XE 2016 with GCC 4.8.5 via MPI wrappers
- **Dependency Management**: NetCDF, HDF5, Intel MPI
- **Network Constraints**: Separate DTN node downloads (compute nodes have no internet)
- **WRF Configuration**: Automated configure script execution
- **WPS Configuration**: Automated configure script execution (requires compiled WRF)
- **Module System**: Creates Lengau-compatible module files

### Key Features

✅ **Automated Installation**: Single-command installation process for both WRF and WPS  
✅ **Cluster-Optimized**: Configured specifically for Lengau cluster architecture  
✅ **Error Handling**: Comprehensive error checking and informative messages  
✅ **Module System**: Creates Lengau-compatible module files  
✅ **Documentation**: Detailed troubleshooting and configuration guides  
✅ **WPS Support**: Complete WPS installation with WRF dependency handling  

## 🔧 Prerequisites

### Cluster Access

- Access to Lengau cluster (CHPC account)
- SSH access to DTN node (`dtn.chpc.ac.za`)
- SSH access to compute nodes

### Required Modules

The installation script automatically loads these modules, but ensure they're available:

- `chpc/parallel_studio_xe/16.0.1/2016.1.150`
- `chpc/netcdf/4.7.4` (or compatible version)
- `chpc/hdf5/1.12.0` (or compatible version)

### Disk Space

- **WRF Source Code**: ~500 MB
- **WPS Source Code**: ~100 MB
- **Build Directory**: ~5-10 GB
- **Installation**: ~1 GB
- **Total**: ~15 GB recommended

## 🚀 Quick Start

### 1. Clone This Repository

```bash
git clone https://github.com/msovara/wrf-lengau.git
cd wrf-lengau
```

### 2. Download Source Code (DTN Node)

**Important**: Compute nodes have no internet access. Download must be done on DTN node.

```bash
# SSH to DTN node
ssh msovara@dtn.chpc.ac.za

# Navigate to your workspace
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy scripts from repository
cp ~/wrf-lengau/download_wrf_source.sh .
cp ~/wrf-lengau/install_wrf_lengau.sh .

# Make executable
chmod +x download_wrf_source.sh install_wrf_lengau.sh

# Download WRF source code
./download_wrf_source.sh
```

### 3. Install WRF (Compute Node)

```bash
# SSH to compute node or request interactive node
qsub -I -l select=1:ncpus=24:mpiprocs=24 -l walltime=08:00:00 -q normal

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Run WRF installation script
./install_wrf_lengau.sh
```

**Note**: WRF compilation can take 4-8 hours depending on system resources.

### 4. Download WPS Source (DTN Node)

```bash
# SSH to DTN node
ssh msovara@dtn.chpc.ac.za

# Navigate to installation directory
cd /home/apps/chpc/earth/WRF-4.7.1

# Copy and run WPS download script
cp ~/wrf-lengau/download_wps_source.sh .
chmod +x download_wps_source.sh
./download_wps_source.sh
```

### 5. Install WPS (Compute Node)

```bash
# On compute node (after WRF is compiled)
cd /home/apps/chpc/earth/WRF-4.7.1

# Run WPS installation script
./install_wps_lengau.sh
```

**Note**: WPS compilation typically takes 30-60 minutes. **WPS requires WRF to be compiled first!**

### 6. Load WRF/WPS Module

```bash
module load chpc/earth/wrf-lengau
```

**See [INSTALL_WRF_WPS.md](INSTALL_WRF_WPS.md) for complete installation guide.**

## 📖 Installation Guide

See [docs/INSTALLATION.md](docs/INSTALLATION.md) for detailed installation instructions.

## ⚙️ Configuration

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for configuration options and customization.

## 🔍 Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues and solutions.

## 💻 Usage

See [docs/USAGE.md](docs/USAGE.md) for usage instructions and examples.

## 📁 Repository Structure

```
wrf-lengau/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── CHANGELOG.md                 # Version history
├── CONTRIBUTING.md              # Contribution guidelines
├── install_wrf_lengau.sh        # WRF installation script
├── install_wps_lengau.sh        # WPS installation script
├── download_wrf_source.sh       # WRF source download script
├── download_wps_source.sh       # WPS source download script
├── INSTALL_WRF_WPS.md           # Combined installation guide
├── docs/                        # Documentation
│   ├── INSTALLATION.md          # Detailed installation guide
│   ├── CONFIGURATION.md         # Configuration options
│   ├── TROUBLESHOOTING.md       # Troubleshooting guide
│   └── USAGE.md                 # Usage guide
└── examples/                    # Example files
    ├── namelist.input.template  # WRF namelist template
    └── run_wrf.pbs.template     # PBS job script template
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- CHPC Lengau cluster administrators
- WRF development team
- Intel for compiler tools

## 📧 Contact

For issues and questions, please open an issue on GitHub.

## 📚 References

- [WRF Official Website](https://www.mmm.ucar.edu/models/wrf)
- [WRF GitHub Repository](https://github.com/wrf-model/WRF)
- [WRF User's Guide](https://www2.mmm.ucar.edu/wrf/users/)
- [CHPC Lengau Documentation](https://www.chpc.ac.za/)

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

