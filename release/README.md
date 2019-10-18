# Release Action

This action automates the manual steps needed to generate changelogs and push release tags.
For more information on the overall flow of this ci image, take a look at the [elementary release process documentation](https://github.com/elementary/os/wiki/Release-Process).

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project. Docs: [debian control](https://elementary.io/docs/code/getting-started#debian-control)
  2. The project needs release information in an `appdata.xml` file. Docs: [appdata](https://elementary.io/docs/code/getting-started#appdata)

### Environment Variables

In order to create tags and push changes to various branches, the script needs a few environment variables set:

| Environment Variable | Example Value                  |
| :------------------- | :------------------------------|
| GITHUB_TOKEN         | `abcd1234thisisanexampletoken` |
| GIT_USER             | `exampleuser`                  |
| GIT_EMAIL            | `example@somewhere.io`         |
| GIT_KEY              | Contents of an id_rsa key.     |

Keep in mind, when using github workflows, the virtual environment [automatically comes with a generated github token secret](https://help.github.com/en/articles/virtual-environments-for-github-actions#github_token-secret).

### Dry Run

To test out the workflow and view information on what a project's changelog diffs would look like, you can use the dry-run option. For example:

## Dry Run Example

```yaml
jobs:
  lint:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/vala-lint@master
      with:
        dryrun: '--dry-run'
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GIT_USER: "${{ secrets.GIT_USER }}"
        GIT_EMAIL: "${{ secrets.GIT_EMAIL }}"
        GIT_KEY: "${{ secrets.GIT_KEY }}"
```

## Full Example

```yaml
jobs:
  lint:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/vala-lint@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        GIT_USER: "${{ secrets.GIT_USER }}"
        GIT_EMAIL: "${{ secrets.GIT_EMAIL }}"
        GIT_KEY: "${{ secrets.GIT_KEY }}"
```
