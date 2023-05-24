# tool4d action

This action install the wanted [tool4d](https://blog.4d.com/a-tool-for-4d-code-execution-in-cli/) to launch your 4D code.

## Inputs

### `project`

**Optional** The project file to run.

- If equal to `*` action will try to find it automatically
- If empty, nothing is run

### `startup-method`

**Optional** The method to run at startup.

- If not defined, standard database method will run

## Outputs

### `tool4d`

tool4d binary path.

## Example usage

Launch a specific method on macOS and windows:

```yaml

name: Unit Tests
on:
  push:
    branches:
      - main
    paths-ignore:
      - 'README.md'
  pull_request:
    branches:
      - main
    paths-ignore:
      - 'README.md'

jobs:
  build:
    name: "Run on ${{ matrix.os }}"
    strategy:
      fail-fast: false
      matrix:
        os: [ macos-latest, windows-latest ]
    runs-on: ${{ matrix.os }}
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - uses: e-marchand/tool4d-action@v1
      id: tool4d
      with:
        project: ${{ github.workspace }}/myProject/Build4D_DF.4DProject
        startup-method: runUnitTests
```
