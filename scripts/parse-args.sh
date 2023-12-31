#!/usr/bin/env bash

#
# Copyright (c) 2020-2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)
#

workdir=$(dirname $(which parse-args))
python3 ${workdir}/parse_args.py $@
