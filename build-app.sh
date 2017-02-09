#!/bin/bash

# Fix npm so it will correctly install without EXDEV errors
# see https://github.com/npm/npm/issues/9863,
# https://github.com/npm/npm/issues/9863#issuecomment-152342020, and
# https://github.com/abernix/meteord/blob/1d9047539e1bd487d0eff2aa5c994b5472e5b9aa/base/scripts/lib/build_app.sh#L4
# for more info
echo "copying app to avoid trixsy EXDEV issues"
cp -R $INITIAL_SRC_DIR $SRC_DIR
rm -rf $INITIAL_SRC_DIR


# See if we have a valid meteor source
METEOR_DIR=$(find ${SRC_DIR} -type d -name .meteor -print |head -n1)

if [ -e "${METEOR_DIR}" ]; then
   echo "Meteor source found in ${METEOR_DIR}"
   cd ${METEOR_DIR}/..

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
