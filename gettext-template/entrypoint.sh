#!/bin/bash
set -e

export DEBIAN_FRONTEND="noninteractive"

# if a custom token is provided, use it instead of the default github token.
if [ -n "$GIT_USER_TOKEN" ]; then
  GITHUB_TOKEN="$GIT_USER_TOKEN"
fi

if [ -z "${GITHUB_TOKEN}" ]; then
  echo "\033[0;31mERROR: The GITHUB_TOKEN environment variable is not defined.\033[0m"  && exit 1
fi

if [ -z "$1" ]; then
  TRANSLATION_BRANCH="master"
else
  TRANSLATION_BRANCH="$1"
fi

# default email and username to github actions user
if [ -z "$GIT_USER_EMAIL" ]; then
  GIT_USER_EMAIL="action@github.com"
fi
if [ -z "$GIT_USER_NAME" ]; then
  GIT_USER_NAME="GitHub Action"
fi

# make sure branches are up-to-date
git fetch
echo "Setting up git credentials..."
git remote set-url origin https://x-access-token:"$GITHUB_TOKEN"@github.com/"$GITHUB_REPOSITORY".git
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
echo "Git credentials configured."

# get the project's name:
PROJECT="$(basename "$GITHUB_REPOSITORY")"
echo "Project: $PROJECT"

#--------------------------------#
# Install the build dependencies #
#--------------------------------#

# make sure we are in sync with HEAD
git reset --hard HEAD

# move to the debian packaging branch
if ! git checkout deb-packaging; then
  echo "\033[0;31mERROR: Unable to checkout the 'deb-packaging' branch. Does it exist?\033[0m" && exit 1
fi

# Create a fake package depending on the build dependency and install/remove it
sudo apt-get -qq update
mk-build-deps --build-dep --install --remove --tool 'apt-get -qq' --root-cmd sudo debian/control

echo -e "\n\033[1;32mInstalled all the build dependencies!\033[0m\n"

#---------------------------------#
# Update the translation template #
#---------------------------------#

# point head back to what it was before checking out deb-packaging
git checkout -
git reset --hard HEAD

if ! git checkout $TRANSLATION_BRANCH; then
  echo "\033[0;31mERROR: Unable to checkout the '$TRANSLATION_BRANCH' branch. Does it exist?\033[0m" && exit 1
fi

# update the translation template and push changes if required
meson build
ninja -C build
if [ "$INPUT_REGENERATE_PO" = true ]; then
GETTEXT_TARGETS=$(git ls-files | grep \.pot$ | sed 's/.*\///' | sed 's/.pot/-update-po/')
else
GETTEXT_TARGETS=$(git ls-files | grep \.pot$ | sed 's/.*\///' | sed 's/.pot/-pot/')
fi
ninja -C build $GETTEXT_TARGETS
echo -e "\n\033[1;32mSuccessfully build the project!\033[0m\n"
python3 /check-diff.py

