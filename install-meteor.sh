#!/bin/bash
# Set default settings, pull repository, build
# app, etc., _if_ we are not given a different
# command.  If so, execute that command instead.
set -e

RELEASE=1.4.2.6
# Download Meteor installer
echo "Downloading Meteor install script..."
curl  -o /tmp/meteor.sh "https://install.meteor.com/?release=${RELEASE}"

# Install Meteor tool
echo "Installing Meteor ${RELEASE}..."
sh /tmp/meteor.sh
rm /tmp/meteor.sh
