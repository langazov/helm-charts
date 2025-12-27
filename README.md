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

Install with custom values:

```bash
helm install my-release my-charts/mariadb --set persistence.size=10Gi
```

Upgrade an existing release:

```bash
helm upgrade my-release my-charts/mongodb
```

## Available Charts

### Applications

- **gitea** (v0.2.1): A lightweight, self-hosted Git service with MariaDB backend
  - App Version: 1.21.11
  - Features: Version control, SCM, integrated MariaDB

- **webapp** (v0.1.0): Example web application chart for demonstration
  - App Version: 1.16.0

- **wordpress** (v0.1.1): WordPress CMS with MariaDB database
  - App Version: latest
  - Features: Blog, CMS platform

- **phpmyadmin** (v0.1.0): Web-based MySQL/MariaDB administration interface
  - App Version: 5.2.1
  - Features: Database management, admin interface

### Databases

- **mariadb** (v0.1.4): MariaDB LTS with automatic random password generation
  - App Version: lts
  - Features: MySQL-compatible database, secure password management

- **mongodb** (v0.1.1): MongoDB with authentication and random password generation
  - App Version: 8.0
  - Features: NoSQL database, secure authentication

- **mongodb-replicaset** (v0.1.5): MongoDB replica set with configurable member count
  - App Version: 7.0
  - Features: High availability, post-deploy initialization job, scalable replica set

- **redis** (v0.1.1): Redis in-memory data store
  - App Version: 8.2.2
  - Features: Caching, key-value store, Alpine-based image

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
│   ├── gitea/             # Gitea Git service chart
│   ├── mariadb/           # MariaDB database chart
│   ├── mongodb/           # MongoDB database chart
│   ├── mongodb-replicaset/ # MongoDB replica set chart
│   ├── phpmyadmin/        # phpMyAdmin admin interface chart
│   ├── redis/             # Redis cache chart
│   ├── webapp/            # Example web application chart
│   └── wordpress/         # WordPress CMS chart
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
