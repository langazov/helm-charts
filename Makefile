.PHONY: help lint package clean install

# Default target
help:
	@echo "Available targets:"
	@echo "  help     - Show this help message"
	@echo "  lint     - Lint all charts"
	@echo "  package  - Package all charts"
	@echo "  clean    - Clean packaged charts"
	@echo "  install  - Install chart-testing (ct) tool"

# Lint all charts
lint:
	@echo "Linting charts..."
	helm lint charts/*/

# Package all charts
package:
	@echo "Packaging charts..."
	@mkdir -p docs
	@for chart in charts/*/; do \
		if [ -d "$$chart" ]; then \
			helm package "$$chart" --destination docs/; \
		fi \
	done
	@helm repo index docs --url https://$(GITHUB_USER).github.io/$(GITHUB_REPO)

# Clean packaged charts
clean:
	@echo "Cleaning packaged charts..."
	@rm -rf docs/*.tgz docs/index.yaml

# Install chart-testing tool
install:
	@echo "Installing chart-testing..."
	@curl -sSL https://github.com/helm/chart-testing/releases/download/v3.10.1/chart-testing_3.10.1_linux_amd64.tar.gz | tar xz
	@sudo mv ct /usr/local/bin/ct