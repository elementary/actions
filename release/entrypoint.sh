#!/bin/bash
set -e

# if a custom token is provided, use it instead of the default github token.
if [ -n "$GIT_USER_TOKEN" ]; then
  GITHUB_TOKEN="$GIT_USER_TOKEN"
fi

if [ -z "${GITHUB_TOKEN}" ]; then
  echo "\033[0;31mERROR: The GITHUB_TOKEN environment variable is not defined.\033[0m"  && exit 1
fi

if [ -z "$1" ]; then
  RELEASE_BRANCH="stable"
else
  RELEASE_BRANCH="$1"
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

#---------------#
# Parse Appdata #
#---------------#

# get appdata filename:
APPDATA="$(basename "$(find data -name "*appdata*")")"

# get the version and release notes from the latest release entry in the appdata
VERSION="$(xmlstarlet sel -t -v '//release[1]//@version' -n data/"$APPDATA")"
echo "Version: $VERSION"

# get the last version tag before we create a new one!
PREVIOUS_VERSION="$(git tag -l | grep -v 'debian' | tail -n1 )"

# get the release notes, remove any empty lines & padded spacing
RELEASE_NOTE_RAW="$(xmlstarlet sel -t -m '//release[1]/description/*' -n -c '.' -n data/"$APPDATA" | awk 'NF' | awk '{$1=$1}1')"
# replace quotes with commented quotes to prevent breakage in github release note string
RELEASE_NOTES_SANITIZED="${RELEASE_NOTE_RAW//\"/\\\"}"
echo "Release Note Content:"
echo -e "$RELEASE_NOTES_SANITIZED\n"

#-----------------------#
# Create Github Release #
#-----------------------#

# replace newlines with a newline character
MARKDOWN_NOTES="$(echo "$RELEASE_NOTES_SANITIZED" | awk '{printf "%s\\n", $0}')"
# add the project name and version to release note
GITHUB_RELEASE_NOTE="$PROJECT $VERSION is out! \n\n$MARKDOWN_NOTES"
DATA="
{
  \"tag_name\": \"$VERSION\",
  \"target_commitish\": \"$GITHUB_SHA\",
  \"name\": \"$PROJECT $VERSION Released\",
  \"body\": \"$GITHUB_RELEASE_NOTE\",
  \"draft\": false,
  \"prerelease\": false
}
"

# push the release content to github!
if ! curl --data "$DATA" https://api.github.com/repos/"$GITHUB_REPOSITORY"/releases?access_token="$GITHUB_TOKEN"; then
  echo "\033[0;31mERROR: Unable to post github release tag information!\033[0m"  && exit 1
fi
echo -e "\n\033[1;32mA new github release tag has been created!\033[0m\n"

#-------------------------#
# Update Debian Changelog #
#-------------------------#

# make sure we are in sync with HEAD
git reset --hard HEAD

# get all commit subjects since previous version tag
COMMITS="$(git log "$PREVIOUS_VERSION"..HEAD --pretty="format:%s")"
# filter out commits involving translations and commits that don't have a related merge number
FILTERED_COMMITS="$(echo "$COMMITS" | grep -v 'Weblate' | grep -v 'weblate')"

echo "Debian Changelog Content:"
echo -e "$FILTERED_COMMITS\n"

# move to the debian packaging branch
if ! git checkout deb-packaging; then
  echo "\033[0;31mERROR: Unable to checkout the 'deb-packaging' branch. Does it exist?\033[0m" && exit 1
fi

if [ -z "$FILTERED_COMMITS" ]; then
  echo "no changes since last tag, an empty debian changelog will be created."
  dch -Mv "$VERSION" "no changes since last release."
else
  # Get the first changelog entry
  FIRST_CHANGE="$(echo "$FILTERED_COMMITS" | head -n 1)"
  # Create a versioned release and add the first line of the changelog
  dch -Mv "$VERSION" "$FIRST_CHANGE"
  # iterate over any other changelog entries, if there are any
  REMAINING_CHANGES="$(echo "$FILTERED_COMMITS"| tail -n +2)"
  if [ -n "$REMAINING_CHANGES" ]; then
    while read -r line; do
      # Append another list item to the changelog
      dch -Ma "$line"
    done <<< "$REMAINING_CHANGES"
  fi
fi

# Set the release channel/distro
dch -Mr bionic

# Commit, Tag, and Push
TAG="$VERSION-debian"
if ! (git commit -am "Release $VERSION" && git tag -a "$TAG" -m "$TAG"); then
  echo "\033[0;31mERROR: Unable to commit and tag changelog information!\033[0m" && exit 1
fi
if ! (git push && git push origin "$TAG"); then
  echo "\033[0;31mERROR: Unable to push changelog information!\033[0m" && exit 1
fi
echo -e "\n\033[1;32mChangelogs have been pushed to deb-packaging!\033[0m\n"

#------------------#
# Deploy to stable #
#------------------#

# point head back to what it was before checking out deb-packaging
git checkout -
git reset --hard HEAD

# checkout or create stable branch
if ! git show-ref --verify --quiet refs/heads/"$RELEASE_BRANCH"; then
  git checkout -b "$RELEASE_BRANCH"
else
  git checkout "$RELEASE_BRANCH"
fi

# rebase off of master & push to remote
if ! git rebase origin/master; then
  echo "\033[0;31mERROR: Unable to merge master into $RELEASE_BRANCH!\033[0m" && exit 1
fi
if ! git push origin "$RELEASE_BRANCH" --force-with-lease; then
  echo "\033[0;31mERROR: Unable to push changes to the $RELEASE_BRANCH branch!\033[0m" && exit 1
fi
echo -e "\n\033[1;32mSuccessfully updated $RELEASE_BRANCH branch!\033[0m\n"
