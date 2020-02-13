#!/bin/bash
set -e

#--------------------------------#
# Install the build dependencies #
#--------------------------------#

# make sure we are in sync with HEAD
git reset --hard HEAD

# merge the debian packaging branch
if ! git merge origin/deb-packaging --allow-unrelated-histories --no-commit; then
  echo "\033[0;31mERROR: Unable to merge the 'deb-packaging' branch. Does it exist?\033[0m" && exit 1
fi

# Create a fake package depending on the build dependency and install/remove it
sudo apt -y update
mk-build-deps --build-dep --install --remove --tool 'apt -y' --root-cmd sudo debian/control

echo -e "\n\033[1;32mInstalled all the build dependencies!\033[0m\n"

# Build from packaging
debuild -i -us -uc -b
