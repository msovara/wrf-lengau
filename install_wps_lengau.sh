#!/bin/bash

# WPS Installation Script for Lengau Cluster
# Using Intel Parallel Studio XE 2016.1.150
# This script compiles and installs WPS (WRF Preprocessing System)
# IMPORTANT: This script must be run ON THE CLUSTER, not locally
# IMPORTANT: WRF must be compiled BEFORE compiling WPS!

set -e  # Exit on any error

# Configuration
INSTALL_DIR="/home/apps/chpc/earth/WRF-4.7.1"
BUILD_DIR="${INSTALL_DIR}/build"
MODULE_DIR="/apps/chpc/scripts/modules/earth"
WPS_VERSION="v4.7.1"  # Latest version as of December 2025 (should match WRF version)
WPS_SOURCE_URL="https://github.com/wrf-model/WPS.git"
WRF_DIR="${BUILD_DIR}/WRF"  # WRF must be compiled first

echo "=== WPS Installation Script for Lengau ==="
echo "Installation directory: ${INSTALL_DIR}"
echo "Build directory: ${BUILD_DIR}"
echo "Module directory: ${MODULE_DIR}"
echo "WPS version: ${WPS_VERSION}"
echo "WRF directory: ${WRF_DIR}"
echo "Intel Parallel Studio XE 2016.1.150"
echo ""
echo "NOTE: This script runs entirely on the cluster"
echo "NOTE: WRF must be compiled before WPS!"
echo ""

# Create directories
echo "Creating installation directories..."
mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}

# Check if WRF is compiled
if [ ! -d "${WRF_DIR}" ]; then
    echo "✗ WRF source code not found at ${WRF_DIR}"
    echo ""
    echo "ERROR: WRF must be compiled before WPS!"
    echo "Please compile WRF first using install_wrf_lengau.sh"
    exit 1
fi

# Check if WRF is actually compiled (look for configure.wrf)
if [ ! -f "${WRF_DIR}/configure.wrf" ]; then
    echo "⚠ WRF configure.wrf not found"
    echo "  WRF may not be configured. Please configure and compile WRF first."
    exit 1
fi

# Check for WRF executables (at least one should exist)
if [ -z "$(find ${WRF_DIR}/main -name "*.exe" -type f 2>/dev/null | head -1)" ]; then
    echo "⚠ WRF executables not found in ${WRF_DIR}/main"
    echo "  WRF must be compiled before WPS!"
    echo "  Please run install_wrf_lengau.sh first"
    exit 1
else
    echo "✓ WRF is compiled (found executables)"
fi

# Check if WPS source exists
if [ ! -d "${BUILD_DIR}/WPS" ]; then
    echo "✗ WPS source code not found at ${BUILD_DIR}/WPS"
    echo ""
    echo "ERROR: Source code must be downloaded on DTN node first!"
    echo "Compute nodes do not have internet access."
    echo ""
    echo "To download source code:"
    echo "1. SSH to DTN node: ssh msovara@dtn.chpc.ac.za"
    echo "2. Run: cd /home/apps/chpc/earth/WRF-4.7.1"
    echo "3. Run: ./download_wps_source.sh"
    echo "4. Then return to compute node and run this installation script"
    echo ""
    exit 1
else
    echo "✓ WPS source code found at ${BUILD_DIR}/WPS"
fi

# Load Intel Parallel Studio XE
echo "Loading Intel Parallel Studio XE..."
module purge

# Try Intel 16.0.1 first (required by NetCDF/HDF5 modules)
if module load chpc/parallel_studio_xe/16.0.1/2016.1.150 2>/dev/null; then
    echo "✓ Loaded chpc/parallel_studio_xe/16.0.1/2016.1.150"
    INTEL_VERSION="16.0.1"
else
    # Fallback to 2018 if 2016 not available
    if module load chpc/parallel_studio_xe/18.0.2/2018.2.046 2>/dev/null; then
        echo "✓ Loaded chpc/parallel_studio_xe/18.0.2/2018.2.046"
        INTEL_VERSION="18.0.2"
    else
        echo "✗ Could not load Intel Parallel Studio XE"
        exit 1
    fi
fi

# Source Intel MPI environment (if available)
echo "Setting up Intel MPI environment..."
if [ "$INTEL_VERSION" = "16.0.1" ]; then
    if [ -f "/apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh" ]; then
        source /apps/compilers/intel/parallel_studio_xe_2016/compilers_and_libraries/linux/mpi/intel64/bin/mpivars.sh
        echo "✓ Intel MPI environment configured (2016)"
    fi
elif [ "$INTEL_VERSION" = "18.0.2" ]; then
    if [ -f "/apps/compilers/intel/parallel_studio_xe_2018_update2/compilers_and_libraries/linux/mpi/bin64/mpivars.sh" ]; then
        source /apps/compilers/intel/parallel_studio_xe_2018_update2/compilers_and_libraries/linux/mpi/bin64/mpivars.sh
        echo "✓ Intel MPI environment configured (2018)"
    fi
fi

echo "✓ Intel Parallel Studio XE loaded (version ${INTEL_VERSION})"

# Load other required modules
echo "Loading other required modules..."

# Try to load compatible NetCDF and HDF5 modules
echo "Checking available NetCDF and HDF5 modules..."

# Try different module combinations
MODULE_LOADED=false

# Option 1: Try versions compatible with Intel 16.0.1
if module load chpc/zlib/1.2.8/intel/16.0.1 2>/dev/null; then
    echo "✓ Loaded chpc/zlib/1.2.8/intel/16.0.1"
    if module load chpc/hdf5/1.8.16/intel/16.0.1 2>/dev/null; then
        echo "✓ Loaded chpc/hdf5/1.8.16/intel/16.0.1"
        if module load chpc/netcdf/4.4.0-C/intel/16.0.1 2>/dev/null; then
            echo "✓ Loaded chpc/netcdf/4.4.0-C/intel/16.0.1"
            MODULE_LOADED=true
        fi
    fi
fi

# Option 2: Try newer versions
if [ "$MODULE_LOADED" = false ]; then
    if module load chpc/netcdf/4.7.4 2>/dev/null; then
        echo "✓ Loaded chpc/netcdf/4.7.4"
        if module load chpc/hdf5/1.12.0 2>/dev/null; then
            echo "✓ Loaded chpc/hdf5/1.12.0"
            MODULE_LOADED=true
        fi
    fi
fi

if [ "$MODULE_LOADED" = false ]; then
    echo "⚠ Could not load NetCDF/HDF5 modules automatically"
    echo "  Will try to use system-installed libraries"
fi

# Set Intel compiler environment variables
export FC=ifort
export CC=icc
export CXX=icpc
export F77=ifort
export F90=ifort

# Set NetCDF and HDF5 paths
if [ -n "$NETCDF_ROOT" ]; then
    export NETCDF=${NETCDF_ROOT}
    echo "✓ Using NetCDF from module: ${NETCDF}"
elif [ -n "$NETCDF" ]; then
    echo "✓ Using existing NetCDF: ${NETCDF}"
else
    echo "⚠ NETCDF_ROOT not set, searching for NetCDF..."
    NETCDF_FOUND=false
    for path in /usr /usr/local /opt/netcdf /apps/netcdf /apps/chpc/earth/netcdf /apps/libs/netcdf; do
        if [ -f "${path}/include/netcdf.h" ] || [ -f "${path}/include/netcdf.mod" ]; then
            export NETCDF=${path}
            echo "✓ Found NetCDF at: ${NETCDF}"
            NETCDF_FOUND=true
            break
        fi
    done
    
    if [ "$NETCDF_FOUND" = false ] && command -v nc-config &> /dev/null; then
        NETCDF_PATH=$(nc-config --prefix 2>/dev/null)
        if [ -n "$NETCDF_PATH" ] && [ -f "${NETCDF_PATH}/include/netcdf.h" ]; then
            export NETCDF=${NETCDF_PATH}
            echo "✓ Found NetCDF via nc-config: ${NETCDF}"
            NETCDF_FOUND=true
        fi
    fi
    
    if [ "$NETCDF_FOUND" = false ]; then
        echo "✗ ERROR: NETCDF not found and NETCDF environment variable not set"
        echo "WPS requires NETCDF to be set. Please:"
        echo "1. Load a NetCDF module: module load chpc/netcdf/4.7.4"
        echo "2. Or set NETCDF manually: export NETCDF=/path/to/netcdf"
        exit 1
    fi
fi

# Verify NETCDF is accessible
if [ ! -f "${NETCDF}/include/netcdf.h" ] && [ ! -f "${NETCDF}/include/netcdf.mod" ]; then
    echo "✗ ERROR: NETCDF set to ${NETCDF} but netcdf.h or netcdf.mod not found"
    echo "Please verify NETCDF path is correct"
    exit 1
fi

# Set WRF_DIR (required by WPS configure)
export WRF_DIR=${WRF_DIR}

# WPS-specific environment variables
export JASPERLIB=/usr/lib64  # Adjust if needed
export JASPERINC=/usr/include  # Adjust if needed

# Intel-specific compiler flags
export FCFLAGS="-O2 -xHost"
export CFLAGS="-O2 -xHost"
export CXXFLAGS="-O2 -xHost"

# WPS environment
export WPS_ROOT=${INSTALL_DIR}

echo ""
echo "Environment variables set:"
echo "FC (Fortran): ${FC}"
echo "CC (C): ${CC}"
echo "NETCDF: ${NETCDF}"
echo "WRF_DIR: ${WRF_DIR}"
echo "WPS_ROOT: ${WPS_ROOT}"
echo ""

# Verify Intel compilers
echo "Verifying Intel compilers..."
if command -v ifort &> /dev/null; then
    echo "✓ Intel Fortran: $(ifort --version | head -1)"
else
    echo "✗ Intel Fortran not found"
    exit 1
fi

if command -v icc &> /dev/null; then
    echo "✓ Intel C: $(icc --version | head -1)"
else
    echo "✗ Intel C not found"
    exit 1
fi
echo ""

# Change to WPS source directory
echo "Changing to WPS source directory..."
cd ${BUILD_DIR}/WPS
echo "Current directory: $(pwd)"
echo ""

# Check for configure script
if [ ! -f "configure" ]; then
    echo "✗ WPS configure script not found"
    exit 1
fi

# WPS uses configure script
echo "Configuring WPS..."
echo ""
echo "Environment check before configure:"
echo "  NETCDF=${NETCDF}"
echo "  NETCDF include: $([ -f "${NETCDF}/include/netcdf.h" ] && echo 'found' || echo 'NOT FOUND')"
echo "  WRF_DIR=${WRF_DIR}"
echo "  WRF_DIR exists: $([ -d "${WRF_DIR}" ] && echo 'YES' || echo 'NO')"
echo ""
echo "NOTE: WPS configure will prompt for configuration option"
echo "For Intel compilers, select:"
echo "  3. Linux x86_64, Intel compiler (serial)"
echo "  or"
echo "  19. Linux x86_64, Intel compiler (serial) with GRIB2"
echo ""
echo "If running non-interactively, we'll try option 3 first..."

# Ensure NETCDF and WRF_DIR are exported
export NETCDF
export WRF_DIR

# Try to run configure non-interactively
# WPS configure typically expects input, so we'll pipe the selection
printf "3\n" | ./configure 2>&1 | tee configure.log
CONFIGURE_EXIT=$?

# Check if configure.wps was created
if [ ! -f "configure.wps" ]; then
    echo "⚠ Configure with option 3 did not create configure.wps, trying option 19 (with GRIB2)..."
    printf "19\n" | ./configure 2>&1 | tee -a configure.log
    CONFIGURE_EXIT=$?
fi

# Final check
if [ ! -f "configure.wps" ]; then
    echo "✗ Configure failed - configure.wps not created"
    echo "Exit code: ${CONFIGURE_EXIT}"
    echo "Please check configure.log for details"
    echo ""
    echo "You may need to run configure interactively:"
    echo "  ./configure"
    echo "  Then select: 3 (Linux x86_64, Intel compiler serial)"
    exit 1
fi

echo "✓ WPS configuration completed"
echo ""

# Verify we're still in the right directory and configure.wps exists
if [ ! -f "configure.wps" ]; then
    echo "✗ ERROR: configure.wps not found in current directory: $(pwd)"
    echo "Configuration may have failed despite success message"
    exit 1
fi

echo "✓ Verified configure.wps exists at: $(pwd)/configure.wps"
echo ""

# Compile WPS
# IMPORTANT: WPS uses ./compile script, NOT make!
echo "Compiling WPS with Intel optimizations..."
echo "This may take 30-60 minutes depending on system resources..."
echo ""

# Ensure we're in the WPS source directory
cd ${BUILD_DIR}/WPS
if [ ! -f "configure.wps" ]; then
    echo "✗ ERROR: configure.wps not found in ${BUILD_DIR}/WPS"
    exit 1
fi

# Clean previous builds
if [ -f "clean" ]; then
    ./clean 2>/dev/null || echo "No previous build to clean"
else
    echo "⚠ clean script not found, skipping clean step"
fi

# Compile WPS using the compile script
# WPS compile script syntax: ./compile [options]
echo "Starting WPS compilation using ./compile script..."
echo "Current directory: $(pwd)"
echo "configure.wps exists: $([ -f configure.wps ] && echo 'YES' || echo 'NO')"
echo ""

# Verify compile script exists
if [ ! -f "compile" ]; then
    echo "✗ ERROR: compile script not found in $(pwd)"
    exit 1
fi

# Use the compile script
# Note: WPS compilation typically takes 30-60 minutes
COMPILE_SUCCESS=false
if ./compile 2>&1 | tee compile.log; then
    COMPILE_SUCCESS=true
else
    COMPILE_EXIT=$?
    echo "⚠ Compilation failed (exit code: ${COMPILE_EXIT})"
    echo "Please check compile.log for details"
fi

if [ "$COMPILE_SUCCESS" = false ]; then
    echo "✗ WPS compilation failed"
    echo "Please check compile.log for details"
    echo ""
    echo "Current directory: $(pwd)"
    echo "configure.wps exists: $([ -f configure.wps ] && echo 'YES' || echo 'NO')"
    echo ""
    echo "Common issues:"
    echo "1. Missing dependencies (NetCDF, HDF5, etc.)"
    echo "2. Compiler errors - check compile.log"
    echo "3. WRF not compiled - WPS requires compiled WRF"
    echo "4. NETCDF path incorrect"
    echo "5. configure.wps not in expected location"
    exit 1
fi

echo "✓ WPS compilation completed"
echo ""

# Check for WPS executables
echo "Checking for WPS executables..."
WPS_EXECUTABLES=$(find . -name "*.exe" -type f)
if [ -z "$WPS_EXECUTABLES" ]; then
    echo "⚠ WPS executables not found in current directory"
    echo "Searching entire WPS directory..."
    find .. -name "*.exe" -type f
else
    echo "✓ WPS executables found:"
    echo "$WPS_EXECUTABLES"
fi

# Install WPS
echo "Installing WPS to ${INSTALL_DIR}..."
mkdir -p ${INSTALL_DIR}/bin
mkdir -p ${INSTALL_DIR}/lib
mkdir -p ${INSTALL_DIR}/include
mkdir -p ${INSTALL_DIR}/share/wps

# Copy executables
find . -name "*.exe" -type f -exec cp {} ${INSTALL_DIR}/bin/ \;

# Copy important files
cd ${BUILD_DIR}/WPS
if [ -f "configure.wps" ]; then
    cp configure.wps ${INSTALL_DIR}/share/wps/
else
    echo "⚠ configure.wps not found to copy"
fi
if [ -f "compile.log" ]; then
    cp compile.log ${INSTALL_DIR}/share/wps/
fi
if [ -f "configure.log" ]; then
    cp configure.log ${INSTALL_DIR}/share/wps/
fi

# Update module file to include WPS
echo "Updating module file to include WPS..."
mkdir -p ${MODULE_DIR}
if [ -f "${MODULE_DIR}/wrf-lengau" ]; then
    # Append WPS paths to existing module file
    if ! grep -q "WPS_ROOT" "${MODULE_DIR}/wrf-lengau"; then
        cat >> ${MODULE_DIR}/wrf-lengau << EOF

# WPS paths
setenv WPS_ROOT \${wrf_root}
prepend-path PATH \${wrf_root}/bin
EOF
        echo "✓ Updated module file with WPS paths"
    else
        echo "✓ Module file already includes WPS paths"
    fi
else
    # Create new module file
    cat > ${MODULE_DIR}/wrf-lengau << EOF
#%Module1.0
##
## WRF/WPS modulefile for Lengau Cluster
## Intel Parallel Studio XE 2016.1.150
##

proc ModulesHelp { } {
    puts stderr "This module sets up the environment for WRF and WPS"
    puts stderr "WRF is the Weather Research and Forecasting Model"
    puts stderr "WPS is the WRF Preprocessing System"
    puts stderr "Compiled with Intel Parallel Studio XE 2016.1.150"
}

module-whatis "WRF/WPS - Weather Research and Forecasting Model and Preprocessing System (Lengau Intel optimized)"

set version "${WPS_VERSION}"
set wrf_root "${INSTALL_DIR}"

prepend-path PATH \${wrf_root}/bin
prepend-path LD_LIBRARY_PATH \${wrf_root}/lib
prepend-path MANPATH \${wrf_root}/share/wrf

setenv WRF_ROOT \${wrf_root}
setenv WPS_ROOT \${wrf_root}
setenv WRF_VERSION \${version}
setenv WPS_VERSION \${version}
setenv WRF_COMPILER "intel-2016.1.150"
setenv WRFIO_NCD_LARGE_FILE_SUPPORT "1"
EOF
    echo "✓ Created module file with WRF and WPS paths"
fi

# Create installation log
echo "Creating installation log..."
cat >> ${INSTALL_DIR}/install_log.txt << EOF

WPS Installation
================
Installation Date: $(date)
WPS Version: ${WPS_VERSION}
WRF Directory: ${WRF_DIR}

Environment Variables:
- FC: ${FC}
- CC: ${CC}
- NETCDF: ${NETCDF}
- WRF_DIR: ${WRF_DIR}
- WPS_ROOT: ${WPS_ROOT}

Compilation completed successfully!
EOF

# Test installation
echo "Testing installation..."
if [ -n "$(find ${INSTALL_DIR}/bin -name "geogrid.exe" -o -name "ungrib.exe" -o -name "metgrid.exe" -type f 2>/dev/null)" ]; then
    echo "✓ WPS executables found:"
    ls -lh ${INSTALL_DIR}/bin/geogrid.exe ${INSTALL_DIR}/bin/ungrib.exe ${INSTALL_DIR}/bin/metgrid.exe 2>/dev/null || \
    find ${INSTALL_DIR}/bin -name "*.exe" -type f -exec ls -lh {} \;
else
    echo "⚠ WPS executables not found in expected location"
    echo "Checking for other executables..."
    find ${INSTALL_DIR}/bin -name "*.exe" -type f -ls 2>/dev/null || echo "No executables found"
fi

echo ""
echo "=== WPS Installation Complete (Lengau Intel) ==="
echo "WPS has been installed to: ${INSTALL_DIR}"
echo "Compiled with: Intel Parallel Studio XE 2016.1.150"
echo ""
echo "WPS Executables:"
echo "- geogrid.exe: Processes geographical data"
echo "- ungrib.exe: Extracts data from GRIB files"
echo "- metgrid.exe: Interpolates meteorological data to WRF grid"
echo ""
echo "To use WPS:"
echo "1. Load the Lengau module: module load chpc/earth/wrf-lengau"
echo "2. Or source the setup script: source ${INSTALL_DIR}/setup_wrf_lengau.sh"
echo "3. Run WPS executables: geogrid.exe, ungrib.exe, metgrid.exe"
echo ""
echo "Installation files:"
echo "- Executables: ${INSTALL_DIR}/bin/"
echo "- Configuration: ${INSTALL_DIR}/share/wps/configure.wps"
echo "- Module file: ${MODULE_DIR}/wrf-lengau"
echo "- Installation log: ${INSTALL_DIR}/install_log.txt"
echo ""
echo "Next steps:"
echo "- Prepare geographical data (GEOG data)"
echo "- Download GRIB files for your simulation"
echo "- Run geogrid.exe to set up domain"
echo "- Run ungrib.exe to extract GRIB data"
echo "- Run metgrid.exe to interpolate to WRF grid"
echo "- Use output with WRF real.exe"
echo ""
echo "Installation completed successfully!"

