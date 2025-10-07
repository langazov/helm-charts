# Helm Chart Repository

This repository contains Helm charts that are automatically packaged and published via GitHub Pages.

## Usage

Add this Helm repository to your local Helm installation:

```bash
helm repo add my-charts https://langazov.github.io/helm-charts
helm repo update
```

Search for available charts:

```bash
helm search repo my-charts
```

Install a chart:

```bash
helm install my-release my-charts/webapp
```

## Available Charts

- **webapp**: Example web application chart

## Development

### Prerequisites

- [Helm](https://helm.sh/docs/intro/install/) v3.0+
- [chart-testing](https://github.com/helm/chart-testing) (optional, for testing)

### Local Development

Lint all charts:

```bash
make lint
```

Package charts locally:

```bash
make package
```

Clean build artifacts:

```bash
make clean
```

### Adding a New Chart

1. Create a new directory under `charts/`:

```bash
helm create charts/my-new-chart
```

1. Customize the chart in `charts/my-new-chart/`

1. Test your chart:

```bash
helm lint charts/my-new-chart
helm template charts/my-new-chart
```

1. Commit and push your changes

### Release Process

Charts are automatically released when you:

1. Push changes to the `main` branch
2. The GitHub Actions workflow will:
   - Lint and test your charts
   - Package them
   - Create GitHub releases
   - Update the Helm repository index
   - Publish to GitHub Pages

## Repository Structure

```text
.
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── charts/                 # Helm charts
│   └── webapp/            # Example chart
├── docs/                  # Generated packages (GitHub Pages)
├── .ct.yaml              # Chart testing configuration
├── Makefile              # Local development commands
└── README.md             # This file
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes locally
5. Submit a pull request

The CI pipeline will automatically test your changes.
