# Retrying WRF Installation (Option 3: Wait and Retry)

This guide helps you retry the WRF installation when Intel compiler licenses become available.

## Quick Retry Steps

### Step 1: Check License Availability

Before attempting installation, check if Intel compiler licenses are available:

```bash
# Make the check script executable
chmod +x check_intel_licenses.sh

# Run the license check
./check_intel_licenses.sh
```

**If licenses are available**, you'll see:
```
✓ SUCCESS - License available!
```

**If licenses are not available**, you'll see:
```
✗ FAILED - License not available
```

### Step 2: Retry Installation

If licenses are available, retry the installation:

```bash
cd /home/apps/chpc/earth/WRF-4.7.1

# Make sure you have the latest script
cp ~/wrf-lengau/install_wrf_lengau.sh .
chmod +x install_wrf_lengau.sh

# Run installation
./install_wrf_lengau.sh
```

## Best Times to Retry

Intel compiler licenses are shared resources. Try during off-peak hours:

- **Evenings**: After 6 PM
- **Weekends**: Saturday and Sunday
- **Early mornings**: Before 8 AM
- **Holidays**: When fewer users are active

## Automated Retry Script

You can create a simple script to check and retry:

```bash
#!/bin/bash
# retry_wrf_install.sh

MAX_ATTEMPTS=5
WAIT_TIME=300  # 5 minutes between attempts

for i in $(seq 1 $MAX_ATTEMPTS); do
    echo "=== Attempt $i of $MAX_ATTEMPTS ==="
    echo "Checking license availability..."
    
    # Quick license check
    module purge 2>/dev/null
    module load chpc/parallel_studio_xe/16.0.1/2016.1.150 2>/dev/null
    
    if ifort --version &>/dev/null 2>&1; then
        echo "✓ Licenses available! Starting installation..."
        cd /home/apps/chpc/earth/WRF-4.7.1
        ./install_wrf_lengau.sh
        exit $?
    else
        echo "✗ Licenses not available. Waiting ${WAIT_TIME} seconds..."
        sleep $WAIT_TIME
    fi
done

echo "Maximum attempts reached. Please try again later or contact CHPC support."
```

## Manual Retry Process

1. **Check current time and system load:**
   ```bash
   date
   uptime
   ```

2. **Check license availability:**
   ```bash
   ./check_intel_licenses.sh
   ```

3. **If available, proceed with installation:**
   ```bash
   cd /home/apps/chpc/earth/WRF-4.7.1
   ./install_wrf_lengau.sh
   ```

4. **If not available:**
   - Wait 15-30 minutes
   - Try again
   - Or schedule for off-peak hours

## Monitoring License Availability

You can periodically check license status:

```bash
# Quick check function
check_licenses() {
    module purge 2>/dev/null
    module load chpc/parallel_studio_xe/16.0.1/2016.1.150 2>/dev/null
    if ifort --version &>/dev/null 2>&1; then
        echo "$(date): ✓ Licenses available"
        return 0
    else
        echo "$(date): ✗ Licenses not available"
        return 1
    fi
}

# Check every 5 minutes
while true; do
    if check_licenses; then
        echo "Licenses are now available! You can proceed with installation."
        break
    fi
    sleep 300  # Wait 5 minutes
done
```

## PBS Job for Off-Peak Installation

You can submit a PBS job to run during off-peak hours:

```bash
#!/bin/bash
#PBS -N wrf_install_retry
#PBS -l select=1:ncpus=24:mpiprocs=24
#PBS -l walltime=08:00:00
#PBS -q normal
#PBS -o wrf_install.out
#PBS -e wrf_install.err
#PBS -W depend=afterok:JOBID  # Optional: wait for specific job

# Wait for licenses (with timeout)
MAX_WAIT=3600  # 1 hour
WAIT_INTERVAL=300  # 5 minutes
ELAPSED=0

module purge
module load chpc/parallel_studio_xe/16.0.1/2016.1.150

while [ $ELAPSED -lt $MAX_WAIT ]; do
    if ifort --version &>/dev/null 2>&1; then
        echo "$(date): Licenses available, starting installation..."
        cd /home/apps/chpc/earth/WRF-4.7.1
        ./install_wrf_lengau.sh
        exit $?
    else
        echo "$(date): Waiting for licenses... (${ELAPSED}s elapsed)"
        sleep $WAIT_INTERVAL
        ELAPSED=$((ELAPSED + WAIT_INTERVAL))
    fi
done

echo "Timeout waiting for licenses. Installation not started."
exit 1
```

## Troubleshooting

### License Check Fails Immediately

If `check_intel_licenses.sh` shows licenses are not available:

1. **Wait 15-30 minutes** and try again
2. **Check system load**: `uptime` - high load means more users competing for licenses
3. **Try different times**: Evenings, weekends, early mornings

### Installation Starts But Fails During Compilation

If the installation starts but fails with license errors during compilation:

1. The updated script should catch this early
2. Check `configure.log` for compiler test failures
3. Wait and retry when licenses are more available

### Contact CHPC Support

If licenses are consistently unavailable:

1. Contact CHPC support
2. Report the issue
3. Request license server status check
4. Ask about account access to Intel compilers

## Next Steps

Once WRF is successfully installed with Intel compilers:

1. Verify installation: `ls -la $WRF_ROOT/bin/*.exe`
2. Install WPS: `./install_wps_lengau.sh`
3. Test a simple WRF run

## Alternative: GCC Compilers

If Intel licenses remain unavailable after multiple attempts, consider using GCC compilers:

- See `INSTALL_WRF_GCC.md` for GCC installation instructions
- GCC-compiled WRF is functionally equivalent
- Performance may differ slightly but should be acceptable

