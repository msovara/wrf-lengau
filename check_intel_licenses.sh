#!/bin/bash

# Quick script to check Intel compiler license availability
# Run this before attempting WRF installation

echo "=== Checking Intel Compiler License Availability ==="
echo ""

# Check if license file exists
if [ -f "/apps/compilers/intel/licenses/chpc.lic" ]; then
    echo "✓ License file exists: /apps/compilers/intel/licenses/chpc.lic"
    ls -lh /apps/compilers/intel/licenses/chpc.lic
else
    echo "✗ License file not found!"
    exit 1
fi

echo ""

# Load Intel module
echo "Loading Intel Parallel Studio XE..."
module purge 2>/dev/null
if module load chpc/parallel_studio_xe/16.0.1/2016.1.150 2>/dev/null; then
    echo "✓ Intel module loaded"
else
    echo "✗ Could not load Intel module"
    exit 1
fi

echo ""

# Test if compilers can check out licenses
echo "Testing Intel compiler license checkout..."
echo ""

# Test Fortran compiler
echo -n "Testing ifort... "
if ifort --version &>/dev/null 2>&1; then
    echo "✓ SUCCESS - License available!"
    ifort --version 2>&1 | head -1
else
    ERROR_MSG=$(ifort --version 2>&1 | head -3)
    if echo "$ERROR_MSG" | grep -qi "license"; then
        echo "✗ FAILED - License not available"
        echo "  Error: $(echo "$ERROR_MSG" | head -1)"
    else
        echo "⚠ UNKNOWN - Could not determine license status"
        echo "  Output: $(echo "$ERROR_MSG" | head -1)"
    fi
fi

echo ""

# Test C compiler
echo -n "Testing icc... "
if icc --version &>/dev/null 2>&1; then
    echo "✓ SUCCESS - License available!"
    icc --version 2>&1 | head -1
else
    ERROR_MSG=$(icc --version 2>&1 | head -3)
    if echo "$ERROR_MSG" | grep -qi "license"; then
        echo "✗ FAILED - License not available"
        echo "  Error: $(echo "$ERROR_MSG" | head -1)"
    else
        echo "⚠ UNKNOWN - Could not determine license status"
        echo "  Output: $(echo "$ERROR_MSG" | head -1)"
    fi
fi

echo ""

# Check for license server processes
echo "Checking for license server processes..."
if ps aux | grep -i lmgrd | grep -v grep &>/dev/null; then
    echo "✓ License server (lmgrd) is running:"
    ps aux | grep -i lmgrd | grep -v grep | head -2
else
    echo "⚠ License server (lmgrd) process not found"
    echo "  This may indicate the license server is not running"
fi

if ps aux | grep -i "intel.*license\|license.*intel" | grep -v grep &>/dev/null; then
    echo "✓ Intel license-related processes found:"
    ps aux | grep -i "intel.*license\|license.*intel" | grep -v grep | head -2
fi

echo ""
echo "=== Summary ==="
echo ""
echo "If both compilers (ifort and icc) show 'SUCCESS', you can proceed with WRF installation."
echo "If they show 'FAILED', wait and try again later, or contact CHPC support."
echo ""
echo "Best times to try:"
echo "  - Evenings (after 6 PM)"
echo "  - Weekends"
echo "  - Early mornings (before 8 AM)"
echo ""

