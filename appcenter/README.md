# AppCenter CI

This action builds an app from CI and runs tests required for publishing in AppCenter

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to have a deb-packaging branch with the necessary debian packaging for the project. Docs: [debian control](https://elementary.io/docs/code/getting-started#debian-control)
  2. The project needs to use the meson build system

## Examples

```yaml
name: AppCenter CI
on: [push, pull_request]

jobs:
  appcenter_ci:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v1
    - uses: elementary/actions/appcenter@master
```
