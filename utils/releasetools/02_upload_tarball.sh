#!/bin/bash

RELEASE_TYPE=""
VERSION_TAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --stable)
            RELEASE_TYPE="stable"
            shift
            ;;
        --unstable)
            RELEASE_TYPE="unstable"
            shift
            ;;
        *)
            VERSION_TAG="$1"
            shift
            ;;
    esac
done

if [ -z "$VERSION_TAG" ]; then
    echo "Usage: ./utils/releasetools/02_upload_tarball.sh [--stable|--unstable] <version_tag>"
    exit 1
fi

echo "Uploading..."
scp /tmp/redis-${VERSION_TAG}.tar.gz ubuntu@host.redis.io:/var/www/download/releases/

if [ "$RELEASE_TYPE" = "unstable" ]; then
    echo "Unstable release - skipping stable symlink update"
    exit 0
fi

if [ -z "$RELEASE_TYPE" ]; then
    echo "Updating web site... "
    echo "Please check the github action tests for the release."
    echo "Press any key if it is a stable release, or Ctrl+C to abort"
    read x
fi

echo "Updating stable symlink..."
ssh ubuntu@host.redis.io "cd /var/www/download;
                          rm -rf redis-${VERSION_TAG}.tar.gz;
                          wget http://download.redis.io/releases/redis-${VERSION_TAG}.tar.gz;
                          tar xvzf redis-${VERSION_TAG}.tar.gz;
                          rm -rf redis-stable;
                          mv redis-${VERSION_TAG} redis-stable;
                          tar cvzf redis-stable.tar.gz redis-stable;
                          rm -rf redis-${VERSION_TAG}.tar.gz;
                          shasum -a 256 redis-stable.tar.gz > redis-stable.tar.gz.SHA256SUM;
                          "
