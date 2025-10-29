#!/bin/bash
# Quick setup for new team members

set -e

echo "👋 Welcome to Claude Skills Team Setup!"
echo "======================================"

# Clone the repository
if [ ! -d "$HOME/claude-skills" ]; then
    echo "📦 Cloning team skills repository..."
    read -p "Enter your GitHub organization name: " ORG_NAME
    git clone https://github.com/$ORG_NAME/claude-skills.git $HOME/claude-skills
else
    echo "📦 Updating skills repository..."
    cd $HOME/claude-skills
    git pull origin main
fi

cd $HOME/claude-skills

# Run main setup
echo "🚀 Running main setup..."
./setup-global-claude-skills.sh

# Setup Google Workspace
echo "🔧 Setting up Google Workspace..."
./mcp-servers/setup-google-workspace.sh

# Create quick start guide
cat > ~/claude-quick-reference.md << 'MARKDOWN'
# Claude Code Quick Reference

## Document Creation
- `claude-workspace create-doc "Technical Specification"`
- `claude-workspace create-sheet "Q4 Analysis"`
- `claude-workspace create-slides "Board Presentation"`

## Data Analysis
- `claude-code --skill documents/google-sheets "Analyze sales data"`

## Report Generation
- `claude-code --skill documents/reports "Generate monthly report"`

## Retrospectives
- `claude-retro` - Run after completing tasks

## Update Skills
- `claude-update-skills` - Get latest team skills
MARKDOWN

echo ""
echo "✅ Setup complete!"
echo ""
echo "See ~/claude-quick-reference.md for commands"
echo "Share Google Drive folders with the service account email shown above"
