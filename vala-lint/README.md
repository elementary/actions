# Vala Lint

This action uses [vala-lint](https://github.com/vala-lang/vala-lint) to lint your vala code.

## Inputs

### `dir`

The directory of code to lint. Default `.`.

### `conf`

The vala-lint configuration file.

### `fail`

Whether to fail the build on errors. Default `true`.

## Simple Example

```yaml
jobs:
  lint:

    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    - uses: elementary/actions/vala-lint@main
```

## Full Example

```yaml
jobs:
  lint:

    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    - uses: elementary/actions/vala-lint@main
      with:
        dir: src/
        conf: .vala-lint.conf
        fail: false
```
