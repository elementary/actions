#!/bin/bash
set -e

export DEBIAN_FRONTEND="noninteractive"

if [ -z "$INPUT_REPOSITORY_NAME" ]; then
  INPUT_REPOSITORY_NAME="appcenter"
fi
if [ -z "$INPUT_REPOSITORY_URL" ]; then
  INPUT_REPOSITORY_URL="https://flatpak.elementary.io/repo.flatpakrepo"
fi

echo "Setting up git credentials..."
# default email and username to github actions user
if [ -z "$GIT_USER_EMAIL" ]; then
  GIT_USER_EMAIL="action@github.com"
fi
if [ -z "$GIT_USER_NAME" ]; then
  GIT_USER_NAME="GitHub Action"
fi

git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
echo "Git credentials configured."

flatpak remote-add --if-not-exists $INPUT_REPOSITORY_NAME $INPUT_REPOSITORY_URL -vv --ostree-verbose

# get the project's name:
PROJECT="$(basename "$GITHUB_REPOSITORY")"
echo "Project: $PROJECT"

TMPDIR=$(basename `mktemp -u`)
mkdir "$TMPDIR"

MANIFEST_PATH="$INPUT_MANIFEST_PATH".json
flatpak-builder --show-manifest "$INPUT_MANIFEST_PATH" | jq 'del(.modules[-1].sources) | .modules[-1].sources[0].path="." | .modules[-1].sources[0].type="dir"' > "$MANIFEST_PATH"
MODULE_NAME=$(jq -r .modules[-1].name $MANIFEST_PATH)

#-------------------#
# Build the project #
#-------------------#

flatpak-builder build "$MANIFEST_PATH" --repo=repo --disable-rofiles-fuse --force-clean --stop-at="$MODULE_NAME" --state-dir="$TMPDIR" --install-deps-from=$INPUT_REPOSITORY_NAME

#---------------------------------#
# Update the translation template #
#---------------------------------#

TRANSLATION_FILES=$(git ls-files | grep \.pot$)
GETTEXT_TARGETS=$(echo $TRANSLATION_FILES | sed 's/.*\///' | sed 's/.pot/-pot/')

echo "ninja $GETTEXT_TARGETS" | flatpak-builder build "$MANIFEST_PATH" --repo=repo --disable-rofiles-fuse --force-clean --build-shell="$MODULE_NAME" --state-dir="$TMPDIR"
for TRANSLATION_FILE in $TRANSLATION_FILES; do
    cp "$TMPDIR/build/$MODULE_NAME/$TRANSLATION_FILE" $TRANSLATION_FILE
done

# update the translation template and push changes if required
echo -e "\n\033[1;32mSuccessfully build the project!\033[0m\n"
python3 $GITHUB_ACTION_PATH/check-diff.py

