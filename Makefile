#!make
include envfile

# This version-strategy uses git tags to set the version string
VERSION := $(shell git describe --tags --always --dirty)

STAGED_GO_FILES = $(shell git diff --cached --name-only | grep ".go$$")

CHANGED_GO_FILES = $(shell git diff --name-only | grep ".go$$")

ifeq (${PROD}, true)
	# do nothing
else ifeq (${DEV}, true)
	VERSION := ${VERSION}-dev
else ifeq (${HOTFIX}, true)
	VERSION := ${VERSION}-hotfix
else
	VERSION := ${VERSION}-local
endif

ALL_ARCH := amd64 arm arm64 ppc64le

# Set default base image dynamically for each arch
ifeq ($(ARCH),amd64)
    BASEIMAGE?=alpine
endif
ifeq ($(ARCH),arm)
    BASEIMAGE?=armel/busybox
endif
ifeq ($(ARCH),arm64)
    BASEIMAGE?=aarch64/busybox
endif
ifeq ($(ARCH),ppc64le)
    BASEIMAGE?=ppc64le/busybox
endif

IMAGE := $(REGISTRY)/$(BIN)

#_$(BIN)-$(ARCH)

# If you want to build all binaries, see the 'all-build' rule.
# If you want to build all containers, see the 'all-container' rule.
# If you want to build AND push all containers, see the 'all-push' rule.
all: build

build-%:
	@$(MAKE) --no-print-directory ARCH=$* build

all-build: $(addprefix build-, $(ALL_ARCH))

build: bin/$(ARCH)/$(BIN)

bin/$(ARCH)/$(BIN): build-dirs
	@echo "building: $@"
	 ARCH=$(ARCH)                                                    \
	 VERSION=$(VERSION)                                              \
	 PKG=$(PKG)                                                      \
	 ./build/build.sh                                                \

run: build # make ARGS="-arg1 val1 -arg2 -arg3" run
	CONFIG=file::dev_cfg/cfg.yml \
	./bin/$(ARCH)/$(BIN) ${ARGS}

version:
	@echo $(VERSION)

install-tools:
	./build/install-tools.sh

env:
	env

fmt:
	gofmt -w $(SRC_DIRS)

test: build-dirs
	./build/test.sh $(SRC_DIRS)

lint: lint-all

lint-all:
	revive -config revive.toml -formatter friendly -exclude vendor/... ./...

lint-changed:
	revive -config revive.toml -formatter friendly -exclude vendor/... $(CHANGED_GO_FILES)

lint-staged:
	revive -config revive.toml -formatter friendly -exclude vendor/... $(STAGED_GO_FILES)

lint-update:
	./build/lint-update.sh

mods: mod
mod:
	GOSUMDB=off ./build/mod.sh

build-dirs:
	@mkdir -p bin/$(ARCH)
	@mkdir -p .go/src/$(PKG) .go/pkg .go/bin .go/std/$(ARCH)

clean: bin-clean

watch:
	reflex --start-service=true -r '\.go$$' make run

watch-tests: watch-test
watch-test:
	reflex --start-service=true -r '\.go$$' make test

bin-clean:
	rm -rf .go bin
