# Appstream Validator Action

This action runs appstream-util to validate/verify the contents of a project's appdata file.

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs an `appdata.xml` file in the `data` directory of the project. Docs: [appdata](https://elementary.io/docs/code/getting-started#appdata)

## Example

```yaml
jobs:
  validate-appstream-data:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/appstream-validator@master
```