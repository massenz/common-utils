# Copyright (c) 2024 AlertAvert.com.  All rights reserved.
# Created by M. Massenzio, 2022-03
#
# Makefile template for Go Applications

# Adjust location accordingly
include $(COMMON_UTILS)/common.mk

# Source files & Test files definitions
# Place all packages in a ./pkg subdir of the main project; the main binary
# should be placed in ./cmd/main.go (change the `build` target accordingly if you
# use something different).
pkgs := $(shell find pkg -mindepth 1 -type d)
all_go := $(shell for d in $(pkgs); do find $$d -name "*.go"; done)
test_srcs := $(shell for d in $(pkgs); do find $$d -name "*_test.go"; done)
srcs := $(filter-out $(test_srcs),$(all_go))
bin := $(prog)-$(RELEASE)_$(GOOS)-$(GOARCH)

##@ General
.PHONY: clean
clean: ## Cleans up the binary, container image and other data
	@rm -rf build
	@docker-compose -f $(compose) down
	@docker rmi $(shell docker images -q --filter=reference=$(image))

.PHONY: version
version: ## Displays the current version tag (release)
	@echo $(release)

.PHONY: fmt
fmt: ## Formats the Go source code using 'go fmt'
	@go fmt $(pkgs) ./cmd

##@ Development
$(out): cmd/main.go $(srcs)
	go build -ldflags "-X $(module)/Release=$(release)" -o $(out) cmd/main.go
	@chmod +x $(out)

build: $(out) ## Builds the server

test: $(srcs) $(test_srcs) ## Runs all tests in parallel
	ginkgo -p $(pkgs)

run: $(out) ## Runs the most recent build of the application
	@echo $(GREEN) Running $(out)...
	$(out)

$(cov)/cov.out: $(srcs) $(test_srcs)
	@go test -coverprofile=$(cov)/cov.out $(pkgs)
	@go tool cover -html=$(cov)/cov.out

.PHONY: coverage
coverage: $(cov)/cov.out ## Runs the Test Coverage target and opens a browser window with the coverage report

##@ Container Management
# Convenience targets to run locally containers and
# setup the test environments.
#
.PHONY: container
container: $(out) ## Builds the container image
	docker build -f $(dockerfile) -t $(image):$(release) .

.PHONY: start
start: ## Starts all the containers
	@RELEASE=$(release) docker-compose -f $(compose) up -d
