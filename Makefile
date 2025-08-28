SHELL := /bin/bash

HELM ?= helm
CT ?= ct
CHARTS := $(wildcard charts/*)
DIST ?= dist

.PHONY: help lint package clean ct-lint

help:
	@echo "Targets:"
	@echo "  lint      - Helm lint for all charts and ct lint (if available)"
	@echo "  package   - Package all charts into $(DIST)/"
	@echo "  clean     - Remove build artifacts"

lint:
	@for c in $(CHARTS); do \
		echo "==> helm lint $$c"; \
		$(HELM) lint $$c || exit $$?; \
	 done
	@command -v $(CT) >/dev/null 2>&1 && echo "==> ct lint" && $(CT) lint --config .ct.yaml || true

package: clean
	@mkdir -p $(DIST)
	@for c in $(CHARTS); do \
		echo "==> packaging $$c"; \
		$(HELM) package $$c -d $(DIST) || exit $$?; \
	 done

clean:
	rm -rf $(DIST)
