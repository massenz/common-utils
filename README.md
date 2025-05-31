# `common-utils` Shell Utilities

---

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Build & Test](https://github.com/massenz/common-utils/actions/workflows/test.yaml/badge.svg)](https://github.com/massenz/common-utils/actions/workflows/test.yaml)
[![Release](https://github.com/massenz/common-utils/actions/workflows/release.yaml/badge.svg)](https://github.com/massenz/common-utils/actions/workflows/release.yaml)

![C++](https://img.shields.io/badge/C++-17-red)
![OS](https://img.shields.io/badge/OS-Linux,%20MacOS-green)

> A collection of utility scripts to simplify common tasks in shell scripts,
 templates for `Makefile` and testing/building scripts for C++ projects.

![Common Utils](images/common-utils-small.jpeg)

# Why these utilities

Remember that:

> If you are writing a script that is more than 100 lines long or that uses non-straightforward control flow logic, you should rewrite it in a more structured language now. Bear in mind that scripts grow. Rewrite your script early to avoid a more time-consuming rewrite at a later date.
>
> [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)

To keep the size and complexity of Bash scripts down to a minimal size, and yet retain enough expressivity within the script for some primitive functionality, I have decided to factor out all the commonality and just `source` it in my scripts.

To paraphrase the authors of the style guide: *this repository "is more a recognition of its use rather than a suggestion that it be used for widespread deployment"*.

# Contents

- a [Collection of Shell functions](#utils)
- a [Command-Line Argument Parser](#command-line-argument-parser)
- [Build / Test scripts](#buildtest-scripts)

# Install

The easiest way to install is to use the installer script:

```shell
export COMMON_UTILS=/path/to/common-utils
export VERSION=...
curl -s -L https://cdn.githubraw.com/massenz/common-utils/$VERSION/install.sh | zsh -s
```

with a recent [Release](https://github.com/massenz/common-utils/releases) for the `VERSION` string.

> **NOTE**
>
> If you are using the Bourne Shell (`bash`) replace `zsh` in the command above with `bash`

The initialization necessary to use the `common-utils` is written out to `$HOME/.commonrc` either copy it to your shell's initialization script (`.zshrc` if you are using the Z Shell; `.bashrc` for the Bourne Shell) or source it directly from there.

Alternatively, you can download the tarball from the Releases page and do the above manually; this is what is needed to properly use the utils, in your `.zshrc`:

```shell
export COMMON_UTILS=/path/to/common-utils
export PATH=$PATH:${COMMON_UTILS}
source ${COMMON_UTILS}/utils
```

## Usage

The `commons.cmake` can then be used inside other projects to include these files, as needed.

For an example, see [this project](https://bitbucket.org/marco/distlib/src/799add59f13d01a7e7c7f761f298642b844af316/CMakeLists.txt#lines-9).

To add the functions defined in `utils.sh` use something like:

```shell
source ${COMMON_UTILS}/utils
```

It is recommended that you add `$COMMON_UTILS` to your system's `PATH`:

```shell
export PATH=$PATH:$COMMON_UTILS
```

Even better, use the Common Utilities:

```shell
source ${COMMON_UTILS}/utils && \
    addpath ${COMMON_UTILS} && \
    success "Added ${COMMON_UTILS} to PATH"
```

# Utils

The `utils` script contains a collection of simple utilities for shell scripts (see [`utils.sh`](scripts/utils.sh) for a full description of each command).

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

This Python script tries to marry the best of both worlds, allowing with a relatively simple setup to parse arbitrary command line options and then having their values reflected in the corresponding local environment variables.

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

The argument is optional, and if it's not present the corresponding variable will be unset (`[[-z ${mount} ]]` would return `true`).

An optional trailing `modifier` changes the meaning of the argument:

- `!` : indicates a required argument, its absence will cause an error;
- `-` : designates a boolean argument, which takes no value and whose presence will result in the corresponding variable to be set;
- `+` : a *positional*, required, argument;
- `?` : an optional *positional* argument.
- `*` : an array of *positional* arguments (possibly empty, if none is present); 
        should be obviously last.

> *NOTE*
>
> "Positional" arguments are those that are not preceded by a `--arg` flag and whose **order** 
matters when the command line is parsed.  As such, an *optional* positional 
(or an array) **must** be the last in the list.
> 
> It is best to avoid combining optional positionals (`?`) and positional arrays (`*`) as they may
result in unexpected behavior.


For example (see the [`parse_example`](examples/parse_example) script):

```shell
source $(./parse_args keep- counts! take mount+ -- $@)
```

will result in:

```shell
$ ./parse_example --keep --take 3 --counts yes /var/loc/bac

Keeping mount: /var/loc/bac
Take: 3, counts: yes

$ ./parse_example.sh --keep --take 3 /mnt/media

usage: [-h] [--keep] [--take TAKE] --counts COUNTS [--mount MOUNT]
ERROR: the following arguments are required: --counts
```

Note how the `mount` "positional" argument is *required* and cannot be omitted:

```shell
$ ./parse_example --keep --take 3 --counts no         
usage: [-h] [--keep] [--take TAKE] --counts COUNTS mount
ERROR: the following arguments are required: mount
```


## Implementation

The source code is available [here](parse-args/parse_args.py) and revolves around adding arguments to `argparse.ArgumentParser` dynamically:

```python
for arg in args:
    kwargs = {}
    m = re.match(MODIFIED_PATTERN, arg)
    if m:
        # Take different action depending on the `modifier`            
        # then add to the parser.
        parser.add_argument(f"{prefix}{m.group('opt')}", **kwargs)
```

We have subclassed the `ArgumentParser` with a [`StderrParser`](parse-args/parse_args.py) so that:

* when erroring out, we emit error messages to `stderr` so they don't get "swallowed" in the bash script; and
* we need to exit with an error code, so that using `set -e` in our shell script will cause it to terminate, instead of executing the `source` command with potentially unexpected consequences.

# Build/Test scripts

These are generic scripts, which rely on a common `env.sh` script to be `source`d from the current directory:

```shell
export COMMON_UTILS=...
export PATH=$PATH:$COMMON_UTILS

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

See the [`libdist` project](https://github.com/massenz/distlib) for an example.


# Emojfy your Echo

The `gen-emoji` script uses OpenAI to generate contextually appropriate emojis for your shell script output messages, making them more visually appealing and easier to read.

## Requirements

1. Python 3.6 or higher
2. The `openai` and `halo` Python modules:
   ```shell
   pip install openai halo
   ```
3. An OpenAI API key set in the `OPENAI_KEY` environment variable:
   ```shell
   export OPENAI_KEY=your-api-key
   ```

## Setup

Ensure the `COMMON_UTILS` environment variable is set to the directory containing the common-utils repository (or just follow the [installation](#install) instructions above):

```shell
export COMMON_UTILS=/path/to/common-utils
export PATH=$PATH:$COMMON_UTILS
```

## Usage

You can use the `gen-emoji` just like any other command-line utility. It takes a string input and returns a formatted string with an emoji prefix based on the context of the message.

```shell
$ gen-emoji "Building a skyscraper"
"--- 🏗️ Building a skyscraper"
```
and then copy and paste the output into your shell script.

More interestingly, it can be used directly in your shell scripts to add emojis to your output messages:

```shell
#!/bin/bash

# Source the utils.sh file from COMMON_UTILS
source $COMMON_UTILS/utils.sh

# Use the emojify function in your script
emojify "Starting backup process"
# Your backup commands here

emojify "Compressing files"
# Your compression commands here

emojify "Backup completed successfully"
```

The script takes a text input and returns a formatted string with an emoji prefix. The emoji is chosen based on the context of the message using OpenAI's API. If the OpenAI API key is not set, it will fall back to a default wrench emoji.

You can also add this to your `.bashrc` or `.zshrc` file to make the function available in your shell:

```shell
# Source the utils.sh file from COMMON_UTILS
source $COMMON_UTILS/scripts/utils.sh
```

Then use it in your terminal or scripts:

```shell
$ emojify "Building Docker image"
--- 🐳 Building Docker image
```


# Emojify your Makefile

The `common.mk` template provides a convenient function to add emojis to your Makefile output messages, making them more visually appealing and easier to read.

## Setup

1. First, ensure the `COMMON_UTILS` environment variable is set to the directory containing the common-utils repository:

    ```shell
    export COMMON_UTILS=/path/to/common-utils
    ```

2. Include the `common.mk` template in your Makefile:

    ```makefile
    include $(COMMON_UTILS)/templates/common.mk
    ```

## Usage

There are two ways to use the emojify functionality:

1. As a function call within your Makefile targets:

    ```makefile
    compile:  ## Compiles the binary
        $(call emojify,Compiling program)
        # Your compilation commands here
    ```

2. As a standalone command:

    ```makefile
    deploy:  ## Deploys the application
        emojify "Deploying application"
        # Your deployment commands here
    ```

If the OpenAI API key is set in the `OPENAI_KEY` environment variable, the emojify function will use OpenAI to generate contextually appropriate emojis. Otherwise, it will fall back to a default wrench emoji.

See [examples/emojify.mk](examples/emojify.mk) for a complete example.

# Contributions

Are warmly appreciated; please open an `Issue` to describe what you think is missing, and you'd like to see added; or even feel free to contribute code via `Pull Request`.

This repository follows strictly the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html), please make sure you understand it and follow it in your contribution.
