# Troubleshooting Intel Compiler License Errors

## Problem

When running `install_wrf_lengau.sh`, you may encounter errors like:

```
Error: A license for Comp-FL is not available now (-97,121).
A connection to the license server could not be made.
ifort: error #10052: could not checkout FLEXlm license
```

Or during WRF configuration:

```
One of compilers testing failed!
Please check your compiler
```

## Causes

1. **Intel compiler licenses are exhausted** - All available licenses are in use
2. **License server is down** - The FLEXlm license server is not running
3. **Network issues** - Cannot reach the license server
4. **License file issues** - License file path or format is incorrect

## Solutions

### Solution 1: Wait and Retry

If licenses are temporarily exhausted:

```bash
# Wait a few minutes and try again
# Check license availability first
lmutil lmstat -a -c /apps/compilers/intel/licenses/chpc.lic 2>/dev/null || echo "Cannot check licenses"
```

### Solution 2: Check License Server Status

```bash
# Check if license server is running
ps aux | grep lmgrd
ps aux | grep intel

# Check license file
ls -la /apps/compilers/intel/licenses/chpc.lic

# Try to check license status (if lmutil is available)
which lmutil
lmutil lmstat -a -c /apps/compilers/intel/licenses/chpc.lic
```

### Solution 3: Contact Cluster Administrator

If licenses are consistently unavailable:

1. **Contact CHPC support** - Report that Intel compiler licenses are not available
2. **Request license access** - Ask for access to Intel compiler licenses
3. **Check allocation** - Verify your account has access to Intel compilers

### Solution 4: Use GCC Compilers (Alternative)

If Intel licenses are permanently unavailable, you can compile WRF with GCC:

**Note**: This requires different NetCDF modules and may have different performance characteristics.

```bash
# Load GCC modules instead
module purge
module load chpc/gcc/9.2.0  # Or available GCC version

# Load NetCDF modules compatible with GCC
module load chpc/zlib/1.2.8/gcc/9.2.0
module load chpc/hdf5/1.12.0/gcc/9.2.0
module load chpc/netcdf/4.7.4/gcc/9.2.0

# Run configure manually and select GCC option
cd /home/apps/chpc/earth/WRF-4.7.1/build/WRF
./configure
# Select: 34 (dmpar) GNU (gfortran/gcc)
# Select: 1 (Basic nesting)

# Then compile
./compile -j 24 em_real
```

**Important**: If using GCC, you'll need to:
- Update the installation script to use GCC modules
- Use GCC-compatible NetCDF modules
- Note that performance may differ from Intel-compiled WRF

## Verification

To verify compilers work before running the installation:

```bash
# Load Intel modules
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

# Test Fortran compiler
ifort --version
echo "program test; end program" > test.f90
ifort test.f90 -o test.exe && echo "✓ Fortran compiler works" || echo "✗ Fortran compiler failed"
rm -f test.f90 test.exe

# Test C compiler
icc --version
echo "int main(){return 0;}" > test.c
icc test.c -o test.exe && echo "✓ C compiler works" || echo "✗ C compiler failed"
rm -f test.c test.exe
```

## Prevention

To avoid license issues:

1. **Compile during off-peak hours** - Fewer users competing for licenses
2. **Use PBS jobs** - Submit compilation as a job rather than interactive session
3. **Check license availability first** - Verify licenses before starting long compilation

## Example PBS Job Script

```bash
#!/bin/bash
#PBS -N wrf_compile
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=08:00:00
#PBS -q normal
#PBS -o wrf_compile.out
#PBS -e wrf_compile.err

cd /home/apps/chpc/earth/WRF-4.7.1
./install_wrf_lengau.sh
```

This ensures you have dedicated resources and may have better license availability.

## Related Files

- `install_wrf_lengau.sh` - Main installation script
- `docs/TROUBLESHOOTING.md` - General troubleshooting guide
- `configure.log` - WRF configuration log (check for compiler errors)

