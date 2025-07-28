#!/usr/bin/env bash

set -euo pipefail

# AWS Lambda Layer Builder for Python
# Uses official AWS SAM CLI build images

# Configuration
PYTHON_VERSION="3.9"
OUTPUT_DIR="."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Find requirements.txt if not specified
if [[ -z "${REQUIREMENTS_FILE:-}" ]]; then
    if [[ -f "requirements.txt" ]]; then
        REQUIREMENTS_FILE="requirements.txt"
        log "Using requirements.txt from current directory"
    elif [[ -f "function/requirements.txt" ]]; then
        REQUIREMENTS_FILE="function/requirements.txt"
        log "Using requirements.txt from function/ directory"
    else
        # Check if Poetry is being used
        if [[ -f "function/pyproject.toml" ]]; then
            log "Found Poetry project, exporting requirements..."
            (cd function && poetry export -f requirements.txt --output requirements.txt --without-hashes)
            REQUIREMENTS_FILE="function/requirements.txt"
        elif [[ -f "pyproject.toml" ]]; then
            log "Found Poetry project, exporting requirements..."
            poetry export -f requirements.txt --output requirements.txt --without-hashes
            REQUIREMENTS_FILE="requirements.txt"
        else
            error "No requirements.txt found and no Poetry project detected"
            exit 1
        fi
    fi
fi

# Verify requirements file exists
if [[ ! -f "${REQUIREMENTS_FILE}" ]]; then
    error "Requirements file not found: ${REQUIREMENTS_FILE}"
    exit 1
fi

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    error "Docker is required but not found in PATH"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Define output zip file name
ZIP_FILE="${OUTPUT_DIR}/base_python${PYTHON_VERSION}.zip"

# Create temporary directory for build
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${TEMP_DIR}"' EXIT

log "Building Lambda layer for Python ${PYTHON_VERSION}"
log "Using requirements from: ${REQUIREMENTS_FILE}"
log "Output will be saved to: ${ZIP_FILE}"

# Copy requirements to temp directory
cp "${REQUIREMENTS_FILE}" "${TEMP_DIR}/requirements.txt"

# Build the layer using AWS SAM CLI build image
log "Running Docker build..."
docker run --rm \
    --network host \
    -v "${TEMP_DIR}":/var/task \
    -w /var/task \
    -u "$(id -u):$(id -g)" \
    "public.ecr.aws/sam/build-python${PYTHON_VERSION}:latest" \
    bash -c "
        set -e
        echo 'Installing dependencies...'
        pip install -r requirements.txt -t python/lib/python${PYTHON_VERSION}/site-packages/ --no-cache-dir
        echo 'Creating zip file...'
        zip -r layer.zip python/
    "

# Move the zip file to the output location
if [[ -f "${ZIP_FILE}" ]]; then
    warning "Existing layer file will be overwritten: ${ZIP_FILE}"
fi

mv "${TEMP_DIR}/layer.zip" "${ZIP_FILE}"

# Display final size
ZIP_SIZE=$(du -h "${ZIP_FILE}" | cut -f1)
log "Layer created successfully: ${ZIP_FILE} (${ZIP_SIZE})"

# Check if size exceeds Lambda limits
ZIP_SIZE_BYTES=$(stat -f%z "${ZIP_FILE}" 2>/dev/null || stat -c%s "${ZIP_FILE}" 2>/dev/null)
if [[ ${ZIP_SIZE_BYTES} -gt 262144000 ]]; then  # 250MB in bytes
    warning "Layer size exceeds Lambda's 250MB unzipped limit!"
    warning "Consider using container images or splitting dependencies"
fi

# Clean up temporary requirements.txt if we created it from Poetry
if [[ -f "function/pyproject.toml" ]] && [[ "${REQUIREMENTS_FILE}" == "function/requirements.txt" ]]; then
    rm -f "${REQUIREMENTS_FILE}"
    log "Cleaned up temporary requirements.txt"
elif [[ -f "pyproject.toml" ]] && [[ "${REQUIREMENTS_FILE}" == "requirements.txt" ]]; then
    rm -f "${REQUIREMENTS_FILE}"
    log "Cleaned up temporary requirements.txt"
fi

log "Build complete!"