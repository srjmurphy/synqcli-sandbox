# SYNQ CLI Setup Guide - AI Advisor with Snowflake/Okta

Complete setup guide for using SYNQ CLI's AI advisor feature with Snowflake and Okta authentication.

## Installation Troubleshooting

### Issue: "synqcli command not found"

When you run the curl command, it downloads and extracts the CLI to your **current directory**, but it's not in your system PATH.

**Solution:**

```bash
# Step 1: Download and extract (you already did this)
curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_darwin_arm64.tar.gz | tar -xz

# Step 2: Verify the file is in your current directory
ls -la synqcli

# Step 3: Make it executable (if not already)
chmod +x synqcli

# Step 4: Test it with ./synqcli (note the ./ prefix)
./synqcli --version

# Step 5: Move it to your PATH so you can run it from anywhere
sudo mv synqcli /usr/local/bin/

# Step 6: Now test without the ./
synqcli --version
```

**If Step 5 fails with permission error:**
```bash
# Alternative: Add to your home bin directory
mkdir -p ~/bin
mv synqcli ~/bin/
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
synqcli --version
```

## Environment Variables Setup

For the AI advisor feature, you need **two sets** of environment variables:

### 1. SYNQ Platform Authentication (Required)

```bash
export SYNQ_CLIENT_ID="your-synq-client-id"
export SYNQ_CLIENT_SECRET="your-synq-client-secret"
export SYNQ_API_URL="https://developer.synq.io"
```

### 2. AI Provider Configuration (Required for Advisor)

**Option A: OpenAI (Most Common)**
```bash
export OPENAI_API_KEY="sk-..."
```

**Option B: AWS Bedrock with Claude**
```bash
export AWS_BEDROCK_MODEL_ID="anthropic.claude-sonnet-4-20250514-v1:0"
export AWS_REGION="us-east-1"
export AWS_ACCESS_KEY_ID="your-aws-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret"
```

**Option C: Azure OpenAI or Custom Endpoint**
```bash
export OPENAI_API_KEY="your-azure-key"
export OPENAI_BASE_URL="https://your-azure-endpoint.openai.azure.com/v1"
```

### 3. Snowflake Connection (Optional, for Data Profiling)

**For Snowflake with Okta SSO:**
```bash
export DWH_TYPE="snowflake"
export DWH_ACCOUNT="your-account.snowflakecomputing.com"
export DWH_USERNAME="your.email@company.com"
export DWH_AUTH_TYPE="externalbrowser"
export DWH_WAREHOUSE="COMPUTE_WH"
export DWH_ROLE="ANALYST"
```

## Complete .env File Template

Create a `.env` file in your project directory:

```bash
# SYNQ Platform Authentication (Required)
SYNQ_CLIENT_ID=your-synq-client-id-here
SYNQ_CLIENT_SECRET=your-synq-client-secret-here
SYNQ_API_URL=https://developer.synq.io

# AI Provider - Choose ONE of the following:

# Option 1: OpenAI (Recommended)
OPENAI_API_KEY=sk-your-openai-api-key-here

# Option 2: AWS Bedrock with Claude (Uncomment to use)
# AWS_BEDROCK_MODEL_ID=anthropic.claude-sonnet-4-20250514-v1:0
# AWS_REGION=us-east-1
# AWS_ACCESS_KEY_ID=your-aws-access-key
# AWS_SECRET_ACCESS_KEY=your-aws-secret-key

# Option 3: Azure OpenAI (Uncomment to use)
# OPENAI_API_KEY=your-azure-openai-key
# OPENAI_BASE_URL=https://your-endpoint.openai.azure.com/v1

# Snowflake Connection (Optional - only needed for data profiling)
# For Okta SSO Authentication:
# DWH_TYPE=snowflake
# DWH_ACCOUNT=your-account.snowflakecomputing.com
# DWH_USERNAME=your.email@company.com
# DWH_AUTH_TYPE=externalbrowser
# DWH_WAREHOUSE=COMPUTE_WH
# DWH_ROLE=ANALYST
# DWH_DATABASE=PROD
```

## Snowflake with Okta SSO Setup

### Prerequisites

1. **Enable ID Token in Snowflake** (Required for SSO caching):
```sql
-- Run this as ACCOUNTADMIN in Snowflake
ALTER ACCOUNT SET ALLOW_ID_TOKEN = TRUE;
```

2. **Verify Okta is configured** as your Snowflake authenticator

### Method 1: Using .env File (Recommended)

Create a `.env` file:
```bash
# SYNQ Platform
SYNQ_CLIENT_ID=your-client-id
SYNQ_CLIENT_SECRET=your-client-secret
SYNQ_API_URL=https://developer.synq.io

# OpenAI for AI features
OPENAI_API_KEY=sk-your-key

# Snowflake with Okta
DWH_TYPE=snowflake
DWH_ACCOUNT=mycompany.snowflakecomputing.com
DWH_USERNAME=john.doe@company.com
DWH_AUTH_TYPE=externalbrowser
DWH_WAREHOUSE=COMPUTE_WH
DWH_ROLE=ANALYST
DWH_DATABASE=PROD
```

### Method 2: Using YAML Configuration File

Create `snowflake-connection.yaml`:
```yaml
- id: my-snowflake
  type: snowflake
  account: mycompany.snowflakecomputing.com
  username: john.doe@company.com
  auth_type: externalbrowser
  warehouse: COMPUTE_WH
  role: ANALYST
  databases: ["PROD", "DEV"]
```

## Testing Your Setup

### Step 1: Test SYNQ CLI Installation
```bash
synqcli --version
# Should output: synqcli version v0.3.0
```

### Step 2: Test SYNQ Platform Authentication
```bash
# Load environment variables
source .env  # or export them manually

# Test with a simple deploy dry-run
synqcli deploy your-monitor.yaml --dry-run
```

If authentication fails, you'll see:
```
Error: authentication failed
```

### Step 3: Test AI Advisor (Without Data Profiling)
```bash
# Basic test - just schema-based suggestions
synqcli advisor --entity-id="your-table-id"
```

Expected behavior:
- Opens browser for Okta login (if using Snowflake SSO)
- Generates test suggestions based on table schema
- Outputs YAML configuration

### Step 4: Test AI Advisor (With Snowflake Data Profiling)

**Using .env variables:**
```bash
synqcli advisor --entity-id="your-table-id" --output=./monitors
```

**Using YAML config file:**
```bash
synqcli advisor \
  --entity-id="your-snowflake-table" \
  --connections=snowflake-connection.yaml \
  --output=./monitors \
  --namespace=my-team
```

### Step 5: Verify Okta SSO Flow

When you run advisor with Snowflake:
1. Browser window opens automatically
2. Okta login page appears
3. After successful login, token is cached
4. CLI continues with data profiling
5. Token valid for ~4 hours

## Common Issues and Solutions

### Issue 1: "synqcli: command not found"
**Solution:** The CLI isn't in your PATH. Use `./synqcli` or move it to `/usr/local/bin/`

### Issue 2: "authentication failed"
**Solution:** Check your SYNQ credentials:
```bash
echo $SYNQ_CLIENT_ID
echo $SYNQ_CLIENT_SECRET
echo $SYNQ_API_URL
```

### Issue 3: "AI provider not configured"
**Solution:** Set OpenAI API key:
```bash
export OPENAI_API_KEY="sk-your-key"
```

### Issue 4: Okta browser doesn't open
**Solution:**
- Check `DWH_AUTH_TYPE=externalbrowser` is set
- Verify you're not in a headless environment
- Try manually: the CLI will provide a URL to open

### Issue 5: "ALLOW_ID_TOKEN must be enabled"
**Solution:** Run in Snowflake as ACCOUNTADMIN:
```sql
ALTER ACCOUNT SET ALLOW_ID_TOKEN = TRUE;
```

### Issue 6: Token expired after 4 hours
**Solution:** Just re-run the command - browser will open again for re-authentication

### Issue 7: "Table not found" in advisor
**Solution:** Ensure your table identifier matches SYNQ's format:
- Check exact format in SYNQ platform
- Example: `snowflake-prod.DATABASE.SCHEMA.TABLE`

## Complete Working Example

Here's a complete end-to-end example:

```bash
# 1. Install SYNQ CLI
curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_darwin_arm64.tar.gz | tar -xz
chmod +x synqcli
sudo mv synqcli /usr/local/bin/

# 2. Create .env file
cat > .env << 'EOF'
SYNQ_CLIENT_ID=abc123
SYNQ_CLIENT_SECRET=secret456
SYNQ_API_URL=https://developer.synq.io
OPENAI_API_KEY=sk-proj-xyz789
DWH_TYPE=snowflake
DWH_ACCOUNT=mycompany.snowflakecomputing.com
DWH_USERNAME=john.doe@company.com
DWH_AUTH_TYPE=externalbrowser
DWH_WAREHOUSE=COMPUTE_WH
DWH_ROLE=ANALYST
DWH_DATABASE=PROD
EOF

# 3. Load environment variables
set -a
source .env
set +a

# 4. Verify installation
synqcli --version

# 5. Generate AI suggestions with Snowflake profiling
synqcli advisor \
  --entity-id="snowflake-prod.PROD.PUBLIC.ORDERS" \
  --namespace=finance-team \
  --output=./monitors \
  --verbose

# 6. Review generated suggestions
cat monitors/finance-team/orders.yaml

# 7. Deploy the generated monitors
synqcli deploy monitors/finance-team/orders.yaml --dry-run
synqcli deploy monitors/finance-team/orders.yaml --auto-confirm
```

## Verification Checklist

- [ ] `synqcli --version` works without `./`
- [ ] `SYNQ_CLIENT_ID` is set and valid
- [ ] `SYNQ_CLIENT_SECRET` is set and valid
- [ ] `SYNQ_API_URL` is set (usually `https://developer.synq.io`)
- [ ] `OPENAI_API_KEY` is set (starts with `sk-`)
- [ ] Snowflake `ALLOW_ID_TOKEN` is enabled
- [ ] `DWH_AUTH_TYPE=externalbrowser` for Okta SSO
- [ ] Table identifier matches exact format in SYNQ

## Getting API Keys

### SYNQ Credentials
1. Log into SYNQ platform
2. Go to Settings → API Keys
3. Create new API key
4. Copy Client ID and Client Secret

### OpenAI API Key
1. Go to https://platform.openai.com/api-keys
2. Create new API key
3. Copy the key (starts with `sk-`)

### AWS Bedrock (Alternative)
1. AWS Console → IAM
2. Create user with Bedrock permissions
3. Generate access keys
4. Enable Claude model in Bedrock console

## Advanced: Using Advisor with Custom Instructions

```bash
synqcli advisor \
  --entity-id="snowflake-prod.PROD.PUBLIC.ORDERS" \
  --instructions="Focus on data quality checks for financial compliance. Include checks for negative amounts, null customer IDs, and future dates." \
  --namespace=finance-team \
  --output=./monitors \
  --deploy
```

## Next Steps

1. Test basic `synqcli --version`
2. Set up .env file with all credentials
3. Test advisor without Snowflake first
4. Add Snowflake connection for data profiling
5. Generate suggestions for your critical tables
6. Review and deploy generated monitors

## Support

If issues persist:
- Check SYNQ documentation: https://docs.synq.io
- Contact SYNQ support: support@synq.io
- Verify credentials in SYNQ platform
- Check Snowflake permissions for your user
