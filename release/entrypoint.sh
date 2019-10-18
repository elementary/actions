#!/bin/bash
set -e

if [ "$1" != "--dry-run" ]; then
  # make sure branches are up-to-date
  git fetch
  echo "Setting up git credentials..."
  git remote set-url origin https://x-access-token:"$GITHUB_TOKEN"@github.com/"$GITHUB_REPOSITORY".git
  git config --global user.email "action@github.com"
  git config --global user.name "GitHub Action"
  echo "Git credentials configured."
fi

# Check if this is a release branch that was merged in
if ! git log --oneline -1 | grep -F "[release]" >/dev/null; then
  # not a release, nothing to do here.
  echo "not a release."
  exit 0
fi

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

# get the release notes, remove any empty lines & padded spacing
RELEASE_NOTE_RAW="$(xmlstarlet sel -t -v '//release[1]' -n data/"$APPDATA"| awk 'NF'| awk '{$1=$1}1')"
echo "Release Note Content:"
echo -e "$RELEASE_NOTE_RAW\n"

#-----------------------#
# Create Github Release #
#-----------------------#

# add ul stars to the notes and replace any newlines with a newline character instead
MARKDOWN_NOTES="$(echo "$RELEASE_NOTE_RAW" | awk '$0="* "$0' | awk '{printf "%s\\n", $0}')"
# add the project name and version to release note
GITHUB_RELEASE_NOTE="$PROJECT $VERSION is out! \n\nChanges:\n\n$MARKDOWN_NOTES"
DATA="
{
  \"tag_name\": \"$VERSION\",
  \"target_commitish\": \"master\",
  \"name\": \"$PROJECT $VERSION Released\",
  \"body\": \"$GITHUB_RELEASE_NOTE\",
  \"draft\": false,
  \"prerelease\": false
}
"

if [ "$1" != "--dry-run" ]; then
  # push the release content to github!
  if ! curl --data "$DATA" https://api.github.com/repos/"$GITHUB_REPOSITORY"/releases?access_token="$GITHUB_TOKEN"; then
    echo "\033[0;31mERROR: Unable to post github release tag information!\033[0m"  && exit 1
  fi
  echo -e "\n\033[1;32mA new github release tag has been created!\033[0m\n"
else
  echo -e "curl contents:\ncurl --data $DATA https://api.github.com/repos/$GITHUB_REPOSITORY/releases?access_token=$GITHUB_TOKEN"
fi

#-------------------------#
# Update Debian Changelog #
#-------------------------#

# make sure we are up to date on the master branch
git checkout master
git reset --hard origin/master

# get all commit subjects since last tag
COMMITS="$(git log "$(git describe --tags "$(git rev-list --tags --max-count=1)")"..HEAD --pretty="format:%s")"
# filter out commits involving translations and commits that don't have a related merge number
FILTERED_COMMITS="$(echo "$COMMITS" | awk '!/Weblate/' | awk '!/weblate/' | grep '(#')"

# move to the debian packaging branch
if ! git checkout deb-packaging; then
  echo "\033[0;31mERROR: Unable to checkout the 'deb-packaging' branch. Does it exist?\033[0m" && exit 1
fi

if [ -z "$FILTERED_COMMITS" ]; then
  echo "no changes since last tag, an empty debian changelog will be created."
  dch -v "$VERSION" "no changes since last release."
else
  # Get the first changelog entry
  FIRST_CHANGE="$(echo "$FILTERED_COMMITS" | head -n 1)"
  # Create a versioned release and add the first line of the changelog
  dch -v "$VERSION" "$FIRST_CHANGE"
  # iterate over any other changelog entries, if there are any
  REMAINING_CHANGES="$(echo "$FILTERED_COMMITS"| tail -n +2)"
  if [ -n "$REMAINING_CHANGES" ]; then
    while read -r line; do
      # Append another list item to the changelog
      dch -a "$line"
    done <<< "$REMAINING_CHANGES"
  fi
fi

# Set the release channel/distro
dch -r bionic

# Commit, Tag, and Push
if [ "$1" == "--dry-run" ]; then
  echo "deb-packaging changelog diff:"
  git diff
else
  TAG="$VERSION-debian"
  if ! git commit -am "Release $VERSION" && git tag -a "$TAG" -m "$TAG"; then
    echo "\033[0;31mERROR: Unable to commit and tag changelog information!\033[0m" && exit 1
  fi
  if ! git push && git push origin "$TAG"; then
    echo "\033[0;31mERROR: Unable to push changelog information!\033[0m" && exit 1
  fi
  echo -e "\n\033[1;32mChangelogs have been pushed to deb-packaging!\033[0m\n"
fi

#------------------#
# Deploy to stable #
#------------------#

if [ "$1" != "--dry-run" ]; then
  # make sure we are up to date on the master branch before rebasing stable
  git checkout master
  git reset --hard origin/master

  # checkout or create stable branch
  if ! git show-ref --verify --quiet refs/heads/stable; then
    git checkout -b stable
  else
    git checkout stable
  fi

  # rebase off of master & push to remote
  if ! git rebase origin/master; then
    echo "\033[0;31mERROR: Unable to merge master into stable!\033[0m" && exit 1
  fi
  if ! git push origin stable --force-with-lease; then
    echo "\033[0;31mERROR: Unable to push changes to stable branch!\033[0m" && exit 1
  fi
  echo -e "\n\033[1;32mThe stable branch has been updated successfully!\033[0m\n"
fi
