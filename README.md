# Python Image Builder - Github Action

This Github Action is part of the [Multi-Py Project](https://github.com/multi-py). It works alongside the [Multi-Py Python Versionator Action](https://github.com/multi-py/action-python-versionator) to continuously release multiarchitecture containers.

The Image Builder is focused on building a single multiarchitecture image around a python package. It uses a two stage approach where the python packages are compiled in a base image and then moved to the final image. This allows for consistent builds and smaller output images.

Using this action, the Github Action Matrix Strategy, and the Versionator allows for building a complex set of images with the most recent versions of the tracked packages.

## Example

```yaml

name: Example Image Builder

# Publish on new pushed, and build on Monday Morning (UTC) regardless.
on:
  push:
    branches:
      - 'main'
  schedule:
    - cron:  '4 0 * * MON'

jobs:
  Uvicorn-Builder:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python_version: ["3.6", "3.7", "3.8", "3.9", "3.10"]
        package_versions: ["0.12.1", "0.12.2", "0.12.3", "0.13.0", "0.13.1", "0.13.2", "0.13.3", "0.13.4", "0.14.0", "0.15.0"]
        target_base: ["full", "slim", "alpine"]
    steps:

      - name: Checkout repository
        uses: actions/checkout@v2

      - name: "Create and push"
        uses: multi-py/action-python-image-builder@main
        with:
          package: "uvicorn"
          package_latest_version: "0.15.0"
          maintainer: "Myname <user@example.com>"
          python_version: ${{ matrix.python_version }}
          target_base: ${{ matrix.target_base }}
          package_version: ${{ matrix.package_versions }}
          registry_password: ${{ secrets.GITHUB_TOKEN }}
```

The `python_version`, `package_versions`, and `package_latest_version` values get updated by a separate Versionator action.

This particular config supports five python versions, three variant images, ten package versions, and three architectures. This results in 150 high level images each consisting of three architectures, for a total of 450 builds across 150 workflows on each run.

## Docker Files and Context

By default this action uses its own dockerfile and repository as context. This can be overridden with the `dockerfile` and `docker_build_path` parameters. To get the most out of this action start with the dockerfile here and expand it so that build arguments will still work.
