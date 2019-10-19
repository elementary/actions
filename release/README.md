# Release Action

This action automates the manual steps needed to generate changelogs and push release tags.
For more information on the overall flow of this ci image, take a look at the [elementary release process documentation](https://github.com/elementary/os/wiki/Release-Process).

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project. Docs: [debian control](https://elementary.io/docs/code/getting-started#debian-control)
  2. The project needs release information in an `appdata.xml` file. Docs: [appdata](https://elementary.io/docs/code/getting-started#appdata)

### Environment Variables

In order to create tags and push changes to various branches, the script needs a github token. Keep in mind, when using github workflows, the virtual environment [automatically comes with a generated github token secret](https://help.github.com/en/articles/virtual-environments-for-github-actions#github_token-secret).

### Specifying a release branch name

By default, this action will create and update a branch named 'stable' whenever a release is pushed. The branch name can be set via the `release_branch` input. Example:

```yaml
with:
  release_branch: 'juno'
```

## Examples

### Simple Example

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: elementary/actions/release@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Full Example

```yaml
jobs:
  release:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - uses: elementary/actions/release@master
      with:
        release_branch: 'juno'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
