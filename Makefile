# Copyright (c) 2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)

TESTDIR := parse-args
VERSION = $(shell ./scripts/get-version.sh manifest.json)
TARBALL := common-utils-$(VERSION).tar.gz

package:
	@mkdir -p dist
	./package.sh dist/$(TARBALL)

test:
	@echo "--- Running tests in the ${TESTDIR} directory"
	python -m unittest discover -s ${TESTDIR}

version:
	@echo $(VERSION)
