# common-utils -- Shared utilities

[![Author](https://img.shields.io/badge/Author-M.%20Massenzio-green)](https://bitbucket.org/marco)
![Version](https://img.shields.io/badge/Version-0.4.0-blue)
![Released](https://img.shields.io/badge/Released-2021.11.27-green)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

![C++](https://img.shields.io/badge/C++-17-red)
![OS](https://img.shields.io/badge/OS-Linux,%20MacOS-green)

This is a collection of utility scripts to simplify option parsing from shell scripts, as well as simplify build/test of CMake-built C++ projects.

# Why these utilities

Remember that:

> If you are writing a script that is more than 100 lines long, or that uses non-straightforward control flow logic, you should rewrite it in a more structured language now. Bear in mind that scripts grow. Rewrite your script early to avoid a more time-consuming rewrite at a later date.
>
> [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

In order to keep the size and complexity of Bash scripts down to a minimal size, and yet retain enough expressivity within the script for some primitive functionality, I have decided to factor out all the commonality and just `source` it in my scripts.

To paraphrase the authors of the style guide: *this repository "is more a recognition of its use rather than a suggestion that it be used for widespread deployment"*.

# Contents

- a [Collection of Shell functions](#utils)
- a [Command-Line Argument Parser](#command-line-argument-parser)
- [Build / Test scripts](#buildtest-scripts)

# Usage

Simply download a release tarball of this repository, and untar it somewhere into your system; then point to it via the `$UTILS_DIR`, typically in your `.zshrc` (`.bashrc`) script, with something like:

```shell
sudo tar xf common-utils-$VERSION.tar.gz -C /opt
export UTILS_DIR=/opt/common-utils
```

The `commons.cmake` can then be used inside other projects to include these files, as needed.

For an example, see [this project](https://bitbucket.org/marco/distlib/src/799add59f13d01a7e7c7f761f298642b844af316/CMakeLists.txt#lines-9).

To add the functions defined in `utils.sh` use something like:

```shell
source ${UTILS_DIR}/utils
```

It is recommended that you add `$UTILS_DIR` to your system's `PATH`:

```shell
export PATH=$PATH:$UTILS_DIR
```

Even better, use the Common Utilities:

```shell
source ${UTILS_DIR}/utils && \
    addpath ${UTILS_DIR} && \
    success "Added ${UTILS_DIR} to PATH"
```

# Utils

The `utils` script contains a collection of simple utilities for shell scripts (see [`utils.sh`](utils.sh) for a full description of each command).

- general file and path handlers:
```
abspath [FILE | PATH]
addpath PATH
findfile [--dir DIR] FILE
```

- logging facilities (emit a timestamp and a log level):
```
msg MSG1 MSG2 ...
errmsg MSG1 MSG2 ...
success MSG
fatal MSG
```
- command wrappers:
```
wrap CMD [ARGS...]
wrap_no_out ERRMSG CMD [ARGS...]
```

- general utilities:
```
killn PROC-NAME
newenv NAME
now
```


# Command-Line Argument Parser


There is something to be said for the immediacy of using shell scripts, especially when dealing with relatively simple system operations; however, parsing command line arguments has always been rather cumbersome and usually done along the lines of painful `if [[ ${1} == '--build' ]] ...`.

On the other hand, Python is pretty convenient for system operations (especially when using the `sh` module), but sometimes a bit of an overkill, or just missing the immediacy of a simple shell script; however, the `argparse` module is nothing short of awesome, when it comes to power and flexibility in parsing command line options.

This simple Python script tries to marry the best of both worlds, allowing with a relatively simple setup to parse arbitrary command line options, and then having their values reflected in the corresponding local environment variables.

## Usage

The usage is rather straightforward: we invoke it with a list of the desired option names, followed by the actual command line arguments (`$@`) separated with `--`.

For example:

```shell
source $(./parse_args keep- take counts! mount -- $@)
```

The `-` indicates a boolean flag (its presence will set the associated variable, no value expected); the `!` indicates a required argument.

The values of the arguments (if any) are then available via the `${ }` operator:

```shell
if [[ -n ${keep} ]]; then
  echo "Keeping mount: ${mount}"
fi
```

## Modifiers

Each option by default indicates a named `--option` argument that expects a value:

    --mounts 3

The argument is optional and if it's not present the corresponding variable will be unset (`[[-z ${mount} ]]` would return `true`).

An optional trailing `modifier` changes the meaning of the argument:

- `!` : indicates a required argument, its absence will cause an error;
- `-` : designates a boolean argument, which takes no value and whose presence will result in the corresponding variable to be set);
- `+` : a positional, required, argument;
- `~` : an optional positional argument.

> *NOTE*
>
> "Positional" arguments are those which are not preceded by a `--arg` flag and whose **order** matters when the command line is parsed.  As such, obviously, an *optional* positional **must** be the last in the list.

For example (see the [`parse_example`](parse_example) script):

```shell
source $(./parse_args keep- mount counts! take -- $@)
```

will result in:

```shell
$ ./parse_example --keep --mount /var/loc/bac --take 3 --counts yes

Keeping mount: /var/loc/bac
Take: 3, counts: yes

$ ./parse_example.sh --keep --mount /var/loc/bac --take 3

usage: [-h] [--keep] [--take TAKE] --counts COUNTS [--mount MOUNT]
ERROR: the following arguments are required: --counts
```

## Implementation

The source code is available [here](parse_args.py) and revolves around adding arguments to `argparse.ArgumentParser` dynamically:

```python
    for arg in args:
        kwargs = {}
        m = re.match(MODIFIED_PATTERN, arg)
        if m:
            # Take different action depending on the `modifier`
            # then add to the parser.
            parser.add_argument(f"{prefix}{m.group('opt')}", **kwargs)
```

We have subclassed the `ArgumentParser` with a [`StderrParser`](parse_args.py#lines-12) so that:

* when erroring out, we emit error messages to `stderr` so they don't get "swallowed" in the bash script; and
* we need to exit with an error code, so that using `set -e` in our shell script will cause it to terminate, instead of executing the `source` command with potentially unexpected consequences.

## Build/Test scripts

These are generic scripts, which rely on a common `env.sh` script to be `source`d from the current directory:

```shell
export UTILS_DIR=...
export PATH=$PATH:$UTILS_DIR

build && runtests
```

They also expect a `$BUILDDIR` full path to point to the build directory, and the tests binaries to be in `$BUILDDIR/tests/bin`.

If your directory structure is something like this:

```
project
  |
  `-  env.sh
  |
  `- src/
  |
  `- build
  `- ... etc.
```

your `env.sh` could look something like (`utils` is `source`d by the `build` script immediately before `source`ing `env.sh`):

```shell
set -eu

BUILDDIR=$(abspath "./build")
CLANG=$(which clang++)

OS_NAME=$(uname -s)
msg "Build Platform: ${OS_NAME}"

... other configurations
```

See the [`libdist` project](https://bitbucket.org/marco/distlib) for an example.


# Contributions

Are warmly appreciated; please open an `Issue` to describe what you think is missing and you'd like to see added; or even feel free to contribute code via `Pull Request`.

This repository follows strictly the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), please make sure you understand it, and follow it in your contribution.
