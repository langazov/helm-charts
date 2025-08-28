SHELL := /bin/bash

HELM ?= helm
CT ?= ct
CHARTS := $(wildcard charts/*)
DIST ?= dist

.PHONY: help lint package index clean ct-lint

help:
	@echo "Targets:"
	@echo "  lint      - Helm lint for all charts and ct lint (if available)"
	@echo "  package   - Package all charts into $(DIST)/"
	@echo "  index     - Generate index.yaml from $(DIST) packages"
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

# Set REPO_URL to where this repo will be hosted (e.g., https://<org>.github.io/<repo>)
REPO_URL ?=

index: package
	@if [ -z "$(REPO_URL)" ]; then \
		echo "[info] REPO_URL not set; generating index.yaml with relative URLs"; \
		$(HELM) repo index $(DIST); \
	else \
		echo "==> generating index.yaml with base URL $(REPO_URL)"; \
		$(HELM) repo index $(DIST) --url $(REPO_URL); \
	fi

clean:
	rm -rf $(DIST)
