#!/bin/bash
# Set default settings, pull repository, build
# app, etc., _if_ we are not given a different
# command.  If so, execute that command instead.
set -e

# Default values
YOURS_HOME="/home/meteor"
APP_DIR="${YOURS_HOME}/www" # Location of built Meteor app
SRC_DIR="${YOURS_HOME}/new-src" # Location of Meteor app source
INITIAL_SRC_DIR="${YOURS_HOME}/src" # Location of Meteor app source

# Make sure critical directories exist
mkdir -p $APP_DIR
mkdir -p $SRC_DIR
mkdir -p $INITIAL_SRC_DIR

# Fix npm so it will correctly install without EXDEV errors
# see https://github.com/npm/npm/issues/9863,
# https://github.com/npm/npm/issues/9863#issuecomment-152342020, and
# https://github.com/abernix/meteord/blob/1d9047539e1bd487d0eff2aa5c994b5472e5b9aa/base/scripts/lib/build_app.sh#L4
# for more info
echo "copying app to avoid trixsy EXDEV issues"
cp -R $INITIAL_SRC_DIR $SRC_DIR


# See if we have a valid meteor source
METEOR_DIR=$(find ${SRC_DIR} -type d -name .meteor -print |head -n1)

if [ -e "${METEOR_DIR}" ]; then
   echo "Meteor source found in ${METEOR_DIR}"
   cd ${METEOR_DIR}/..

   # Check Meteor version
   echo "Checking Meteor version..."
   RELEASE=$(cat .meteor/release | cut -f2 -d'@')

   # Download Meteor installer
   echo "Downloading Meteor install script..."
   curl ${CURL_OPTS} -o /tmp/meteor.sh https://install.meteor.com/

   # Install Meteor tool
   echo "Installing Meteor ${RELEASE}..."
   sed -i "s/^RELEASE=.*/RELEASE=${RELEASE}/" /tmp/meteor.sh
   sh /tmp/meteor.sh
   rm /tmp/meteor.sh

   if [ -f package.json ]; then
      echo "Installing application-side NPM dependencies..."
      npm install --production
   fi

   # Bundle the Meteor app
   echo "Building the bundle...(this may take a while)"
   mkdir -p ${APP_DIR}
   meteor build --directory ${APP_DIR}
else
	echo "could not find $METEOR_DIR"
	exit 1
fi

# Locate the actual bundle directory
# subdirectory (default)
if [ ! -e ${BUNDLE_DIR:=$(find ${APP_DIR} -type d -name bundle -print |head -n1)} ]; then
   # No bundle inside app_dir; let's hope app_dir _is_ bundle_dir...
   BUNDLE_DIR=${APP_DIR}
fi

# Install NPM modules
if [ -e ${BUNDLE_DIR}/programs/server ]; then
   pushd ${BUNDLE_DIR}/programs/server/

   echo "Installing NPM prerequisites..."
   # Install all NPM packages
   npm install
   popd
else
   echo "Unable to locate server directory in ${BUNDLE_DIR}; hold on: we're likely to fail"
fi

if [ ! -e ${BUNDLE_DIR}/main.js ]; then
   echo "Failed to locate main.js in ${BUNDLE_DIR}; cannot start application."
   exit 1
fi

echo "uninstalling meteor"
rm -rf /usr/local/bin/meteor
rm -rf ~/.meteor
