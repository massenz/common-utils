# Copyright (c) 2023 AlertAvert.com.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0
# http://www.apache.org/licenses/LICENSE-2.0
#
# Author: Marco Massenzio (marco@alertavert.com)

include templates/common.mk

TESTDIR := parse-args
TARBALL := common-utils-$(version).tar.gz
python := $(shell which python3)

package:
	@mkdir -p dist
	./package.sh dist/$(TARBALL)

test:
ifeq ($(strip $(python)),)
	@echo "$(RED)ERROR:$(RESET) Missing python3 binary"
	@exit 1
endif
	@echo "--- Running tests in the ${TESTDIR} directory"
	$(python) -m unittest discover -s ${TESTDIR}

version:
	@echo $(version)
