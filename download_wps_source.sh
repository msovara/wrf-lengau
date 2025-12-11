#!/bin/bash

# WPS Source Download Script for Lengau Cluster
# This script downloads WPS (WRF Preprocessing System) source code to the cluster
# IMPORTANT: Run this ON THE DTN NODE (dtn.chpc.ac.za) - compute nodes have no internet!
# After downloading, run install_wps_lengau.sh on a compute node

set -e

# Configuration
INSTALL_DIR="/home/apps/chpc/earth/WRF-4.7.1"
BUILD_DIR="${INSTALL_DIR}/build"
WPS_VERSION="v4.7.1"  # Latest version as of December 2025 (should match WRF version)
WPS_SOURCE_URL="https://github.com/wrf-model/WPS.git"

echo "=== WPS Source Download Script ==="
echo "Build directory: ${BUILD_DIR}"
echo "WPS version: ${WPS_VERSION}"
echo ""
echo "NOTE: This script runs on the DTN node (has internet access)"
echo ""

# Create directories
echo "Creating build directory..."
mkdir -p ${BUILD_DIR}

# Check if source already exists
if [ -d "${BUILD_DIR}/WPS" ]; then
    echo "✓ WPS source code already exists at ${BUILD_DIR}/WPS"
    echo "Updating to latest version..."
    cd ${BUILD_DIR}/WPS
    if [ -d ".git" ]; then
        git fetch --all --tags 2>/dev/null || echo "⚠ Git fetch had issues"
        git checkout ${WPS_VERSION} 2>/dev/null || echo "⚠ Could not checkout ${WPS_VERSION}"
        echo "✓ WPS source updated"
    else
        echo "⚠ WPS directory exists but is not a git repository"
        echo "  Consider removing it and re-downloading"
    fi
    exit 0
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo "✗ Git not available. Please install git or download WPS source manually."
    exit 1
fi

# Download WPS source
echo "Downloading WPS source code from GitHub..."
cd ${BUILD_DIR}

# Check if already cloned
if [ -d "WPS" ] && [ -d "WPS/.git" ]; then
    echo "✓ WPS repository already exists, updating..."
    cd WPS
    git fetch --all --tags 2>/dev/null || echo "⚠ Git fetch had issues"
    
    # Checkout specific version if specified
    if [ -n "${WPS_VERSION}" ]; then
        echo "Checking out version ${WPS_VERSION}..."
        git checkout ${WPS_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${WPS_VERSION}, using current branch"
            echo "Available tags:"
            git tag | tail -10
        }
    fi
    echo "✓ WPS repository updated"
    cd ..
else
    # Fresh clone
    echo "Cloning WPS from GitHub (this may take a few minutes)..."
    GIT_SSL_NO_VERIFY=1 git clone ${WPS_SOURCE_URL} WPS || {
        echo "✗ GitHub clone failed"
        echo "Please download WPS source code manually and place it in ${BUILD_DIR}/WPS"
        echo "You can obtain WPS from:"
        echo "  - https://github.com/wrf-model/WPS"
        echo "  - https://www2.mmm.ucar.edu/wrf/users/download/get_source.html"
        exit 1
    }
    
    # Checkout specific version if specified
    if [ -n "${WPS_VERSION}" ]; then
        cd WPS
        echo "Checking out version ${WPS_VERSION}..."
        git checkout ${WPS_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${WPS_VERSION}, using default branch"
            echo "Available tags:"
            git tag | tail -10
        }
        cd ..
    fi
fi

echo ""
echo "=== Download Complete ==="
echo "WPS source code downloaded to: ${BUILD_DIR}/WPS"
echo "WPS version: ${WPS_VERSION}"
echo ""
echo "Next step: Run install_wps_lengau.sh on a compute node to compile and install WPS"
echo "Note: WPS compilation typically takes 30-60 minutes"
echo ""
echo "IMPORTANT: WPS requires WRF to be compiled first!"
echo "Make sure WRF is installed before compiling WPS."

