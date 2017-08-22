#!/bin/bash

# Install swift for linux
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    DIR="$(pwd)"
    cd ..
    export SWIFT_VERSION=swift-4.0-DEVELOPMENT-SNAPSHOT-2017-08-21-a
    wget https://swift.org/builds/swift-4.0-branch/ubuntu1604/${SWIFT_VERSION}/${SWIFT_VERSION}-ubuntu16.04.tar.gz
    tar -xzf $SWIFT_VERSION-ubuntu14.04.tar.gz
    export PATH="${PWD}/${SWIFT_VERSION}-ubuntu14.04/usr/bin:${PATH}"
    cd "$DIR"
fi