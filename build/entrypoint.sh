#!/bin/bash
set -e

#----------------------#
# Install Dependencies #
#----------------------#

DEPENDENCIES="$*"
if [ -n "$DEPENDENCIES" ]; then
  apt-get install -y $DEPENDENCIES
fi
#---------------#
# Build Project #
#---------------#

meson build
ninja -C build
ninja -C build install

#------------------#
# Validate Appdata #
#------------------#

APPDATA="$(find build/data -name "*appdata*")"
appstream-util validate-relax --nonet "$APPDATA"
appstreamcli validate "$(find data -name "*appdata*")"
