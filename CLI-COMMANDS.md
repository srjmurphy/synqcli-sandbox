# SYNQ CLI Commands Reference

This guide shows you how to run SYNQ CLI commands manually, equivalent to what the GitHub Actions workflow does automatically.

## Prerequisites

Before running these commands:

1. Install SYNQ CLI (see README.md for installation instructions)
2. Set up authentication with your SYNQ credentials
3. Have your monitor YAML files ready

## Authentication Setup

### Option 1: Environment Variables (Recommended for local testing)

```bash
export SYNQ_CLIENT_ID="your-client-id-here"
export SYNQ_CLIENT_SECRET="your-client-secret-here"
export SYNQ_API_URL="https://developer.synq.io"
```

### Option 2: .env File (Recommended for projects)

Create a `.env` file in your project root:

```bash
cat > .env << 'EOF'
SYNQ_CLIENT_ID=your-client-id-here
SYNQ_CLIENT_SECRET=your-client-secret-here
SYNQ_API_URL=https://developer.synq.io
EOF
```

### Option 3: Command-Line Flags (Highest priority)

```bash
synqcli deploy example-monitor.yaml \
  --client-id="your-client-id" \
  --client-secret="your-client-secret" \
  --api-url="https://developer.synq.io"
```

## Manual Deployment Steps (Equivalent to GitHub Actions)

### Step 1: Download and Install SYNQ CLI

This is what the GitHub Action does in the "Download SYNQ CLI" step:

```bash
# Download SYNQ CLI v0.3.0
wget https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_linux_amd64.tar.gz

# Extract the archive
tar -xzf synqcli_0.3.0_linux_amd64.tar.gz

# Make it executable
chmod +x synqcli

# Verify installation
./synqcli --version

# Optional: Move to system path for easier access
sudo mv synqcli /usr/local/bin/
```

### Step 2: Validate Monitor Configurations (Dry Run)

This is what the GitHub Action does in the "validate" job:

```bash
# Validate example-monitor.yaml
synqcli deploy example-monitor.yaml --dry-run

# Validate all monitors in the monitors/ directory
synqcli deploy monitors/**/*.yaml --dry-run

# Validate specific files
synqcli deploy monitors/finance-monitors.yaml monitors/sales-monitors.yaml --dry-run
```

**What dry run does:**
- Parses YAML files for syntax errors
- Validates against SYNQ's schema
- Shows what changes will be made
- Does NOT actually deploy anything

### Step 3: Deploy Monitors to SYNQ

This is what the GitHub Action does in the "deploy" job:

```bash
# Deploy example-monitor.yaml
synqcli deploy example-monitor.yaml --auto-confirm

# Deploy all monitors in the monitors/ directory
for file in monitors/*.yml monitors/*.yaml; do
  if [ -f "$file" ]; then
    echo "Processing $file"
    synqcli deploy "$file" --auto-confirm
  fi
done
```

**Alternative: Deploy all at once**
```bash
# Deploy multiple files in a single command
synqcli deploy monitors/**/*.yaml --auto-confirm

# Deploy all YAML files including subdirectories
synqcli deploy monitors/**/*.{yml,yaml} --auto-confirm
```

## Complete Manual Deployment Script

Here's a complete script that replicates the entire GitHub Actions workflow:

```bash
#!/bin/bash
set -e  # Exit on any error

echo "=== SYNQ Monitor Deployment Script ==="
echo ""

# Check if SYNQ CLI is installed
if ! command -v synqcli &> /dev/null; then
    echo "SYNQ CLI not found. Installing..."
    wget https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_linux_amd64.tar.gz
    tar -xzf synqcli_0.3.0_linux_amd64.tar.gz
    chmod +x synqcli
    sudo mv synqcli /usr/local/bin/
    echo "SYNQ CLI installed successfully"
fi

# Verify SYNQ CLI version
echo "SYNQ CLI version:"
synqcli --version
echo ""

# Validate authentication
if [ -z "$SYNQ_CLIENT_ID" ] || [ -z "$SYNQ_CLIENT_SECRET" ]; then
    echo "ERROR: SYNQ_CLIENT_ID and SYNQ_CLIENT_SECRET must be set"
    echo "Run: export SYNQ_CLIENT_ID='your-id' && export SYNQ_CLIENT_SECRET='your-secret'"
    exit 1
fi

echo "=== Step 1: Validating Monitor Configurations ==="
echo ""

# Validate example-monitor.yaml
if [ -f "example-monitor.yaml" ]; then
    echo "Validating example-monitor.yaml..."
    synqcli deploy example-monitor.yaml --dry-run
    echo ""
fi

# Validate monitors directory
if [ -d "monitors" ]; then
    echo "Validating monitors in monitors/ directory..."
    for file in monitors/*.yml monitors/*.yaml; do
        if [ -f "$file" ]; then
            echo "Validating $file..."
            synqcli deploy "$file" --dry-run
        fi
    done
    echo ""
fi

echo "=== Validation Complete ==="
echo ""
read -p "Do you want to proceed with deployment? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled"
    exit 0
fi

echo ""
echo "=== Step 2: Deploying Monitors to SYNQ ==="
echo ""

# Deploy example-monitor.yaml
if [ -f "example-monitor.yaml" ]; then
    echo "Deploying example-monitor.yaml..."
    synqcli deploy example-monitor.yaml --auto-confirm
    echo ""
fi

# Deploy monitors directory
if [ -d "monitors" ]; then
    echo "Deploying monitors from monitors/ directory..."
    for file in monitors/*.yml monitors/*.yaml; do
        if [ -f "$file" ]; then
            echo "Deploying $file..."
            synqcli deploy "$file" --auto-confirm
        fi
    done
    echo ""
fi

echo "=== Deployment Complete ==="
echo ""
echo "All monitors have been successfully deployed to SYNQ!"
```

Save this script as `deploy-monitors.sh` and run it:

```bash
# Make it executable
chmod +x deploy-monitors.sh

# Run the deployment
./deploy-monitors.sh
```

## Common CLI Workflows

### Workflow 1: Quick Test & Deploy

```bash
# 1. Validate your configuration
synqcli deploy example-monitor.yaml --dry-run

# 2. If validation passes, deploy
synqcli deploy example-monitor.yaml --auto-confirm
```

### Workflow 2: Deploy with Manual Review

```bash
# Deploy without --auto-confirm to review changes before applying
synqcli deploy example-monitor.yaml
```

This will show you the changes and prompt:
```
The following changes will be applied:
  + Create monitor: s_nyc_taxi_growth_daily_cicd_workflow

Do you want to continue? (yes/no):
```

### Workflow 3: Deploy Specific Namespace Only

```bash
# Deploy only monitors in a specific namespace
synqcli deploy monitors/**/*.yaml --namespace=finance-team --auto-confirm
```

### Workflow 4: Debug Deployment Issues

```bash
# Use debug mode to see detailed information
synqcli deploy example-monitor.yaml --print-protobuf

# This outputs detailed protobuf messages in JSON format
```

### Workflow 5: Export Existing Monitors

```bash
# Export all monitors to YAML files for version control
synqcli export --output=./exported-monitors

# Export specific namespace
synqcli export --namespace=finance-team --output=./finance-monitors

# Review the exported files
ls -la exported-monitors/
```

### Workflow 6: Generate AI Suggestions

```bash
# Generate monitor suggestions for a table
synqcli advisor --entity-id="bq-prod.dataset.orders"

# Generate and save to specific directory
synqcli advisor --entity-id="bq-prod.dataset.orders" --output=./monitors --namespace=finance-team

# Generate and immediately deploy
synqcli advisor --entity-id="bq-prod.dataset.orders" --deploy --namespace=finance-team
```

## Advanced Usage

### Deploy Multiple Files Selectively

```bash
# Deploy specific files only
synqcli deploy \
  monitors/critical-tables.yaml \
  monitors/daily-checks.yaml \
  --auto-confirm

# Deploy all YAML files except certain ones
synqcli deploy monitors/*.yaml \
  --auto-confirm \
  | grep -v "test-monitors.yaml"
```

### Continuous Deployment Loop (for testing)

```bash
# Watch for changes and auto-deploy (requires inotify-tools)
while inotifywait -e modify,create,delete monitors/*.yaml; do
  echo "Changes detected, redeploying..."
  synqcli deploy monitors/**/*.yaml --auto-confirm
  echo "Deployment complete at $(date)"
done
```

### Deploy with Different Environments

```bash
# Development environment
export SYNQ_API_URL="https://dev.synq.io"
synqcli deploy monitors/**/*.yaml --namespace=dev-team --auto-confirm

# Production environment
export SYNQ_API_URL="https://developer.synq.io"
synqcli deploy monitors/**/*.yaml --namespace=prod-team --auto-confirm
```

## Troubleshooting Commands

### Check Authentication

```bash
# Verify environment variables are set
echo "Client ID: ${SYNQ_CLIENT_ID:0:10}..."
echo "API URL: $SYNQ_API_URL"

# Test deployment with dry run
synqcli deploy example-monitor.yaml --dry-run
```

### Validate YAML Syntax

```bash
# Use yamllint if available
yamllint example-monitor.yaml

# Or use Python
python -c "import yaml; yaml.safe_load(open('example-monitor.yaml'))"
```

### Debug Network Issues

```bash
# Test API connectivity
curl -I $SYNQ_API_URL

# Deploy with verbose output
synqcli deploy example-monitor.yaml --print-protobuf
```

## Comparison: GitHub Actions vs. Manual CLI

| Action | GitHub Actions | Manual CLI |
|--------|---------------|------------|
| **Installation** | Automatic (downloads in workflow) | Manual (one-time setup) |
| **Authentication** | GitHub Secrets | Environment variables or .env |
| **Validation** | Automatic on PR | Run `--dry-run` manually |
| **Deployment** | Automatic on merge to main | Run `--auto-confirm` manually |
| **Error Handling** | Workflow fails, shows in PR | Terminal output, manual review |
| **Rollback** | Revert commit | Re-deploy previous YAML |
| **Approval** | PR review process | Manual confirmation prompt |

## Quick Reference

```bash
# Most common commands
synqcli deploy <file.yaml>              # Deploy with confirmation
synqcli deploy <file.yaml> --auto-confirm    # Deploy without confirmation
synqcli deploy <file.yaml> --dry-run    # Validate only, don't deploy
synqcli export --output=./monitors      # Export existing monitors
synqcli advisor --entity-id="table-id"  # Generate AI suggestions
synqcli --version                       # Check CLI version
synqcli --help                          # Show help
```

## Next Steps

1. Test the dry-run command with your example-monitor.yaml
2. Deploy your first monitor manually
3. Set up the GitHub Actions workflow for automated deployment
4. Export your existing monitors to YAML for version control
5. Use advisor to generate suggestions for your critical tables
