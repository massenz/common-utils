#!/usr/bin/env zsh
#
# Extends `find` to use .gitignore to exclude
# paths from results.
#
# Created M. Massenzio, 2024-05-04
declare -r search_dir=${1:-.}

# Start constructing the find command
cmd="find ${search_dir} -type f"

# Exclude common "noisy" directories
patterns=('.git' '.run' '.idea' '.cache')
for p in "${patterns[@]}"; do
  cmd+=" -not -path ${search_dir}/$p/'*'"
done

# If it exists in the current directory,
# or in the $search_dir path,
# read each line from .gitignore
gitignore=$((test -f ./.gitignore && echo './.gitignore') || \
    (test -f "${search_dir}/.gitignore" && echo "${search_dir}/.gitignore"))
if [[ -f ${gitignore} ]]; then
  while read -r pattern; do
    # Ignore empty lines and comments
    # Append the exclusion pattern to the find command
    # only if it is a directory exclusion pattern.
    if [[ -n "$pattern" && ! ( "$pattern" =~ '^#' || "$pattern" =~ '^!' ) \
          && "$pattern" =~ '/$' ]]; then
      cmd+=" -not -path '$search_dir/$pattern*'"
    fi
  done < ${gitignore}
fi

# Execute the find command
eval "$cmd"
