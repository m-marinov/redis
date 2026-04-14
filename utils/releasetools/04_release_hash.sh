#!/bin/bash

# Parse optional flags
AUTO_CONFIRM=0
VERSION_TAG=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=1
            shift
            ;;
        *)
            VERSION_TAG="$1"
            shift
            ;;
    esac
done

if [ -z "$VERSION_TAG" ]
then
    echo "Usage: ./utils/releasetools/04_release_hash.sh [-y|--yes] <version_tag>"
    exit 1
fi

SHA=$(curl -s http://download.redis.io/releases/redis-${VERSION_TAG}.tar.gz | shasum -a 256 | cut -f 1 -d' ')
ENTRY="hash redis-${VERSION_TAG}.tar.gz sha256 $SHA http://download.redis.io/releases/redis-${VERSION_TAG}.tar.gz"
echo $ENTRY >> ../redis-hashes/README

if [ $AUTO_CONFIRM -eq 0 ]; then
    echo "Press any key to commit, Ctrl-C to abort)."
    read yes
fi

(cd ../redis-hashes; git commit -a -m "${VERSION_TAG} hash."; git push)
