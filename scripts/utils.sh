#
# Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

# Utility functions for shell scripting.
#
# Created M. Massenzio, 2015-09-01
# Updated: 2020-04-25
#
# Do not execute this script directly; `source` it instead from your own scripts.

# Prints the absolute path of the file or path; without arguments,
# it prints the absolute path of the current directory.
#
# Usage: abspath [FILE | PATH]
function abspath {
    local pathname=${1:-$(pwd)}
    local cmd=python3
    if [[ ! -x $(which $cmd) ]]; then cmd=python; fi
    echo $(${cmd} -c "import os; print(os.path.abspath(\"${pathname}\"))")
}


# Adds the given path to PATH
#
# Usage: addpath PATH
function addpath {
    local -r dir="$1"
    if [[ ! -d "${dir}" ]]; then
      fatal "Cannot add non-existent directory (${dir}) to \$PATH"
      return 1
    fi
    if [[ -z $(echo ${PATH} | grep ${dir}) ]]; then
      export PATH=${dir}:${PATH}
    fi
}


# Emits the current data in ISO-8960 format, truncated to the nearest minute, no TZ.
#
# Usage: now
function now {
    echo $(date +"%Y-%m-%dT%H:%M")
}

# Shared logging method.
#
# Do NOT use directly, prefer using pre-defined level functions:
# `msg`, `errmsg`, `fatal` and `success`.
#
# Usage: log LVL MSG
function log {
    local level=${1:-}
    shift 1
    local msg="$@"
    echo "$(now) [${level}] ${msg}"
}

# Emits an INFO message.
#
# Usage: msg MSG1 MSG2 ...
function msg {
    log "INFO" "$@"
}


# Emits an ERROR message
#
# Usage: errmsg MSG1 MSG2 ...
function errmsg {
    log "ERROR" "$@"
}


# Emits a SUCCESS message
#
# Usage: success MSG
function success {
    log "SUCCESS" "$@"
}


# Emits a FATAL message and exits with a non-zero error code.
#
# Uses the special $- argument to check whether the command is invoked
# from an interactive shell or from a script and will, respectively, either
# return a non-zero value, or exit altogether.
#
# Usage: fatal MSG
function fatal {
    log "FATAL" "$@"
    case "$-" in
        *i*) return 1 ;;
          *) exit 1 ;;
    esac
}


# Wraps the output of the given CMD ($1) by checking the outcome and emitting
# an appropriate log level (INFO or ERROR) depending on the outcome.
#
# If the retcode from the invoked command is non-zero, it will exit.
#
# Usage: wrap CMD [ARGS...]
function wrap {
    if [[ $# < 1 ]]; then
        errmsg "$0 function must be invoked with at least one argument (the command to execute)"
        return 1
    fi
    local CMD=$1
    shift
    OUT=$(${CMD} $@ 2>&1)
    RES=$?
    if [[ $RES != 0 ]]; then
        fatal ${OUT}
        return 1
    fi
    msg ${OUT}
    return 0
}


# Customization of the `wrap` function for long-running commands that emit a lot
# of stdout: it will just check the exit code and emit the message passed as $1 if
# an error occurs; it will not capture stdout.
#
# Usage: wrap_no_out ERRMSG CMD [ARGS...]
function wrap_no_out {
    if [[  $# -lt 2 ]]; then
        errmsg "Usage: $0 ERRMSG CMD [ARGS...]"
        return 1
    fi
    local MSG=$1
    local CMD=$2
    shift 2
    msg "Executing ${CMD}..."
    ${CMD} $@
    if [[ $? != 0 ]]; then
        fatal ${MSG}
        return 1
    fi
    return 0
}


# Kills the named process, if it exists
#
# Usage: killn PROC-NAME
function killn {
    if [[ $# < 1 ]]; then
        msg "Usage: killn PROC"
        fatal "killn MUST be invoked with the name of the process to kill."
        return 1
    fi
    PID=$(ps aux | grep -v grep | grep -i ${1} | cut -f 1 -d ' ')
    if [[ -n ${PID} ]]; then
        kill $PID
        return $?
    fi
    errmsg "No Process named ${1} found"
    return 1
}


# Looks up a filename in an optional subdirectory, or the current one.
#
# Usage: findfile [--dir DIR] FILE
function findfile {
    source $(parse-args dir fname+ -- $@)
    echo "dir: $dir fname: $fname" >&2
    local where=${dir:-.}

    find ${where} -name "${fname}" 2>/dev/null
}


# Creates and initializes a new Python Virtualenv
#
# Usage: newenv NAME
function newenv {
    local envname=${1:-}
    local reqsdir="${HOME}/.virtualenvs/requirements"
    local reqs="${reqsdir}/${envname}.txt"

    if [[ -z ${envname} ]]
    then
        fatal "Virtualenv NAME not provided"
        return 1
    fi
    mkvirtualenv -p $(which python3) ${envname}
    wrap_no_out "Failed to upgrade pip" pip install -U pip
    if [[ -e ${reqs} ]]
    then
        wrap pip install -U -r ${reqs}
    fi
    success "Virtualenv ${envname} created"
}

# Inserts a pause in the progress, and an option to terminate early.
#
# Usage: should_continue
function should_continue {
    if read -q "?Paused. Hit 'y' when ready to continue, or 'n' to terminate "; then
        echo -e "\nOk, continuing...\n"
    else
        echo -e "\nAborting\n"
        exit 1
    fi
}

# Asks an optional question and returns a non-zero value if the user
# responds anything other than `y`.
#
# Should be used in an `if` statement:
#
#   if ask "About to remove resource, continue?"; then
#      ... do the deed
#   fi
# Usage: ask [PROMPT]
function ask {
    read -q "?${1:-Proceed?} [y/n] "
    res=$?
    echo -n "\n"
    return $res
}

# Adds an emoji prefix to a message based on its context.
#
# If OPENAI_KEY is set, it uses OpenAI to generate a contextually appropriate emoji.
# Otherwise, it falls back to a default wrench emoji.
#
# Usage: emojify MESSAGE
function emojify {
    if [ -n "$OPENAI_KEY" ]; then
      gen-emoji.py "$1" | tr -d '"'
    else
      echo "--- 🔧 $1"
    fi
}
