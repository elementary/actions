# Gettext updates

This action automates the manual steps needed to regenerate the gettext templates if required

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project. Docs: [debian control](https://elementary.io/docs/code/getting-started#debian-control)
  2. The project needs to use the meson build system

### Environment Variables

In order to create tags and push changes to various branches, the script needs push access. The easiest way to set this
up is with the [`actions/checkout`](https://github.com/actions/checkout) action. If your translation branch is not
protected, that's all you need to do. However, if it is protected, you will need to generate a Personal Access Token
with the `repo` scope from someone with admin permissions for the repo. Then just specify the `token` param in
`actions/checkout`, and you should be all good.

1. [Generate a Personal Access Token](https://github.com/settings/tokens/new) from your GitHub user settings
2. Give it the `repo` scope
3. Copy the generated Personal Access Token
4. In the repo's settings, navigate to the "Secrets" tab and "Add a new secret"
5. Name the new secret `GIT_USER_TOKEN` and paste the copied Personal Access Token

#### Git User

By default, this action will use a github specific action bot git user. If you would like to specify a different user,
you can specify these properties:

```yaml
with:
  git_name: "example-user"
  git_email: "exampleuser@example.com"
```

### Specifying a translation branch name

By default, this action will use a branch named 'master' to to push the changes. The branch name can be set via the
`translation_branch` input. Example:

```yaml
with:
  translation_branch: 'i18n'
```

### Include the translation template

By default, this action will only rebuild the translation template. It is also possible to include the language by
setting the `regenerate_po` input to true. Example:

```yaml
with:
  regenerate_po: 'true'
```

## Examples

### Simple Example

```yaml
---

name: Merge

on:
  push:
    branches: master

jobs:
  Gettext:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Gettext
        uses: elementary/actions/gettext-template@master
```

### Full Example

```yaml
---
name: Merge

on:
  push:
    branches: master

jobs:
  Gettext:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          token: ${{ secrets.GIT_USER_TOKEN }}

      - name: Gettext
        uses: elementary/actions/gettext-template@master
        with:
          git_name: Bot Account
          git_email: bot@example.com
          translation_branch: 'i18n'
          regenerate_po: 'true'
```
