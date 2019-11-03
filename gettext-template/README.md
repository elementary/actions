# Gettext updates

This action automates the manual steps needed to regenerate the gettext templates if required

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project. Docs: [debian control](https://elementary.io/docs/code/getting-started#debian-control)
  2. The project needs to use the meson build system

### Environment Variables

In order to create tags and push changes to various branches, the script needs a github token. Keep in mind, when using github workflows, the virtual environment [automatically comes with a generated github token secret](https://help.github.com/en/articles/virtual-environments-for-github-actions#github_token-secret).

### Specifying a translation branch name

By default, this action will use a branch named 'master' to to push the changes. The branch name can be set via the `translation_branch` input. Example:

```yaml
with:
  translation_branch: 'i18n'
```

### Git User

Instead of using the default github token (`GITHUB_TOKEN`), you can use a custom git user token with the `GIT_USER_TOKEN` environment variable. You can also use the following environment variables to set the git user & email:

```yaml
env:
  GIT_USER_TOKEN: "${{ secrets.GIT_USER_TOKEN }}"
  GIT_USER_NAME: "example-user"
  GIT_USER_EMAIL: "exampleuser@example.com"
```

## Examples

### Simple Example

```yaml
name: Gettext updates
on:
  push:
    branches: master
jobs:
  gettext_template:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/gettext-template@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Full Example

```yaml
name: Gettext updates
on:
  push:
    branches: master
jobs:
  gettext_template:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/gettext-template@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        translation_branch: 'i18n'
```
