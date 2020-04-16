#!/bin/bash
set -e

#----------------------#
# Install Dependencies #
#----------------------#

apt-get install -y  "$DEPENDENCIES"

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
