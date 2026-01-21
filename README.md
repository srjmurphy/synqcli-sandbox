# SYNQ CLI Testing Guide

A quick-start guide for testing SYNQ CLI to deploy data quality monitors and tests.

## 📚 Available Guides

- **[README.md](README.md)** - This file: Quick start guide for basic deployment
- **[AI-ADVISOR-SETUP.md](AI-ADVISOR-SETUP.md)** - Complete guide for AI advisor with Snowflake/Okta SSO
- **[CLI-COMMANDS.md](CLI-COMMANDS.md)** - Detailed CLI commands reference and manual deployment
- **[test-setup.sh](test-setup.sh)** - Diagnostic script to verify your setup

## Overview

SYNQ CLI is a command-line tool for managing data quality tests and monitors as code. This guide provides everything you need to test SYNQ CLI with a sample monitor configuration.

**Need help with AI advisor or Snowflake?** See [AI-ADVISOR-SETUP.md](AI-ADVISOR-SETUP.md)

## Prerequisites

- SYNQ account with API credentials (Client ID and Client Secret)
- Your SYNQ API URL (e.g., `https://developer.synq.io`)
- A data source/table already integrated in SYNQ

## Quick Start

### 1. Install SYNQ CLI

**macOS (Apple Silicon):**
```bash
curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_darwin_arm64.tar.gz | tar -xz
sudo mv synqcli /usr/local/bin/
synqcli --version
```

**macOS (Intel):**
```bash
curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_darwin_amd64.tar.gz | tar -xz
sudo mv synqcli /usr/local/bin/
synqcli --version
```

**Linux (AMD64):**
```bash
curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_linux_amd64.tar.gz | tar -xz
sudo mv synqcli /usr/local/bin/
synqcli --version
```

### 2. Configure Authentication

Create a `.env` file in your project directory:

```bash
SYNQ_CLIENT_ID=your-client-id-here
SYNQ_CLIENT_SECRET=your-client-secret-here
SYNQ_API_URL=https://developer.synq.io
```

**Alternatively, export as environment variables:**
```bash
export SYNQ_CLIENT_ID="your-client-id-here"
export SYNQ_CLIENT_SECRET="your-client-secret-here"
export SYNQ_API_URL="https://developer.synq.io"
```

### 3. Update the Example Monitor

Edit `example-monitor.yaml` and replace:
- `namespace` - Your team/project namespace
- `monitored_ids` in the entities section - Replace `s_nyc_taxi` with your actual table identifier from SYNQ

Your table identifier should match the format shown in SYNQ (e.g., `bq-prod.dataset.table_name` or `snowflake-prod.database.schema.table_name`).

### 4. Test Your Configuration

**Preview changes without deploying (dry run):**
```bash
synqcli deploy example-monitor.yaml --dry-run
```

This will show you what SYNQ CLI plans to create/update without actually making changes.

### 5. Deploy Your Monitor

**Deploy the monitor:**
```bash
synqcli deploy example-monitor.yaml --auto-confirm
```

The `--auto-confirm` flag skips the confirmation prompt. Omit it if you want to review changes before applying.

### 6. Deploy Multiple Monitors

If you have multiple YAML files in a directory:

```bash
# Deploy all YAML files in the monitors directory
synqcli deploy monitors/**/*.yaml --auto-confirm

# Or deploy specific files
synqcli deploy monitors/finance-monitors.yaml monitors/sales-monitors.yaml --auto-confirm
```

## Running via GitHub Actions

See `.github/workflows/deploy-synq-monitors.yml` for a complete CI/CD workflow that:
- Validates monitor configurations on pull requests
- Automatically deploys monitors when changes are merged to main
- Uses GitHub Secrets for secure credential management

### Setting Up GitHub Actions

1. Add the following secrets to your GitHub repository (Settings → Secrets and variables → Actions):
   - `SYNQ_CLIENT_ID`
   - `SYNQ_CLIENT_SECRET`
   - `SYNQ_API_URL` (optional, defaults to `https://developer.synq.io`)

2. Place your monitor YAML files in the `monitors/` directory

3. Push changes to trigger the workflow

## CLI Commands Reference

### Deploy Commands

```bash
# Basic deployment
synqcli deploy example-monitor.yaml

# Dry run (preview only)
synqcli deploy example-monitor.yaml --dry-run

# Auto-confirm (skip prompts)
synqcli deploy example-monitor.yaml --auto-confirm

# Deploy specific namespace only
synqcli deploy monitors/**/*.yaml --namespace=finance-team

# Debug mode
synqcli deploy example-monitor.yaml --print-protobuf
```

### Export Existing Monitors

```bash
# Export all monitors to YAML files
synqcli export --output=./exported-monitors

# Export specific namespace
synqcli export --namespace=finance-team --output=./finance-monitors
```

### Generate Monitor Suggestions (AI Advisor)

```bash
# Generate suggestions for a table
synqcli advisor --entity-id="your-table-id"

# Generate with custom namespace
synqcli advisor --entity-id="your-table-id" --namespace=finance-team --output=./monitors

# Generate and deploy immediately
synqcli advisor --entity-id="your-table-id" --deploy --namespace=finance-team
```

## Example Monitor Explanation

The included `example-monitor.yaml` creates:

1. **Volume Monitor** - Tracks daily row count changes
2. **Automated Monitoring** - Enables SYNQ's anomaly detection with PRECISE sensitivity
3. **Daily Schedule** - Runs at midnight (540 minutes = 9:00 AM UTC)
4. **Timezone Support** - Configured for Europe/London

## File Structure

```
synqcli-sandbox/
├── .env                                    # Authentication credentials (DO NOT commit!)
├── README.md                               # This guide
├── example-monitor.yaml                    # Sample monitor configuration
├── monitors/                               # Directory for your monitor YAML files
└── .github/
    └── workflows/
        └── deploy-synq-monitors.yml        # GitHub Actions CI/CD workflow
```

## Troubleshooting

### Authentication Errors
- Verify your Client ID and Client Secret are correct
- Ensure the API URL matches your SYNQ region
- Check that environment variables are properly set

### Entity Not Found Errors
- Verify the table identifier matches exactly what appears in SYNQ
- Ensure the table/data source is already integrated in SYNQ
- Check for typos in namespace or entity IDs

### YAML Syntax Errors
- Validate YAML indentation (use spaces, not tabs)
- Check for missing required fields
- Use `--dry-run` to catch errors before deployment

### Debug Mode
For detailed troubleshooting information:
```bash
synqcli deploy example-monitor.yaml --print-protobuf
```

## Additional Resources

- **SYNQ CLI Repository:** https://github.com/getsynq/synqcli
- **Official Documentation:** https://docs.synq.io
- **Latest Releases:** https://github.com/getsynq/synqcli/releases
- **Support:** support@synq.io

## Next Steps

After successfully testing with the example monitor:

1. **Export existing monitors** from SYNQ to YAML for version control
2. **Create additional monitors** for your critical data tables
3. **Set up CI/CD** using the GitHub Actions workflow
4. **Explore advisor command** to generate AI-powered test suggestions
5. **Organize monitors** by namespace for different teams/projects

## Version Information

- SYNQ CLI Version: v0.3.0
- Configuration Schema: v1beta2
- Last Updated: January 2026
