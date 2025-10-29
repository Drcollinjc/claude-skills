# Document Creation Skills

This directory contains skills for creating various types of documents.

## Available Skills

### PowerPoint (powerpoint.md)
- Create presentations programmatically
- Add charts and visualizations
- Template-based generation

### Google Sheets (google-sheets.md)
- Create and populate spreadsheets
- Data analysis and visualization
- Formula generation
- Formatting

### Google Docs (google-docs.md)
- Create formatted documents
- Template-based generation
- Markdown to Docs conversion

### Google Slides (google-slides.md)
- Create presentations in Google Slides
- Import charts from Sheets
- Template management

### Reports (reports.md)
- Multi-format report generation
- Combine multiple document types
- Automated workflows

## Setup

1. Run the setup script:
   ```bash
   ./mcp-servers/setup-google-workspace.sh
   ```

2. Share Google Drive folders with the service account

3. Use the skills:
   ```bash
   claude-code --skill documents/powerpoint "Create Q4 presentation"
   ```

## Evolution

These skills improve through usage:
- Formatting patterns get refined
- Templates evolve based on feedback
- New chart types get added
- Integration patterns improve
