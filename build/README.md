# Build Action

This action builds and installs a meson-based project, and verifies the appstream data after an install completes.

## Requirements

This image is intended for use with elementary debian projects. There are a few requirements before getting started:

  1. The project needs to support the meson build system.
  2. The project needs an `appdata.xml` file in the `data` directory of the project. Docs: [appdata](https://elementary.io/docs/code/getting-started#appdata)
  3. Dependencies need to be included in the "dependencies" input.

## Examples

### Simple Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: elementary/actions/build@master
```

### Full Example

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: elementary/actions/build@master
    with:
        dependencies: 'libchamplain-0.12-dev libchamplain-gtk-0.12-dev libclutter-1.0-dev libecal1.2-dev libedataserverui1.2-dev libfolks-dev libgee-0.8-dev libgeocode-glib-dev libgeoclue-2-dev libglib2.0-dev libgranite-dev libgtk-3-dev libical-dev'
