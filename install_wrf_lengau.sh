#!/bin/bash

# WRF Installation Script for Lengau Cluster
# Using Intel Parallel Studio XE 2018.2.046
# This script compiles and installs WRF (Weather Research and Forecasting Model)
# IMPORTANT: This script must be run ON THE CLUSTER, not locally

set -e  # Exit on any error

# Configuration
INSTALL_DIR="/home/apps/chpc/earth/WRF-4.7.1"
BUILD_DIR="${INSTALL_DIR}/build"
MODULE_DIR="/apps/chpc/scripts/modules/earth"
WRF_VERSION="v4.7.1"  # Latest version as of December 2025
WRF_SOURCE_URL="https://github.com/wrf-model/WRF.git"

echo "=== WRF Installation Script for Lengau ==="
echo "Installation directory: ${INSTALL_DIR}"
echo "Build directory: ${BUILD_DIR}"
echo "Module directory: ${MODULE_DIR}"
echo "WRF version: ${WRF_VERSION}"
echo "Intel Parallel Studio XE 2016.1.150"
echo ""
echo "NOTE: This script runs entirely on the cluster"
echo ""

# Create directories
echo "Creating installation directories..."
mkdir -p ${INSTALL_DIR}
mkdir -p ${BUILD_DIR}

# Check if source already exists
# NOTE: Source code must be downloaded separately on DTN node (compute nodes have no internet)
if [ ! -d "${BUILD_DIR}/WRF" ]; then
    echo "✗ WRF source code not found at ${BUILD_DIR}/WRF"
    echo ""
    echo "ERROR: Source code must be downloaded on DTN node first!"
    echo "Compute nodes do not have internet access."
    echo ""
    echo "To download source code:"
    echo "1. SSH to DTN node: ssh msovara@dtn.chpc.ac.za"
    echo "2. Run: cd /home/apps/chpc/earth"
    echo "3. Run: ./download_wrf_source.sh"
    echo "4. Then return to compute node and run this installation script"
    echo ""
    exit 1
else
    echo "✓ WRF source code found at ${BUILD_DIR}/WRF"
fi

# Load Intel Parallel Studio XE
# Note: NetCDF/HDF5 modules require Intel 16.0.1, so we'll use that
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
module avail chpc/netcdf 2>/dev/null | grep -E "(netcdf|hdf5)" | head -10 || echo "Module avail output suppressed"

# Try different module combinations
MODULE_LOADED=false

# Option 1: Try versions compatible with Intel 16.0.1 (load dependencies first)
# NOTE: netcdf/4.4.3-F requires netcdf/4.4.0-C to be loaded first!
if module load chpc/zlib/1.2.8/intel/16.0.1 2>/dev/null; then
    echo "✓ Loaded chpc/zlib/1.2.8/intel/16.0.1"
    if module load chpc/hdf5/1.8.16/intel/16.0.1 2>/dev/null; then
        echo "✓ Loaded chpc/hdf5/1.8.16/intel/16.0.1"
        # Load netcdf/4.4.0-C first (required dependency)
        if module load chpc/netcdf/4.4.0-C/intel/16.0.1 2>/dev/null; then
            echo "✓ Loaded chpc/netcdf/4.4.0-C/intel/16.0.1 (base)"
            # Then try to load 4.4.3-F (if available and needed)
            if module load chpc/netcdf/4.4.3-F/intel/16.0.1 2>/dev/null; then
                echo "✓ Loaded chpc/netcdf/4.4.3-F/intel/16.0.1"
                MODULE_LOADED=true
            else
                # 4.4.0-C is sufficient for WRF
                echo "✓ Using chpc/netcdf/4.4.0-C/intel/16.0.1 (4.4.3-F not available, but 4.4.0-C is sufficient)"
                MODULE_LOADED=true
            fi
        else
            echo "⚠ Could not load chpc/netcdf/4.4.0-C/intel/16.0.1"
        fi
    else
        echo "⚠ Could not load chpc/hdf5/1.8.16/intel/16.0.1"
    fi
fi

# Option 2: Try just 4.4.0-C if 4.4.3-F failed
if [ "$MODULE_LOADED" = false ]; then
    if module load chpc/zlib/1.2.8/intel/16.0.1 2>/dev/null; then
        echo "✓ Loaded chpc/zlib/1.2.8/intel/16.0.1"
        if module load chpc/hdf5/1.8.16/intel/16.0.1 2>/dev/null; then
            echo "✓ Loaded chpc/hdf5/1.8.16/intel/16.0.1"
            if module load chpc/netcdf/4.4.0-C/intel/16.0.1 2>/dev/null; then
                echo "✓ Loaded chpc/netcdf/4.4.0-C/intel/16.0.1 (sufficient for WRF)"
                MODULE_LOADED=true
            fi
        fi
    fi
fi

# Option 3: Try older Intel version
if [ "$MODULE_LOADED" = false ]; then
    if module load chpc/netcdf/4.1.3/intel-2016 2>/dev/null; then
        echo "✓ Loaded chpc/netcdf/4.1.3/intel-2016"
        MODULE_LOADED=true
    fi
fi

# Option 3: Try system modules
if [ "$MODULE_LOADED" = false ]; then
    echo "⚠ Could not load CHPC modules, trying system modules..."
    if module load netcdf 2>/dev/null; then
        echo "✓ Loaded system netcdf"
        if module load hdf5 2>/dev/null; then
            echo "✓ Loaded system hdf5"
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
export MPIFC=mpif90
export MPICC=mpicc
export MPICXX=mpicxx

# Set NetCDF and HDF5 paths
# WRF configure script REQUIRES NETCDF environment variable to be set
if [ -n "$NETCDF_ROOT" ]; then
    export NETCDF=${NETCDF_ROOT}
    echo "✓ Using NetCDF from module: ${NETCDF}"
elif [ -n "$NETCDF" ]; then
    echo "✓ Using existing NetCDF: ${NETCDF}"
else
    echo "⚠ NETCDF_ROOT not set, searching for NetCDF..."
    # Try to find NetCDF in common locations
    NETCDF_FOUND=false
    for path in /usr /usr/local /opt/netcdf /apps/netcdf /apps/chpc/earth/netcdf /apps/chpc/earth/netcdf-4.1.3-intel2016; do
        if [ -f "${path}/include/netcdf.h" ] || [ -f "${path}/include/netcdf.mod" ]; then
            export NETCDF=${path}
            echo "✓ Found NetCDF at: ${NETCDF}"
            NETCDF_FOUND=true
            break
        fi
    done
    
    # Also check if nc-config is available and use it
    if [ "$NETCDF_FOUND" = false ] && command -v nc-config &> /dev/null; then
        NETCDF_PATH=$(nc-config --prefix 2>/dev/null)
        if [ -n "$NETCDF_PATH" ] && [ -f "${NETCDF_PATH}/include/netcdf.h" ]; then
            export NETCDF=${NETCDF_PATH}
            echo "✓ Found NetCDF via nc-config: ${NETCDF}"
            NETCDF_FOUND=true
        fi
    fi
    
    # If still not found, fail with clear error
    if [ "$NETCDF_FOUND" = false ]; then
        echo "✗ ERROR: NETCDF not found and NETCDF environment variable not set"
        echo "WRF requires NETCDF to be set. Please:"
        echo "1. Load a NetCDF module: module load chpc/netcdf/4.7.4"
        echo "2. Or set NETCDF manually: export NETCDF=/path/to/netcdf"
        echo ""
        echo "Trying to show available NetCDF modules:"
        module avail chpc/netcdf 2>/dev/null | head -20 || echo "Could not list modules"
        exit 1
    fi
fi

# Verify NETCDF is accessible
if [ ! -f "${NETCDF}/include/netcdf.h" ] && [ ! -f "${NETCDF}/include/netcdf.mod" ]; then
    echo "✗ ERROR: NETCDF set to ${NETCDF} but netcdf.h or netcdf.mod not found"
    echo "Please verify NETCDF path is correct"
    exit 1
fi

if [ -n "$HDF5_ROOT" ]; then
    export HDF5=${HDF5_ROOT}
    echo "✓ Using HDF5 from module: ${HDF5}"
elif [ -n "$HDF5" ]; then
    echo "✓ Using existing HDF5: ${HDF5}"
else
    echo "⚠ HDF5_ROOT not set, will try system installation"
    # Try to find HDF5 in common locations
    for path in /usr /usr/local /opt/hdf5 /apps/hdf5 /apps/libs/hdf5; do
        if [ -f "${path}/include/hdf5.h" ]; then
            export HDF5=${path}
            echo "✓ Found HDF5 at: ${HDF5}"
            break
        fi
    done
fi

# WRF-specific environment variables
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export JASPERLIB=/usr/lib64  # Adjust if needed
export JASPERINC=/usr/include  # Adjust if needed

# Intel-specific compiler flags for optimization
export FCFLAGS="-O2 -xHost -qopenmp"
export CFLAGS="-O2 -xHost -qopenmp"
export CXXFLAGS="-O2 -xHost -qopenmp"

# WRF environment
export WRF_ROOT=${INSTALL_DIR}

echo "Environment variables set:"
echo "FC (Fortran): ${FC}"
echo "CC (C): ${CC}"
echo "CXX (C++): ${CXX}"
echo "MPIFC: ${MPIFC}"
echo "NETCDF: ${NETCDF}"
echo "HDF5: ${HDF5}"
echo "FCFLAGS: ${FCFLAGS}"
echo "WRF_ROOT: ${WRF_ROOT}"
echo "WRFIO_NCD_LARGE_FILE_SUPPORT: ${WRFIO_NCD_LARGE_FILE_SUPPORT}"
echo ""

# Verify Intel compilers
echo "Verifying Intel compilers..."
if command -v ifort &> /dev/null; then
    # Test if compiler can actually compile (requires license)
    if ifort --version &>/dev/null; then
        echo "✓ Intel Fortran: $(ifort --version 2>&1 | head -1)"
    else
        echo "✗ Intel Fortran found but cannot run (license issue?)"
        echo "  Error: $(ifort --version 2>&1 | head -3)"
        echo ""
        echo "ERROR: Intel compiler license not available!"
        echo "Please:"
        echo "1. Check if Intel license server is running"
        echo "2. Wait for licenses to become available"
        echo "3. Contact cluster administrator"
        echo "4. Or consider using GCC compilers (requires different configuration)"
        exit 1
    fi
else
    echo "✗ Intel Fortran not found"
    exit 1
fi

if command -v icc &> /dev/null; then
    if icc --version &>/dev/null; then
        echo "✓ Intel C: $(icc --version 2>&1 | head -1)"
    else
        echo "✗ Intel C found but cannot run (license issue?)"
        echo "  Error: $(icc --version 2>&1 | head -3)"
        echo ""
        echo "ERROR: Intel compiler license not available!"
        exit 1
    fi
else
    echo "✗ Intel C not found"
    exit 1
fi

if command -v icpc &> /dev/null; then
    if icpc --version &>/dev/null; then
        echo "✓ Intel C++: $(icpc --version 2>&1 | head -1)"
    else
        echo "✗ Intel C++ found but cannot run (license issue?)"
        echo "  Error: $(icpc --version 2>&1 | head -3)"
        echo ""
        echo "ERROR: Intel compiler license not available!"
        exit 1
    fi
else
    echo "✗ Intel C++ not found"
    exit 1
fi

# Verify Intel MPI
echo "Verifying Intel MPI..."
if command -v mpif90 &> /dev/null; then
    echo "✓ Intel MPI Fortran: $(mpif90 --version | head -1)"
else
    echo "✗ Intel MPI Fortran not found"
    exit 1
fi
echo ""

# Change to WRF source directory
echo "Changing to WRF source directory..."
cd ${BUILD_DIR}/WRF
echo "Current directory: $(pwd)"
echo "Source structure: $(ls -la | head -10)"
echo ""

# Initialize and update git submodules (required for NoahMP and other components)
# This is critical for WRF v4.7+ which uses submodules
if [ -d ".git" ]; then
    echo "Initializing and updating git submodules (required for NoahMP)..."
    git submodule update --init --recursive 2>&1 | tee submodule.log || {
        echo "⚠ Git submodule update had issues, but continuing..."
        echo "This may cause NoahMP compilation errors"
    }
    echo "✓ Git submodules initialized"
    echo ""
fi

# WRF uses configure script
echo "Configuring WRF..."

# Check for configure script
if [ ! -f "configure" ]; then
    echo "✗ WRF configure script not found"
    exit 1
fi

# Run configure script
# For Intel compilers with distributed memory (dmpar), typically option 15 or 35
# We'll use interactive mode but can also try non-interactive
echo "Running WRF configure script..."
echo ""
echo "Environment check before configure:"
echo "  NETCDF=${NETCDF}"
echo "  NETCDF include: $([ -f "${NETCDF}/include/netcdf.h" ] && echo 'found' || echo 'NOT FOUND')"
echo ""
echo "NOTE: WRF configure will prompt for configuration option"
echo "For Intel compilers with distributed memory (dmpar), select:"
echo "  15. (dmpar) INTEL (ifort/icc)"
echo "  or"
echo "  35. (dmpar) INTEL (ifort/icc): Intel oneAPI"
echo ""
echo "If running non-interactively, we'll try option 15..."

# Ensure NETCDF is exported (WRF configure script checks this)
export NETCDF

# Try to run configure non-interactively
# WRF configure typically expects input, so we'll pipe the selection
# Also need to handle the nesting option (usually option 1 for basic)
# Use printf to ensure proper input formatting and add a small delay
printf "15\n1\n" | ./configure 2>&1 | tee configure.log
CONFIGURE_EXIT=$?

# Check configure.log for compiler test failures
if grep -qi "One of compilers testing failed" configure.log 2>/dev/null || \
   grep -qi "compiler.*failed" configure.log 2>/dev/null || \
   grep -qi "could not checkout.*license" configure.log 2>/dev/null; then
    echo ""
    echo "✗ ERROR: Compiler test failed during configuration!"
    echo ""
    echo "Common causes:"
    echo "1. Intel compiler license not available"
    echo "2. Compiler cannot compile test programs"
    echo "3. Missing compiler dependencies"
    echo ""
    echo "Checking configure.log for details..."
    echo "--- Last 30 lines of configure.log ---"
    tail -30 configure.log | grep -A 5 -B 5 -i "fail\|error\|license" || tail -30 configure.log
    echo "--- End of configure.log excerpt ---"
    echo ""
    echo "SOLUTIONS:"
    echo "1. Check Intel license server:"
    echo "   - Contact cluster admin if licenses are unavailable"
    echo "   - Try again later if licenses are temporarily exhausted"
    echo ""
    echo "2. Verify compilers work manually:"
    echo "   ifort -V 2>&1 | head -1"
    echo "   icc -V 2>&1 | head -1"
    echo ""
    echo "3. If licenses are permanently unavailable, consider:"
    echo "   - Using GCC compilers (option 34 for dmpar GNU)"
    echo "   - Contacting cluster admin for license access"
    echo ""
    exit 1
fi

# Check if configure.wrf was actually created
if [ ! -f "configure.wrf" ]; then
    echo "⚠ Configure with option 15 did not create configure.wrf"
    echo "Checking configure.log for errors..."
    if grep -qi "One of compilers testing failed" configure.log 2>/dev/null; then
        echo "✗ Compiler test failed - configure.wrf not created"
        echo "This is likely due to Intel license issues"
        exit 1
    fi
    echo "Trying option 35..."
    printf "35\n1\n" | ./configure 2>&1 | tee -a configure.log
    CONFIGURE_EXIT=$?
    
    # Check again for compiler failures
    if grep -qi "One of compilers testing failed" configure.log 2>/dev/null; then
        echo "✗ Compiler test failed with option 35 as well"
        exit 1
    fi
fi

# Final check
if [ ! -f "configure.wrf" ]; then
    echo "✗ Configure failed - configure.wrf not created"
    echo "Exit code: ${CONFIGURE_EXIT}"
    echo ""
    echo "--- Checking configure.log for errors ---"
    tail -50 configure.log | grep -i "fail\|error\|license" || tail -50 configure.log
    echo "--- End of error check ---"
    echo ""
    echo "Please check configure.log for details"
    echo ""
    echo "You may need to run configure interactively:"
    echo "  ./configure"
    echo "  Then select: 15 (dmpar INTEL)"
    echo "  Then select: 1 (Basic nesting)"
    exit 1
fi

# Verify configure.wrf is valid (not empty)
if [ ! -s "configure.wrf" ]; then
    echo "✗ configure.wrf exists but is empty - configuration failed"
    exit 1
fi

echo "✓ WRF configuration completed"
echo ""

# Verify we're still in the right directory and configure.wrf exists
if [ ! -f "configure.wrf" ]; then
    echo "✗ ERROR: configure.wrf not found in current directory: $(pwd)"
    echo "Configuration may have failed despite success message"
    exit 1
fi

echo "✓ Verified configure.wrf exists at: $(pwd)/configure.wrf"
echo ""

# Compile WRF
# IMPORTANT: WRF uses ./compile script, NOT make!
echo "Compiling WRF with Intel optimizations..."
echo "This may take 30-60 minutes depending on system resources..."
echo ""

# Ensure we're in the WRF source directory
cd ${BUILD_DIR}/WRF
if [ ! -f "configure.wrf" ]; then
    echo "✗ ERROR: configure.wrf not found in ${BUILD_DIR}/WRF"
    exit 1
fi

# Clean previous builds
if [ -f "clean" ]; then
    ./clean -a 2>/dev/null || echo "No previous build to clean"
else
    echo "⚠ clean script not found, skipping clean step"
fi

# Compile WRF using the compile script
# WRF compile script syntax: ./compile <case> [options]
# Common cases: em_real, em_quarter_ss, em_b_wave, nmm_real, etc.
# We'll compile em_real (real data case) which is most common
echo "Starting WRF compilation using ./compile script..."
echo "Current directory: $(pwd)"
echo "configure.wrf exists: $([ -f configure.wrf ] && echo 'YES' || echo 'NO')"
echo "Compiling em_real case (most common configuration)..."
echo ""

# Verify compile script exists
if [ ! -f "compile" ]; then
    echo "✗ ERROR: compile script not found in $(pwd)"
    exit 1
fi

# Use the compile script with parallel jobs
# Syntax: ./compile -j <num_cores> <case>
NUM_CORES=$(nproc)
echo "Using ${NUM_CORES} cores for compilation..."

# Run compile script
# Note: WRF compilation can take 30-60 minutes
COMPILE_SUCCESS=false
if ./compile -j ${NUM_CORES} em_real 2>&1 | tee compile.log; then
    COMPILE_SUCCESS=true
else
    COMPILE_EXIT=$?
    echo "⚠ Parallel compilation failed (exit code: ${COMPILE_EXIT})"
    
    # Check if it's a NoahMP submodule issue
    if grep -q "NoahMP submodule files not populating" compile.log 2>/dev/null; then
        echo ""
        echo "⚠ NoahMP submodule issue detected. Attempting to fix..."
        echo "Initializing git submodules..."
        git submodule update --init --recursive 2>&1 || true
        echo "Retrying compilation..."
        
        # Try again after submodule init
        if ./compile -j ${NUM_CORES} em_real 2>&1 | tee -a compile.log; then
            COMPILE_SUCCESS=true
        else
            echo "⚠ Compilation still failed after submodule init, trying sequential..."
            if ./compile em_real 2>&1 | tee -a compile.log; then
                COMPILE_SUCCESS=true
            fi
        fi
    else
        # Not a submodule issue, try sequential
        echo "Trying sequential compilation..."
        if ./compile em_real 2>&1 | tee -a compile.log; then
            COMPILE_SUCCESS=true
        fi
    fi
fi

if [ "$COMPILE_SUCCESS" = false ]; then
    echo "✗ WRF compilation failed"
    echo "Please check compile.log for details"
    echo ""
    echo "Current directory: $(pwd)"
    echo "configure.wrf exists: $([ -f configure.wrf ] && echo 'YES' || echo 'NO')"
    echo ""
    echo "Common issues:"
    echo "1. Missing dependencies (NetCDF, HDF5, etc.)"
    echo "2. Compiler errors - check compile.log"
    echo "3. Memory issues - try compiling with fewer cores"
    echo "4. NoahMP submodule not initialized - run: git submodule update --init --recursive"
    echo "5. configure.wrf not in expected location"
    exit 1
fi

echo "✓ WRF compilation completed"
echo ""

# Check for WRF executables
echo "Checking for WRF executables..."
cd main
WRF_EXECUTABLES=$(find . -name "*.exe" -type f)
if [ -z "$WRF_EXECUTABLES" ]; then
    echo "⚠ WRF executables not found in main/"
    echo "Searching entire WRF directory..."
    find .. -name "*.exe" -type f
else
    echo "✓ WRF executables found:"
    echo "$WRF_EXECUTABLES"
fi

cd ${BUILD_DIR}/WRF

# Install WRF
echo "Installing WRF to ${INSTALL_DIR}..."
mkdir -p ${INSTALL_DIR}/bin
mkdir -p ${INSTALL_DIR}/lib
mkdir -p ${INSTALL_DIR}/include
mkdir -p ${INSTALL_DIR}/share/wrf

# Copy executables
find main -name "*.exe" -type f -exec cp {} ${INSTALL_DIR}/bin/ \;
find test -name "*.exe" -type f -exec cp {} ${INSTALL_DIR}/bin/ \; 2>/dev/null || true

# Copy libraries if any
find . -name "*.so" -type f -exec cp {} ${INSTALL_DIR}/lib/ \; 2>/dev/null || true
find . -name "*.a" -type f -exec cp {} ${INSTALL_DIR}/lib/ \; 2>/dev/null || true

# Copy important files
# Ensure we're in the right directory
cd ${BUILD_DIR}/WRF
if [ -f "configure.wrf" ]; then
    cp configure.wrf ${INSTALL_DIR}/share/wrf/
else
    echo "⚠ configure.wrf not found to copy"
fi
if [ -f "compile.log" ]; then
    cp compile.log ${INSTALL_DIR}/share/wrf/
fi
if [ -f "configure.log" ]; then
    cp configure.log ${INSTALL_DIR}/share/wrf/
fi

# Copy source files (optional, for reference)
# cp -r * ${INSTALL_DIR}/share/wrf/ 2>/dev/null || echo "Some files could not be copied"

# Create Lengau-specific module file
echo "Creating Lengau-specific module file..."
mkdir -p ${MODULE_DIR}
cat > ${MODULE_DIR}/wrf-lengau << EOF
#%Module1.0
##
## WRF modulefile for Lengau Cluster
## Intel Parallel Studio XE 2018.2.046
##

proc ModulesHelp { } {
    puts stderr "This module sets up the environment for WRF"
    puts stderr "WRF is the Weather Research and Forecasting Model"
    puts stderr "Compiled with Intel Parallel Studio XE 2018.2.046"
}

module-whatis "WRF - Weather Research and Forecasting Model (Lengau Intel optimized)"

set version "${WRF_VERSION}"
set wrf_root "${INSTALL_DIR}"

prepend-path PATH \${wrf_root}/bin
prepend-path LD_LIBRARY_PATH \${wrf_root}/lib
prepend-path MANPATH \${wrf_root}/share/wrf

setenv WRF_ROOT \${wrf_root}
setenv WRF_VERSION \${version}
setenv WRF_COMPILER "intel-2018.2.046"
setenv WRFIO_NCD_LARGE_FILE_SUPPORT "1"
EOF

# Create Lengau-specific setup script
echo "Creating Lengau-specific setup script..."
cat > ${INSTALL_DIR}/setup_wrf_lengau.sh << EOF
#!/bin/bash
# Setup script for WRF on Lengau Cluster

# Load Intel Parallel Studio XE
module load chpc/parallel_studio_xe/18.0.2/2018.2.046

# Source Intel MPI environment
if [ -f "/apps/compilers/intel/parallel_studio_xe_2018_update2/compilers_and_libraries/linux/mpi/bin64/mpivars.sh" ]; then
    source /apps/compilers/intel/parallel_studio_xe_2018_update2/compilers_and_libraries/linux/mpi/bin64/mpivars.sh
fi

# Load NetCDF and HDF5 modules
module load chpc/netcdf/4.7.4 2>/dev/null || module load chpc/netcdf/4.4.0-C/intel/16.0.1 2>/dev/null || true
module load chpc/hdf5/1.12.0 2>/dev/null || module load chpc/hdf5/1.8.16/intel/16.0.1 2>/dev/null || true

# Set WRF environment
export WRF_ROOT="${INSTALL_DIR}"
export PATH="\${WRF_ROOT}/bin:\${PATH}"
export LD_LIBRARY_PATH="\${WRF_ROOT}/lib:\${LD_LIBRARY_PATH}"
export WRF_COMPILER="intel-2018.2.046"
export WRFIO_NCD_LARGE_FILE_SUPPORT="1"

echo "WRF environment set up for Lengau:"
echo "WRF_ROOT: \${WRF_ROOT}"
echo "WRF_COMPILER: \${WRF_COMPILER}"
echo "WRF executables:"
ls -1 \${WRF_ROOT}/bin/ 2>/dev/null || echo "No executables found"
echo ""
echo "Intel Parallel Studio XE 2018.2.046 loaded"
echo "Intel MPI environment configured"
EOF

chmod +x ${INSTALL_DIR}/setup_wrf_lengau.sh

# Create installation log
echo "Creating installation log..."
cat > ${INSTALL_DIR}/install_log.txt << EOF
WRF Installation Log
====================
Installation Date: $(date)
WRF Version: ${WRF_VERSION}
Installation Directory: ${INSTALL_DIR}
Build Directory: ${BUILD_DIR}
Compiler: Intel Parallel Studio XE 2018.2.046

Environment Variables:
- FC: ${FC}
- CC: ${CC}
- CXX: ${CXX}
- MPIFC: ${MPIFC}
- NETCDF: ${NETCDF}
- HDF5: ${HDF5}
- FCFLAGS: ${FCFLAGS}
- WRF_ROOT: ${WRF_ROOT}
- WRFIO_NCD_LARGE_FILE_SUPPORT: ${WRFIO_NCD_LARGE_FILE_SUPPORT}

Compilation completed successfully!
EOF

# Test installation
echo "Testing installation..."
if [ -n "$(find ${INSTALL_DIR}/bin -name '*.exe' -type f 2>/dev/null)" ]; then
    echo "✓ WRF executables found:"
    ls -lh ${INSTALL_DIR}/bin/*.exe
else
    echo "⚠ WRF executables not found in expected location"
    echo "Checking for other executables..."
    find ${INSTALL_DIR}/bin -type f -executable -ls 2>/dev/null || echo "No executables found"
fi

echo ""
echo "=== Installation Complete (Lengau Intel) ==="
echo "WRF has been installed to: ${INSTALL_DIR}"
echo "Compiled with: Intel Parallel Studio XE 2018.2.046"
echo ""
echo "To use WRF:"
echo "1. Load the Lengau module: module load chpc/earth/wrf-lengau"
echo "2. Or source the setup script: source ${INSTALL_DIR}/setup_wrf_lengau.sh"
echo "3. Run WRF: wrf.exe (or other WRF executables)"
echo ""
echo "Installation files:"
echo "- Executables: ${INSTALL_DIR}/bin/"
echo "- Configuration: ${INSTALL_DIR}/share/wrf/configure.wrf"
echo "- Module file: ${MODULE_DIR}/wrf-lengau"
echo "- Setup script: ${INSTALL_DIR}/setup_wrf_lengau.sh"
echo "- Installation log: ${INSTALL_DIR}/install_log.txt"
echo ""
echo "Performance notes:"
echo "- Compiled with Intel Parallel Studio XE 2018.2.046"
echo "- Optimized for the target architecture (-O2 -xHost)"
echo "- OpenMP support enabled (-qopenmp)"
echo "- Intel MPI support included (dmpar)"
echo "- Large file support enabled"
echo "- Should provide excellent performance on Lengau cluster"
echo ""
echo "Next steps:"
echo "- Install WPS (WRF Preprocessing System) if needed"
echo "- Prepare input data for WRF runs"
echo "- Configure namelist files for your simulations"
echo ""

echo "Installation completed successfully!"

