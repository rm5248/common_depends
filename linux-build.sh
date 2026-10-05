#!/bin/bash
#
# Build the vcpkg dependencies inside a pbuilder chroot.  Run as root by
# 'pbuilder execute' (see the Jenkinsfile) with the workspace and the vcpkg
# binary cache bind-mounted at the same paths as on the host.
#
# Usage: linux-build.sh <workspace> <binary cache dir> <triplet> <export dir> <uid> <gid>

set -e

WORKSPACE="$1"
BINARY_CACHE="$2"
TRIPLET="$3"
EXPORT_DIR="$4"
BUILD_UID="$5"
BUILD_GID="$6"

bash "$WORKSPACE/linux-depends.sh"

# Do the actual build as the Jenkins user so that everything written to the
# workspace is owned by it, not root.
mkdir -p /tmp/builder
chown "$BUILD_UID:$BUILD_GID" /tmp/builder

cd "$WORKSPACE"
setpriv --reuid="$BUILD_UID" --regid="$BUILD_GID" --clear-groups \
    env HOME=/tmp/builder \
        VCPKG_DISABLE_METRICS=1 \
        VCPKG_DEFAULT_BINARY_CACHE="$BINARY_CACHE" \
    bash -e -c '
        ./vcpkg/bootstrap-vcpkg.sh -disableMetrics
        ./vcpkg/vcpkg install --triplet "$0" --x-install-root=vcpkg_installed --keep-going
        mkdir -p "$1"
        ./vcpkg/vcpkg export --triplet "$0" --x-install-root=vcpkg_installed --zip --output-dir="$1"
    ' "$TRIPLET" "$EXPORT_DIR"
