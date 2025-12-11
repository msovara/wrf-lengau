# Installing WRF with GCC Compilers (Alternative to Intel)

This guide provides instructions for compiling WRF v4.7.1 using GCC compilers when Intel compiler licenses are unavailable.

## Prerequisites

- Access to Lengau cluster
- GCC compiler modules available
- NetCDF modules compatible with GCC

## Step 1: Load GCC Modules

```bash
# Purge all modules
module purge

# Load GCC compiler
module load chpc/gcc/9.2.0  # Or available GCC version
# Check available versions: module avail chpc/gcc

# Load NetCDF modules compatible with GCC
module load chpc/zlib/1.2.8/gcc/9.2.0
module load chpc/hdf5/1.12.0/gcc/9.2.0
module load chpc/netcdf/4.7.4/gcc/9.2.0  # Or compatible version

# Verify modules loaded
module list
```

## Step 2: Set Environment Variables

```bash
# Set compiler environment
export FC=gfortran
export CC=gcc
export CXX=g++
export MPIFC=mpif90  # Should use gfortran
export MPICC=mpicc   # Should use gcc
export MPICXX=mpicxx # Should use g++

# Set NetCDF path
export NETCDF=${NETCDF_ROOT:-/apps/libs/netcdf/4.7.4}  # Adjust to your NetCDF path

# WRF-specific
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export JASPERLIB=/usr/lib64
export JASPERINC=/usr/include

# GCC-specific compiler flags
export FCFLAGS="-O2 -fopenmp"
export CFLAGS="-O2 -fopenmp"
export CXXFLAGS="-O2 -fopenmp"

# Verify compilers
gfortran --version
gcc --version
mpif90 --version  # Should show GCC
```

## Step 3: Navigate to WRF Source

```bash
cd /home/apps/chpc/earth/WRF-4.7.1/build/WRF
```

## Step 4: Configure WRF

```bash
# Run configure interactively
./configure

# When prompted, select:
#   34. (dmpar) GNU (gfortran/gcc)
#   1. Basic nesting (or your preference)
```

Or non-interactively:

```bash
printf "34\n1\n" | ./configure 2>&1 | tee configure.log
```

## Step 5: Verify Configuration

```bash
# Check that configure.wrf was created
ls -la configure.wrf

# Verify it contains GCC settings
grep "SFC.*gfortran" configure.wrf
grep "SCC.*gcc" configure.wrf
```

## Step 6: Compile WRF

```bash
# Clean previous builds (if any)
./clean -a

# Compile em_real case
./compile -j 24 em_real 2>&1 | tee compile.log

# This will take 30-60 minutes
```

## Step 7: Verify Compilation

```bash
# Check for executables
ls -la main/*.exe

# Should see:
# - wrf.exe
# - real.exe
# - ideal.exe
# - ndown.exe
# - tc.exe
```

## Step 8: Install WRF

```bash
# Create installation directory
mkdir -p /home/apps/chpc/earth/WRF-4.7.1/bin

# Copy executables
cp main/*.exe /home/apps/chpc/earth/WRF-4.7.1/bin/

# Copy configure.wrf
cp configure.wrf /home/apps/chpc/earth/WRF-4.7.1/share/wrf/ 2>/dev/null || \
  mkdir -p /home/apps/chpc/earth/WRF-4.7.1/share/wrf && \
  cp configure.wrf /home/apps/chpc/earth/WRF-4.7.1/share/wrf/
```

## Step 9: Create Module File

```bash
# Create module directory
mkdir -p /apps/chpc/scripts/modules/earth

# Create module file
cat > /apps/chpc/scripts/modules/earth/wrf-lengau-gcc << 'EOF'
#%Module1.0
##
## WRF modulefile for Lengau Cluster (GCC version)
##
proc ModulesHelp { } {
    puts stderr "This module sets up the environment for WRF (GCC compiled)"
    puts stderr "WRF v4.7.1 compiled with GCC compilers"
}

module-whatis "WRF - Weather Research and Forecasting Model (GCC compiled)"

set version "4.7.1"
set wrf_root "/home/apps/chpc/earth/WRF-4.7.1"

prepend-path PATH ${wrf_root}/bin
prepend-path LD_LIBRARY_PATH ${wrf_root}/lib

setenv WRF_ROOT ${wrf_root}
setenv WRF_VERSION ${version}
setenv WRF_COMPILER "gcc-9.2.0"
EOF
```

## Step 10: Test Installation

```bash
# Load module
module load chpc/earth/wrf-lengau-gcc

# Check executables
ls -la $WRF_ROOT/bin/*.exe

# Test one executable
$WRF_ROOT/bin/real.exe --version 2>&1 | head -5
```

## Notes

1. **Performance**: GCC-compiled WRF may have slightly different performance characteristics compared to Intel-compiled WRF, but should be functionally equivalent.

2. **Compatibility**: Ensure all NetCDF modules are GCC-compatible. Mixing Intel and GCC modules can cause linking errors.

3. **MPI**: Make sure `mpif90` and `mpicc` use GCC compilers:
   ```bash
   mpif90 --version  # Should show GCC
   mpicc --version   # Should show GCC
   ```

4. **Troubleshooting**: If you encounter linking errors:
   - Verify all modules are GCC-compatible
   - Check `LD_LIBRARY_PATH` includes GCC library paths
   - Ensure NetCDF was compiled with GCC

## Differences from Intel Version

- Compiler: GCC instead of Intel
- Flags: `-fopenmp` instead of `-qopenmp`
- Performance: May differ slightly, but should be acceptable
- Compatibility: Works with GCC-compatible NetCDF modules

## Next Steps

After installing WRF with GCC, you can install WPS using the same GCC compilers. Update `install_wps_lengau.sh` to use GCC modules instead of Intel.

