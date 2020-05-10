# Shared utilities


Project   | common-utils
:---      | ---:
Author    | [M. Massenzio](https://bitbucket.org/marco)
Release   | 0.1.0
Updated   | 2020-05-09

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Usage

Simply clone this repository, then point to it via the `$COMMON_UTILS_DIR`, typically in your `.zshrc` (`.bashrc`) script, with something like:

```bash
export COMMON_UTILS_DIR=${HOME}/development/common-utils
```

This can then be used inside other projects to include these files, as needed.

For an example, see [this project](https://bitbucket.org/marco/distlib/src/799add59f13d01a7e7c7f761f298642b844af316/CMakeLists.txt#lines-9).

To add the functions defined in `utils.sh` use something like:

```bash
source ${COMMON_UTILS_DIR}/utils.sh
```

## Build/Test scripts

These are generic scripts, which rely on a common `env.sh` script to be `source`d from the same directory (typically, `bin`) in which links to these exist:

```shell script
ln -s ${COMMON_UTILS_DIR}/build.sh bin/build
ln -s ${COMMON_UTILS_DIR}/test.sh bin/test
```

They also expect a `$BUILDDIR` full path to be defined to the build directory, and the tests binaries to be in `$BUILDDIR/tests/bin`.

See the [`libdist` project](https://bitbucket.org/marco/distlib) for an example.

# Contributions

Are warmly appreciated; please open an `Issue` to describe what you think is missing and you'd like to see added; or even feel free to contribute code via `Pull Request`.

This repository follows strictly the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), please make sure you understand it, and follow it in your contribution.

## Why these utilities

Remember that:

> If you are writing a script that is more than 100 lines long, or that uses non-straightforward control flow logic, you should rewrite it in a more structured language now. Bear in mind that scripts grow. Rewrite your script early to avoid a more time-consuming rewrite at a later date.
>
> [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

In order to keep the size and complexity of the scripts down to a minimal size, and yet retain enough expressivity within the script for some primitive functionality, I have decided to factor out all the commonality and just `source` it in my scripts.

To paraphrase the authors of the style guide: *this repository "is more a recognition of its use rather than a suggestion that it be used for widespread deployment"*.
