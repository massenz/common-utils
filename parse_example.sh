#!/usr/bin/env bash

# This prevents `source` to be invoked at all (and most likely error out)
# when parse_args fails to parse the given arguments.
set -e

# The `-` indicates a bool flag (its presence will set the associated variable, no
# value expected); the `!` indicates a required argument.
PARSED=$(./parse_args keep- take counts! mount -- $@)
source ${PARSED}

# Here we are using the parsed arguments as ordinary bash variables.
if [[ -n ${keep} ]]; then
  echo "Keeping mount: ${mount}"
fi

echo "Take ${take}, counts: ${counts}"

# This is optional, and removes the temporary file.
rm ${PARSED}
