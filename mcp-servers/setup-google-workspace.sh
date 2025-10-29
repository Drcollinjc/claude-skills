#!/bin/bash
# Setup Google Workspace MCP for team

set -e

echo "🔧 Setting up Google Workspace Integration"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is required${NC}"
    exit 1
fi

if ! command -v pip3 &> /dev/null; then
    echo -e "${RED}❌ pip3 is required${NC}"
    exit 1
fi

# Create directories
echo "Creating directories..."
mkdir -p ~/.claude-code/credentials
mkdir -p ~/.claude-code/mcp-servers

# Install Python packages
echo "Installing Python packages..."
pip3 install --upgrade google-auth google-auth-oauthlib google-auth-httplib2
pip3 install --upgrade google-api-python-client
pip3 install --upgrade pandas openpyxl python-pptx python-docx markdown2

# Check for Google credentials
if [ ! -f "$HOME/.claude-code/credentials/google-service-account.json" ]; then
    echo -e "${YELLOW}⚠️  Google Service Account credentials not found${NC}"
    echo ""
    echo "To set up Google Workspace access:"
    echo "1. Go to https://console.cloud.google.com"
    echo "2. Create a new project or select existing"
    echo "3. Enable these APIs:"
    echo "   - Google Drive API"
    echo "   - Google Docs API"
    echo "   - Google Sheets API"
    echo "   - Google Slides API"
    echo "4. Create Service Account:"
    echo "   - IAM & Admin > Service Accounts > Create"
    echo "   - Download JSON key"
    echo "5. Save as: ~/.claude-code/credentials/google-service-account.json"
    echo ""
    read -p "Press Enter when you have saved the credentials file..."

    if [ ! -f "$HOME/.claude-code/credentials/google-service-account.json" ]; then
        echo -e "${RED}❌ Credentials file still not found${NC}"
        echo "Please save the file and run this script again"
        exit 1
    fi
fi

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.claude-code/credentials/google-service-account.json"

# Add to shell profile
if ! grep -q "GOOGLE_APPLICATION_CREDENTIALS" ~/.bashrc; then
    echo "export GOOGLE_APPLICATION_CREDENTIALS=\"$HOME/.claude-code/credentials/google-service-account.json\"" >> ~/.bashrc
fi

if [ -f ~/.zshrc ] && ! grep -q "GOOGLE_APPLICATION_CREDENTIALS" ~/.zshrc; then
    echo "export GOOGLE_APPLICATION_CREDENTIALS=\"$HOME/.claude-code/credentials/google-service-account.json\"" >> ~/.zshrc
fi

# Test connection
echo ""
echo "Testing Google Workspace connection..."
python3 << 'PYTHON'
import os
import sys
from google.oauth2 import service_account
from googleapiclient.discovery import build

try:
    creds_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if not creds_file:
        print("❌ GOOGLE_APPLICATION_CREDENTIALS not set")
        sys.exit(1)

    SCOPES = [
        'https://www.googleapis.com/auth/drive.readonly',
        'https://www.googleapis.com/auth/documents.readonly',
        'https://www.googleapis.com/auth/spreadsheets.readonly',
        'https://www.googleapis.com/auth/presentations.readonly'
    ]

    creds = service_account.Credentials.from_service_account_file(
        creds_file, scopes=SCOPES)

    # Test each service
    drive = build('drive', 'v3', credentials=creds)
    drive.files().list(pageSize=1).execute()
    print("✅ Google Drive API: Connected")

    docs = build('docs', 'v1', credentials=creds)
    print("✅ Google Docs API: Connected")

    sheets = build('sheets', 'v4', credentials=creds)
    print("✅ Google Sheets API: Connected")

    slides = build('slides', 'v1', credentials=creds)
    print("✅ Google Slides API: Connected")

    print("\n✅ All Google Workspace services connected successfully!")

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)
PYTHON

# Create MCP configuration
echo ""
echo "Creating MCP configuration..."
cat > ~/.claude-code/mcp-google-workspace.json << 'JSON'
{
  "mcpServers": {
    "google-workspace": {
      "command": "python3",
      "args": ["-m", "mcp_google_workspace_server"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "${GOOGLE_APPLICATION_CREDENTIALS}"
      }
    }
  }
}
JSON

# Create helper command
cat > ~/bin/claude-workspace << 'BASH'
#!/bin/bash
# Quick access to Google Workspace operations

case "$1" in
    list)
        claude-code --skill integrations/google-workspace "List all team files"
        ;;
    create-doc)
        shift
        claude-code --skill documents/google-docs "Create document: $*"
        ;;
    create-sheet)
        shift
        claude-code --skill documents/google-sheets "Create spreadsheet: $*"
        ;;
    create-slides)
        shift
        claude-code --skill documents/powerpoint "Create presentation: $*"
        ;;
    analyze)
        shift
        claude-code --skill documents/google-sheets --skill documents/powerpoint \
            "Analyze data and create presentation: $*"
        ;;
    *)
        echo "Usage: claude-workspace [list|create-doc|create-sheet|create-slides|analyze] [description]"
        ;;
esac
BASH
chmod +x ~/bin/claude-workspace

echo ""
echo -e "${GREEN}✅ Google Workspace setup complete!${NC}"
echo ""
echo "Available commands:"
echo "  claude-workspace list                    - List team files"
echo "  claude-workspace create-doc 'title'      - Create document"
echo "  claude-workspace create-sheet 'title'    - Create spreadsheet"
echo "  claude-workspace create-slides 'title'   - Create presentation"
echo "  claude-workspace analyze 'description'   - Analyze and visualize"
echo ""
echo "To use in Claude Code:"
echo "  claude-code --skill documents/google-docs 'Create technical spec'"
echo "  claude-code --skill documents/google-sheets 'Analyze Q4 data'"
echo "  claude-code --skill documents/powerpoint 'Create investor deck'"
echo ""
echo "Service Account Email (share files with this):"
python3 -c "import json; print(json.load(open('$HOME/.claude-code/credentials/google-service-account.json'))['client_email'])"
