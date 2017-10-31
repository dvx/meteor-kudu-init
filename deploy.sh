#!/bin/bash

BUILDS_DIR="${HOME}/drop/builds"
TIME=`date '+%Y_%m_%d__%H_%M_%S'`;

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
# Setup
# -------------------------------
cd "${DEPLOYMENT_TEMP}" || error_exit "Could not find working directory"

print "Unpacking bundle"
# Unpack bundle
if [ -d "bundle" ]; then
  print "Clearing old bundle"
  rm -rf "bundle" || error_exit "Could not clear old bundle"
fi
mkdir "bundle"
tar -xzf "${BUILDS_DIR}/bundle.tar.gz" -C "bundle" --warning="no-unknown-keyword" || error_exit "Could not unpack bundle"

# -------------------------------
# Deploy
# -------------------------------

print "Moving bundle"

cd "${DEPLOYMENT_TARGET}" || error_exit "Could not find target directory"

# Empty wwwroot
rm -rf *
rm -rf .[a-z]*

# Move bundle and package.json into wwwroot
mv "${DEPLOYMENT_TEMP}/bundle" .
cp "${DEPLOYMENT_SOURCE}/package.json" .

# Know when we deployed last
touch "deployed.$TIME"

print "Finished successfully"
