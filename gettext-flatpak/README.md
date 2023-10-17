# Gettext updates

This action automates the manual steps needed to regenerate the gettext templates if required

## Requirements

This image is intended for use with elementary flatpak projects. There are a few requirements before getting started:

  1. The project needs to have a flatpak manifest
  2. The project needs to use the meson build system

### Specifying the manifest

This action requires a manifest provided with the `manifest-path` input. Example:

```yaml
with:
  manifest-path: 'io.elementary.code.yml'
```

### Specifying a repository to use

By default, this action will use the elementary appcenter repository to get the dependencies. An alternative store can be set by specifying both `repository-url` and `repository-name` inputs. Example:

```yaml
with:
  repository-url: 'https://flatpak.elementary.io/repo.flatpakrepo'
  repository-name: 'appcenter'
```

## Examples

### Simple Example

```yaml
name: Gettext updates
on:
  push:
    branches: [ $default-branch ]
jobs:
  gettext_flatpak:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/elementary/flatpak-platform/runtime:7.2-x86_64
      options: --privileged
    steps:

    steps:
    - name: Install git, python3-git and jq
      run: |
        apt-get update
        apt-get install git jq python3-git -y
    - name: Clone repository
      uses: actions/checkout@v4
      with:
        token: ${{ secrets.GIT_USER_TOKEN }}
    - name: Configure Git
      run: |
        git config --global --add safe.directory "$GITHUB_WORKSPACE"
    - uses: elementary/actions/gettext-flatpak@master
      with:
        manifest-path: 'io.elementary.code.yml'
```

### Full Example

```yaml
name: Gettext updates
on:
  push:
    branches: [ $default-branch ]
jobs:
  gettext_flatpak:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/elementary/flatpak-platform/runtime:7.2-x86_64
      options: --privileged
    steps:
    - name: Install git, python3-git and jq
      run: |
        apt-get update
        apt-get install git jq python3-git -y
    - name: Clone repository
      uses: actions/checkout@v4
      with:
        token: ${{ secrets.GIT_USER_TOKEN }}
    - name: Configure Git
      run: |
        git config --global --add safe.directory "$GITHUB_WORKSPACE"
    - uses: elementary/actions/gettext-flatpak@master
      with:
        manifest-path: 'io.elementary.code.yml'
        repository-url: 'https://flatpak.elementary.io/repo.flatpakrepo'
        repository-name: 'appcenter'
```
