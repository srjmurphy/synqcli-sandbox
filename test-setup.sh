#!/bin/bash
# SYNQ CLI Setup Verification Script
# Run this to diagnose setup issues

echo "======================================"
echo "SYNQ CLI Setup Verification"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: SYNQ CLI Installation
echo "1. Checking SYNQ CLI installation..."
if command -v synqcli &> /dev/null; then
    echo -e "${GREEN}✓${NC} synqcli is installed"
    synqcli --version
elif [ -f "./synqcli" ]; then
    echo -e "${YELLOW}⚠${NC} synqcli found in current directory but not in PATH"
    echo "   Run: sudo mv synqcli /usr/local/bin/"
    ./synqcli --version
else
    echo -e "${RED}✗${NC} synqcli not found"
    echo "   Download it with:"
    echo "   curl -L https://github.com/getsynq/synqcli/releases/download/v0.3.0/synqcli_0.3.0_darwin_arm64.tar.gz | tar -xz"
fi
echo ""

# Check 2: SYNQ Platform Authentication
echo "2. Checking SYNQ Platform credentials..."
if [ -z "$SYNQ_CLIENT_ID" ]; then
    echo -e "${RED}✗${NC} SYNQ_CLIENT_ID not set"
else
    echo -e "${GREEN}✓${NC} SYNQ_CLIENT_ID: ${SYNQ_CLIENT_ID:0:10}..."
fi

if [ -z "$SYNQ_CLIENT_SECRET" ]; then
    echo -e "${RED}✗${NC} SYNQ_CLIENT_SECRET not set"
else
    echo -e "${GREEN}✓${NC} SYNQ_CLIENT_SECRET: [hidden]"
fi

if [ -z "$SYNQ_API_URL" ]; then
    echo -e "${YELLOW}⚠${NC} SYNQ_API_URL not set (will use default)"
else
    echo -e "${GREEN}✓${NC} SYNQ_API_URL: $SYNQ_API_URL"
fi
echo ""

# Check 3: AI Provider Configuration
echo "3. Checking AI provider configuration..."
if [ -z "$OPENAI_API_KEY" ] && [ -z "$AWS_BEDROCK_MODEL_ID" ]; then
    echo -e "${RED}✗${NC} No AI provider configured"
    echo "   Set either OPENAI_API_KEY or AWS_BEDROCK_MODEL_ID"
elif [ ! -z "$OPENAI_API_KEY" ]; then
    echo -e "${GREEN}✓${NC} OpenAI API key configured: ${OPENAI_API_KEY:0:10}..."
    if [ ! -z "$OPENAI_BASE_URL" ]; then
        echo -e "${GREEN}✓${NC} Custom OpenAI endpoint: $OPENAI_BASE_URL"
    fi
elif [ ! -z "$AWS_BEDROCK_MODEL_ID" ]; then
    echo -e "${GREEN}✓${NC} AWS Bedrock configured: $AWS_BEDROCK_MODEL_ID"
    if [ -z "$AWS_REGION" ]; then
        echo -e "${YELLOW}⚠${NC} AWS_REGION not set (will use default: us-east-1)"
    else
        echo -e "${GREEN}✓${NC} AWS_REGION: $AWS_REGION"
    fi
fi
echo ""

# Check 4: Snowflake Configuration (Optional)
echo "4. Checking Snowflake configuration (for data profiling)..."
if [ -z "$DWH_TYPE" ]; then
    echo -e "${YELLOW}⚠${NC} Snowflake not configured (optional)"
    echo "   Advisor will work without data profiling"
else
    if [ "$DWH_TYPE" = "snowflake" ]; then
        echo -e "${GREEN}✓${NC} DWH_TYPE: snowflake"

        if [ -z "$DWH_ACCOUNT" ]; then
            echo -e "${RED}✗${NC} DWH_ACCOUNT not set"
        else
            echo -e "${GREEN}✓${NC} DWH_ACCOUNT: $DWH_ACCOUNT"
        fi

        if [ -z "$DWH_USERNAME" ]; then
            echo -e "${RED}✗${NC} DWH_USERNAME not set"
        else
            echo -e "${GREEN}✓${NC} DWH_USERNAME: $DWH_USERNAME"
        fi

        if [ "$DWH_AUTH_TYPE" = "externalbrowser" ]; then
            echo -e "${GREEN}✓${NC} DWH_AUTH_TYPE: externalbrowser (Okta SSO)"
        elif [ -z "$DWH_AUTH_TYPE" ]; then
            echo -e "${YELLOW}⚠${NC} DWH_AUTH_TYPE not set (will use default)"
        else
            echo -e "${GREEN}✓${NC} DWH_AUTH_TYPE: $DWH_AUTH_TYPE"
        fi

        if [ -z "$DWH_WAREHOUSE" ]; then
            echo -e "${YELLOW}⚠${NC} DWH_WAREHOUSE not set"
        else
            echo -e "${GREEN}✓${NC} DWH_WAREHOUSE: $DWH_WAREHOUSE"
        fi
    fi
fi
echo ""

# Check 5: .env File
echo "5. Checking for .env file..."
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC} .env file found"
    echo "   To load it, run: set -a && source .env && set +a"
elif [ -f ".env.example" ]; then
    echo -e "${YELLOW}⚠${NC} Only .env.example found"
    echo "   Copy it to .env and fill in your credentials:"
    echo "   cp .env.example .env"
else
    echo -e "${YELLOW}⚠${NC} No .env file found"
    echo "   Create one with your credentials"
fi
echo ""

# Summary
echo "======================================"
echo "Summary"
echo "======================================"

CRITICAL_ISSUES=0

if ! command -v synqcli &> /dev/null && [ ! -f "./synqcli" ]; then
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if [ -z "$SYNQ_CLIENT_ID" ] || [ -z "$SYNQ_CLIENT_SECRET" ]; then
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
fi

if [ -z "$OPENAI_API_KEY" ] && [ -z "$AWS_BEDROCK_MODEL_ID" ]; then
    echo -e "${YELLOW}⚠${NC} AI features require OpenAI or AWS Bedrock configuration"
fi

if [ $CRITICAL_ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Basic setup looks good!"
    echo ""
    echo "Next steps:"
    echo "1. If using .env file, load it: set -a && source .env && set +a"
    echo "2. Test advisor: synqcli advisor --entity-id='your-table-id'"
    echo "3. See AI-ADVISOR-SETUP.md for detailed usage examples"
else
    echo -e "${RED}✗${NC} Found $CRITICAL_ISSUES critical issue(s)"
    echo ""
    echo "Please fix the issues above and run this script again."
    echo "See AI-ADVISOR-SETUP.md for detailed setup instructions."
fi
echo ""
