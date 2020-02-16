SHELL := /bin/bash

menu:
	@perl -ne 'printf("%10s: %s\n","$$1","$$2") if m{^([\w+-]+):[^#]+#\s(.+)$$}' Makefile | sort -b

all: # Run everything except build
	$(MAKE) fmt
	$(MAKE) lint
	$(MAKE) test
	$(MAKE) docs

fmt: # Format with isort, black
	@echo
	drone exec --pipeline $@
	drone exec --pipeline $@-python

lint: # Run pyflakes, mypy
	@echo
	drone exec --pipeline $@
	drone exec --pipeline $@-python

test: # Run tests
	@echo
	drone exec --pipeline $@

docs: # Build docs
	@echo
	drone exec --pipeline $@

requirements: # Compile requirements
	@echo
	drone exec --pipeline $@

build: # Build container
	@echo
	drone exec --pipeline $@ --secret-file .drone.secret
	cat benchmark/build.json | jq -r 'to_entries | map(.value = (.value/1000000/1000 | tostring | split(".")[0] | tonumber))[] | "\(.value) \(.key)"' | sort -n | talign 1

watch: # Watch for changes
	@trap 'exit' INT; while true; do fswatch -0 src content | while read -d "" event; do case "$$event" in *.py) figlet woke; make lint test; break; ;; *.md) figlet docs; make docs; ;; esac; done; sleep 1; done
