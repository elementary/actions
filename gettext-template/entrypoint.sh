#!/bin/bash
set -e

export DEBIAN_FRONTEND="noninteractive"

# get default branch, see: https://davidwalsh.name/get-default-branch-name
DEFAULT_BRANCH="$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)"

if [ -z "${INPUT_TRANSLATION_BRANCH}" ]; then
  TRANSLATION_BRANCH="${DEFAULT_BRANCH}"
else
  TRANSLATION_BRANCH="${INPUT_TRANSLATION_BRANCH}"
fi

# make sure branches are up-to-date
git fetch
echo "Setting up git credentials..."
git config --global user.email "$INPUT_GIT_EMAIL"
git config --global user.name "$INPUT_GIT_NAME"
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

sudo apt-get -qq update
sudo apt-get -qq dist-upgrade
sudo apt-get --no-install-recommends -qq build-dep .

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
