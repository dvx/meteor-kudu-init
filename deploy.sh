#!/bin/bash

BUILDS_DIR="${HOME}/drop/builds"
TIME=`date '+%Y_%m_%d_%H_%M_%S.meteor_kudu_init'`;

# -------------------------------
# Functions
# -------------------------------

function print { echo "meteor-kudu-init: ${1}"; }

function error_exit {
  # Display error message and exit
  echo "meteor-kudu-init: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

# -------------------------------
# Cleanup
# -------------------------------
print "*** Phase: Cleanup ***"
cd "${DEPLOYMENT_TARGET}" || error_exit "Could not find target directory"
print "[ Working directory: ${DEPLOYMENT_TARGET} ]"
print "Cleaning ${DEPLOYMENT_TARGET}"

# Clean wwwroot
rm -rf *
rm -rf .[a-z]*

# Move package.json into wwwroot
cp "${DEPLOYMENT_SOURCE}/package.json" .

# -------------------------------
# Setup & Deployment
# -------------------------------
print "*** Phase: Setup & Deployment ***"
cd "${DEPLOYMENT_TEMP}" || error_exit "Could not find temp directory"
print "[ Working directory: ${DEPLOYMENT_TEMP} ]"
print "Unpacking bundle to ${DEPLOYMENT_TEMP}/bundle"

# Unpack bundle
if [ -d "bundle" ]; then
  print "Clearing old bundle"
  rm -rf "bundle" || error_exit "Could not clear old bundle"
fi
mkdir "bundle"
unzip -qq "${BUILDS_DIR}/bundle.zip" -d "bundle" || error_exit "Could not unpack bundle"

# We can't use mv because we're the deployment/repository user, so copy (and remove) instead
print "Moving bundle to ${DEPLOYMENT_TARGET}"
cp -r --no-preserve=mode,ownership "bundle" "${DEPLOYMENT_TARGET}" && rm -rf "bundle"

# -------------------------------
# Finalizing
# -------------------------------
print "*** Phase: Finalizing ***"
cd "${DEPLOYMENT_TARGET}" || error_exit "Could not find target directory"
print "[ Working directory: ${DEPLOYMENT_TARGET} ]"
# Know when we deployed last
touch "deployed.$TIME"

print "Finished successfully"
