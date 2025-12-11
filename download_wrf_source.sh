#!/bin/bash

# WRF Source Download Script for Lengau Cluster
# This script downloads WRF source code to the cluster
# IMPORTANT: Run this ON THE DTN NODE (dtn.chpc.ac.za) - compute nodes have no internet!
# After downloading, run install_wrf_lengau.sh on a compute node

set -e

# Configuration
INSTALL_DIR="/home/apps/chpc/earth/WRF-4.7.1"
BUILD_DIR="${INSTALL_DIR}/build"
WRF_VERSION="v4.7.1"  # Latest version as of December 2025
WRF_SOURCE_URL="https://github.com/wrf-model/WRF.git"

echo "=== WRF Source Download Script ==="
echo "Build directory: ${BUILD_DIR}"
echo "WRF version: ${WRF_VERSION}"
echo ""
echo "NOTE: This script runs on the cluster"
echo ""

# Create directories
echo "Creating build directory..."
mkdir -p ${BUILD_DIR}

# Check if source already exists
if [ -d "${BUILD_DIR}/WRF" ]; then
    echo "✓ WRF source code already exists at ${BUILD_DIR}/WRF"
    echo "Updating to latest version..."
    cd ${BUILD_DIR}/WRF
    git fetch --all --tags 2>/dev/null || echo "⚠ Git fetch had issues"
    git checkout ${WRF_VERSION} 2>/dev/null || echo "⚠ Could not checkout ${WRF_VERSION}"
    git submodule update --init --recursive 2>&1 || echo "⚠ Submodule update had issues"
    echo "✓ WRF source updated"
    exit 0
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo "✗ Git not available. Please install git or download WRF source manually."
    exit 1
fi

# Download WRF source
echo "Downloading WRF source code from GitHub..."
cd ${BUILD_DIR}

# Check if already cloned
if [ -d "WRF" ] && [ -d "WRF/.git" ]; then
    echo "✓ WRF repository already exists, updating..."
    cd WRF
    git fetch --all --tags 2>/dev/null || echo "⚠ Git fetch had issues"
    
    # Checkout specific version if specified
    if [ -n "${WRF_VERSION}" ]; then
        echo "Checking out version ${WRF_VERSION}..."
        git checkout ${WRF_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${WRF_VERSION}, using current branch"
            echo "Available tags:"
            git tag | tail -10
        }
    fi
    
    # Always update submodules (critical for WRF v4.7+)
    echo "Updating git submodules (required for NoahMP and other components)..."
    git submodule update --init --recursive 2>&1 || {
        echo "⚠ Git submodule update had issues"
        echo "Attempting to fix submodule references..."
        git submodule sync 2>/dev/null
        git submodule update --init --recursive 2>&1 || {
            echo "⚠ Submodule update still failed, but continuing..."
        }
    }
    echo "✓ Git submodules updated"
    cd ..
else
    # Fresh clone
    echo "Cloning WRF from GitHub (this may take a few minutes)..."
    git clone ${WRF_SOURCE_URL} WRF || {
        echo "✗ GitHub clone failed"
        echo "Please download WRF source code manually and place it in ${BUILD_DIR}/WRF"
        echo "You can obtain WRF from:"
        echo "  - https://github.com/wrf-model/WRF"
        echo "  - https://www2.mmm.ucar.edu/wrf/users/download/get_source.html"
        exit 1
    }
    
    # Checkout specific version if specified
    if [ -n "${WRF_VERSION}" ]; then
        cd WRF
        echo "Checking out version ${WRF_VERSION}..."
        git checkout ${WRF_VERSION} 2>/dev/null || {
            echo "⚠ Could not checkout ${WRF_VERSION}, using default branch"
            echo "Available tags:"
            git tag | tail -10
        }
        cd ..
    fi
    
    # Initialize and update submodules (critical for WRF v4.7+)
    cd WRF
    echo "Initializing git submodules (required for NoahMP and other components)..."
    echo "This may take several minutes as it downloads additional components..."
    git submodule update --init --recursive 2>&1 || {
        echo "⚠ Git submodule initialization had issues"
        echo "Attempting to fix..."
        git submodule sync 2>/dev/null
        git submodule update --init --recursive 2>&1 || {
            echo "⚠ Submodule initialization still failed"
            echo "This may cause compilation errors, but continuing..."
        }
    }
    echo "✓ Git submodules initialized"
    cd ..
fi

echo ""
echo "=== Download Complete ==="
echo "WRF source code downloaded to: ${BUILD_DIR}/WRF"
echo "WRF version: ${WRF_VERSION}"
echo ""
echo "Next step: Run install_wrf_lengau.sh on a compute node to compile and install WRF"
echo "Note: WRF compilation can take 4-8 hours depending on system resources"

