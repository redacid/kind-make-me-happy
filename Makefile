-include .env
export
SHELL := /bin/bash
KIND_BIN := /usr/bin/kind

KIND_SA_NAME := redacid
KIND_SA_TOKEN_DURATION := 8760h
KIND_CLUSTER := test
KIND_CONTROL_PLANE_WAIT := 2m
KIND_CONTEXT := kind-$(KIND_CLUSTER)

# colors
GREEN = $(shell tput -Txterm setaf 2)
YELLOW = $(shell tput -Txterm setaf 3)
WHITE = $(shell tput -Txterm setaf 7)
RESET = $(shell tput -Txterm sgr0)
GRAY = $(shell tput -Txterm setaf 6)
TARGET_MAX_CHAR_NUM = 30

.EXPORT_ALL_VARIABLES:

all: help

# https://kind.sigs.k8s.io/docs/user/quick-start/#installation
# https://hub.docker.com/r/kindest/node/tags

## Kind help
kind-help:
	$(KIND_BIN) version
	$(KIND_BIN) --help
	$(KIND_BIN) create cluster --help

## First start kind cluster
kind-deploy: kind-destroy @kind-first-start

## Destroy kind cluster
kind-destroy: @kind-delete

@kind-first-start:
	$(KIND_BIN) create cluster --name $(KIND_CLUSTER) --wait $(KIND_CONTROL_PLANE_WAIT) --config kind-cluster-config.yaml --retain

## Delete kind cluster
@kind-delete:
	$(KIND_BIN) delete cluster --name $(KIND_CLUSTER)

cluster-info:
	kubectl cluster-info --context $(KIND_CONTEXT)
	kubectl cluster-info dump --context $(KIND_CONTEXT)

set-context:
	kubectl config get-contexts
	kubectl config set current-context $(KIND_CONTEXT)

## Shows help. | Help
help:
	@echo ''
	@echo 'Usage:'
	@echo ''
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-_]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
		    if (index(lastLine, "|") != 0) { \
				stage = substr(lastLine, index(lastLine, "|") + 1); \
				printf "\n ${GRAY}%s: \n\n", stage;  \
			} \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			if (index(lastLine, "|") != 0) { \
				helpMessage = substr(helpMessage, 0, index(helpMessage, "|")-1); \
			} \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''