# tool4d action

This action install the wanted [tool4d](https://blog.4d.com/a-tool-for-4d-code-execution-in-cli/) to launch your 4D code.

## Inputs

### Launch a project

#### `project` (v1)

**Optional** The project file to run.

- If equal to `*` action will try to find it automatically
- If empty, nothing is run

#### `startup-method` (v1)

**Optional** The method to run at startup.

- If not defined, standard database method will run

#### `user-param` (v1)

**Optional** User parameters that could be acceded using 4D code:

```4d
var $r : Real
var $startupParam: Text
$r:=Get database parameter(User param value; $startupParam)
```

#### `error-flag` (v1)

**Optional** File used to check if there execution errors (default `error`). (see [Manage errors](#manage-errors))

### Choose tool4d version (v1)

The parametrised URL used to download too4d is: 
> `https://resources-download.4d.com/release/<product-line>/<version>/<build>/win/tool4d_v<build>_<os>.tar.xz`

#### `product-line` (v1)

**Optional** tool4d product line (default `20.x`)

#### `version` (v1)

**Optional** tool4d version (default `20.0`)

#### `build-method` (v1)

**Optional** tool4d build number (default `latest`)

## Outputs

### `tool4d` (v1)

tool4d binary path.

## Example

A full running example could be found here: [https://github.com/e-marchand/tool4d-action-test](https://github.com/e-marchand/tool4d-action-test)

### Launch with default parameters

- It will launch your `.4DProject` file found in `Project`
- `On Startup` database method will be launched

```yaml
name: Unit Tests
on:
 ... 

jobs:
  build:
    name: "Run on macOS"
    runs-on: macos-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - uses: e-marchand/tool4d-action@v1
      with:
        project: "*"
```

> 💡 without `project` parameter no tool4d will be launch

### Choose default method to launch

Here we choose to launch `runUnitTests` method.

```yaml
name: Unit Tests
on:
 ... 

jobs:
  build:
    name: "Run on macOS"
    runs-on: macos-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v3
    - uses: 4d/tool4d-action@v1
      with:
        project: "*"
        startup-method: runUnitTests
```

### Launch a specific method on macOS and windows

Using matrix, we could factorize. Here a full example

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
    - uses: 4d/tool4d-action@v1
      id: tool4d
      with:
        project: ${{ github.workspace }}/Project/Build4D_DF.4DProject
        startup-method: runUnitTests
```

## Manage errors

Create an `error` file in current working directory to notify action of some failures. (4D code do not allow to exit/quit with a specific exit code)
