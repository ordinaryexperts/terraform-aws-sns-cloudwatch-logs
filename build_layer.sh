#!/usr/bin/env bash

set -euo pipefail

# AWS Lambda Layer Builder for Python
# Uses official AWS SAM CLI build images

# Configuration
PYTHON_VERSION="3.12"
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
        # Check if uv/pyproject.toml is being used
        if [[ -f "function/pyproject.toml" ]]; then
            log "Found pyproject.toml, exporting requirements with uv..."
            (cd function && uv pip compile pyproject.toml -o requirements.txt)
            REQUIREMENTS_FILE="function/requirements.txt"
        elif [[ -f "pyproject.toml" ]]; then
            log "Found pyproject.toml, exporting requirements with uv..."
            uv pip compile pyproject.toml -o requirements.txt
            REQUIREMENTS_FILE="requirements.txt"
        else
            error "No requirements.txt found and no pyproject.toml detected"
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

# Define the Docker image for building
BUILD_IMAGE="public.ecr.aws/sam/build-python${PYTHON_VERSION}:latest"

# Verify Docker image is available
log "Checking Docker image availability..."
if ! docker image inspect "${BUILD_IMAGE}" &>/dev/null; then
    log "Docker image not found locally, will be pulled automatically"
fi

# Build the layer using AWS SAM CLI build image
log "Running Docker build..."
docker run --rm \
    --network host \
    -v "${TEMP_DIR}":/var/task \
    -w /var/task \
    -u "$(id -u):$(id -g)" \
    "${BUILD_IMAGE}" \
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

# Lambda layer size limit (250MB unzipped)
LAMBDA_LAYER_SIZE_LIMIT=262144000  # 250MB in bytes

# Check if size exceeds Lambda limits
# Use portable method to get file size
ZIP_SIZE_BYTES=$(wc -c < "${ZIP_FILE}" | tr -d ' ')
if [[ ${ZIP_SIZE_BYTES} -gt ${LAMBDA_LAYER_SIZE_LIMIT} ]]; then
    warning "Layer size exceeds Lambda's 250MB unzipped limit!"
    warning "Consider using container images or splitting dependencies"
fi

# Clean up temporary requirements.txt if we created it from pyproject.toml
cleanup_temp_requirements() {
    local pyproject_file="$1"
    local req_file="$2"
    
    if [[ -f "${pyproject_file}" ]] && [[ "${REQUIREMENTS_FILE}" == "${req_file}" ]]; then
        rm -f "${REQUIREMENTS_FILE}"
        log "Cleaned up temporary requirements.txt"
    fi
}

cleanup_temp_requirements "function/pyproject.toml" "function/requirements.txt"
cleanup_temp_requirements "pyproject.toml" "requirements.txt"

log "Build complete!"