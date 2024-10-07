# Release Action

This action automates the manual steps needed to generate changelogs and push release tags.
For more information on the overall flow of this ci image, take a look at the [elementary release process documentation](https://github.com/elementary/os/wiki/Release-Process).

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project.
  2. The project needs release information in an `appdata.xml` file. Docs: [appdata](https://elementary.io/docs/code/getting-started#appdata)

### Environment Variables

In order to create tags and push changes to various branches, the script needs a github token. Keep in mind, when using github workflows, the virtual environment [automatically comes with a generated github token secret](https://help.github.com/en/articles/virtual-environments-for-github-actions#github_token-secret).

To change the debian release channel in the project's debian changelog config, you can set the `RELEASE_CHANNEL` environment variable:

```yaml
env:
  RELEASE_CHANNEL: focal
```

### Specifying a release branch name

By default, this action will create and update a branch named 'stable' whenever a release is pushed. The branch name can be set via the `release_branch` input. Example:

```yaml
with:
  release_branch: 'juno'
```

### Specifying a label

By default, the examples check for a label called `Release` on the related pull request. This can be set in the workflow action by changing the following:

```yaml
# check for "Release" label:
true == contains(join(github.event.pull_request.labels.*.name), 'Release')
# check for "Example" label:
true == contains(join(github.event.pull_request.labels.*.name), 'Example')
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
name: Release
on:
  pull_request:
    branches: [ $default-branch ]
    types: closed
jobs:
  release:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true && true == contains(join(github.event.pull_request.labels.*.name), 'Release')
    steps:
    - uses: actions/checkout@v4
    - uses: elementary/actions/release@main
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Full Example

```yaml
name: Release
on:
  pull_request:
    branches: [ $default-branch ]
    types: closed
jobs:
  release:
    runs-on: ubuntu-latest
    if: github.event.pull_request.merged == true && true == contains(join(github.event.pull_request.labels.*.name), 'Release')
    steps:
    - uses: actions/checkout@v4
    - uses: elementary/actions/release@main
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      with:
        release_branch: 'juno'
```
