# Copyright (c) 2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)

TESTDIR := tests

test:
	@echo "--- Running tests in the ${TESTDIR} directory"
	python -m unittest discover -s ${TESTDIR}
