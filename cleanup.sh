#!/bin/bash

# Clean up dependencies and files we no longer nead
set -e

echo "cleaning up apt"
apt-get clean -y
apt-get purge build-essential -y
apt-get autoremove -y
rm -Rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "uninstalling meteor"
rm -rf /usr/local/bin/meteor
rm -rf ~/.meteor
