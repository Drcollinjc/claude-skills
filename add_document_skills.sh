#!/bin/bash
# add-document-skills.sh
# Add document creation and Google Workspace skills to existing claude-skills repo

set -e

echo "📚 Adding Document Creation & Google Workspace Skills"
echo "===================================================="

# Check if in claude-skills repo
if [ ! -d "skills" ] || [ ! -d "orchestrator" ]; then
    echo "❌ Please run from your claude-skills repository root"
    exit 1
fi

# Create new skill categories
echo "📁 Creating document skill directories..."
mkdir -p skills/documents
mkdir -p skills/integrations
mkdir -p mcp-servers/{google-drive,google-docs,google-sheets}
mkdir -p templates/documents
mkdir -p team-setup

# Create PowerPoint skill
echo "📝 Creating PowerPoint skill..."
cat > skills/documents/powerpoint.md << 'EOF'
# PowerPoint Creation Skill v1.0.0

## Purpose
Create professional PowerPoint presentations programmatically

## Activation
- Keywords: powerpoint, presentation, slides, ppt, deck
- Use when: Creating presentations, slide decks, or visual reports

## Dependencies
```bash
pip install python-pptx pillow pandas matplotlib seaborn
```

## Core Patterns

### Basic Presentation Creation
```python
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor

class PresentationBuilder:
    def __init__(self, template=None):
        self.prs = Presentation(template) if template else Presentation()
        self.slides = []

    def add_title_slide(self, title, subtitle=""):
        slide = self.prs.slides.add_slide(self.prs.slide_layouts[0])
        slide.shapes.title.text = title
        if subtitle and len(slide.placeholders) > 1:
            slide.placeholders[1].text = subtitle
        return slide

    def add_content_slide(self, title, bullets):
        slide = self.prs.slides.add_slide(self.prs.slide_layouts[1])
        slide.shapes.title.text = title

        text_frame = slide.placeholders[1].text_frame
        text_frame.clear()  # Clear any default text

        for bullet in bullets:
            p = text_frame.add_paragraph()
            p.text = bullet
            p.level = 0
            p.font.size = Pt(18)

        return slide

    def add_chart_slide(self, title, chart_path):
        slide = self.prs.slides.add_slide(self.prs.slide_layouts[5])
        slide.shapes.title.text = title

        # Add chart image
        left = Inches(1)
        top = Inches(2)
        height = Inches(4.5)
        slide.shapes.add_picture(chart_path, left, top, height=height)

        return slide

    def save(self, filename):
        self.prs.save(filename)
        return filename
```

### Data Visualization Integration
```python
import matplotlib.pyplot as plt
import seaborn as sns
from io import BytesIO

def create_chart_for_slide(data, chart_type='bar', title=""):
    plt.figure(figsize=(10, 6))

    if chart_type == 'bar':
        plt.bar(data.index, data.values)
    elif chart_type == 'line':
        plt.plot(data.index, data.values, marker='o')
    elif chart_type == 'pie':
        plt.pie(data.values, labels=data.index, autopct='%1.1f%%')

    plt.title(title)
    plt.tight_layout()

    # Save to bytes
    img_buffer = BytesIO()
    plt.savefig(img_buffer, format='png', dpi=150, bbox_inches='tight')
    img_buffer.seek(0)
    plt.close()

    return img_buffer
```

### Report Generation Pattern
```python
def generate_quarterly_report(quarter_data):
    builder = PresentationBuilder()

    # Title slide
    builder.add_title_slide(
        f"Q{quarter_data['quarter']} {quarter_data['year']} Report",
        f"Generated: {datetime.now().strftime('%Y-%m-%d')}"
    )

    # Executive summary
    builder.add_content_slide("Executive Summary", [
        f"Revenue: ${quarter_data['revenue']:,.0f}",
        f"Growth: {quarter_data['growth']:.1f}%",
        f"New Customers: {quarter_data['new_customers']:,}",
        f"Retention Rate: {quarter_data['retention']:.1f}%"
    ])

    # Revenue chart
    chart_buffer = create_chart_for_slide(
        quarter_data['monthly_revenue'],
        'bar',
        'Monthly Revenue'
    )
    builder.add_chart_slide("Revenue Trend", chart_buffer)

    # Key achievements
    builder.add_content_slide("Key Achievements",
                             quarter_data['achievements'])

    # Next steps
    builder.add_content_slide("Next Quarter Focus",
                             quarter_data['next_steps'])

    # Save
    filename = f"Q{quarter_data['quarter']}_{quarter_data['year']}_report.pptx"
    builder.save(filename)
    return filename
```

## Best Practices
- Keep slides simple (6-8 lines max)
- Use consistent formatting
- Include page numbers
- Use high-quality images (150+ DPI)
- Follow 10-20-30 rule: 10 slides, 20 minutes, 30pt font minimum

## Anti-Patterns
- Wall of text
- Too many colors/fonts
- Low-resolution images
- Overcrowded charts
- Missing slide numbers

## Testing
```python
def test_presentation_creation():
    builder = PresentationBuilder()
    builder.add_title_slide("Test Presentation")
    builder.add_content_slide("Test Content", ["Point 1", "Point 2"])
    filename = builder.save("test.pptx")
    assert os.path.exists(filename)
    os.remove(filename)
```

## Evolution
- v1.0.0: Initial implementation with basic patterns
EOF

# Create Google Sheets skill
echo "📝 Creating Google Sheets skill..."
cat > skills/documents/google-sheets.md << 'EOF'
# Google Sheets Automation Skill v1.0.0

## Purpose
Create, manipulate, and analyze Google Sheets programmatically

## Activation
- Keywords: sheets, spreadsheet, excel, data, csv, analysis
- Use when: Working with tabular data, creating reports, data analysis

## Setup
```bash
pip install --upgrade google-auth google-auth-oauthlib google-auth-httplib2
pip install --upgrade google-api-python-client
pip install pandas openpyxl xlsxwriter
```

## Authentication
```python
from google.oauth2 import service_account
from googleapiclient.discovery import build
import os

def get_sheets_service():
    """Get authenticated Google Sheets service"""
    SCOPES = ['https://www.googleapis.com/auth/spreadsheets']

    creds_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    if not creds_file:
        raise ValueError("Set GOOGLE_APPLICATION_CREDENTIALS environment variable")

    creds = service_account.Credentials.from_service_account_file(
        creds_file, scopes=SCOPES)

    return build('sheets', 'v4', credentials=creds)
```

## Core Patterns

### Create and Populate Sheet
```python
import pandas as pd

class GoogleSheetsManager:
    def __init__(self):
        self.service = get_sheets_service()

    def create_spreadsheet(self, title, data=None):
        """Create new spreadsheet with optional data"""
        spreadsheet = {
            'properties': {'title': title}
        }

        result = self.service.spreadsheets().create(
            body=spreadsheet).execute()

        spreadsheet_id = result['spreadsheetId']

        if data is not None:
            self.write_data(spreadsheet_id, data)

        return spreadsheet_id

    def write_data(self, spreadsheet_id, data, range_name='A1'):
        """Write pandas DataFrame or list to sheet"""
        if isinstance(data, pd.DataFrame):
            values = [data.columns.tolist()] + data.values.tolist()
        else:
            values = data

        body = {'values': values}

        self.service.spreadsheets().values().update(
            spreadsheetId=spreadsheet_id,
            range=range_name,
            valueInputOption='RAW',
            body=body
        ).execute()

    def read_data(self, spreadsheet_id, range_name='A1:Z1000'):
        """Read data from sheet into pandas DataFrame"""
        result = self.service.spreadsheets().values().get(
            spreadsheetId=spreadsheet_id,
            range=range_name
        ).execute()

        values = result.get('values', [])

        if not values:
            return pd.DataFrame()

        # First row as headers
        df = pd.DataFrame(values[1:], columns=values[0])
        return df
```

### Data Analysis Pattern
```python
def analyze_spreadsheet(spreadsheet_id):
    """Perform analysis and add summary sheet"""
    manager = GoogleSheetsManager()

    # Read data
    df = manager.read_data(spreadsheet_id)

    # Perform analysis
    summary = {
        'Total Rows': len(df),
        'Columns': len(df.columns),
        'Numeric Columns': len(df.select_dtypes(include=['number']).columns),
        'Missing Values': df.isnull().sum().sum(),
        'Memory Usage': f"{df.memory_usage(deep=True).sum() / 1024:.2f} KB"
    }

    # Add summary statistics for numeric columns
    numeric_cols = df.select_dtypes(include=['number']).columns
    for col in numeric_cols:
        summary[f'{col} Mean'] = df[col].mean()
        summary[f'{col} Std'] = df[col].std()
        summary[f'{col} Min'] = df[col].min()
        summary[f'{col} Max'] = df[col].max()

    # Create summary sheet
    summary_data = [[k, v] for k, v in summary.items()]
    summary_data.insert(0, ['Metric', 'Value'])

    # Add new sheet
    requests = [{
        'addSheet': {
            'properties': {
                'title': 'Analysis Summary'
            }
        }
    }]

    manager.service.spreadsheets().batchUpdate(
        spreadsheetId=spreadsheet_id,
        body={'requests': requests}
    ).execute()

    # Write summary
    manager.write_data(spreadsheet_id, summary_data, 'Analysis Summary!A1')

    return summary
```

### Formatting Pattern
```python
def format_spreadsheet(spreadsheet_id, sheet_name='Sheet1'):
    """Apply professional formatting"""
    service = get_sheets_service()

    # Get sheet ID
    sheet_metadata = service.spreadsheets().get(
        spreadsheetId=spreadsheet_id).execute()

    sheet_id = None
    for sheet in sheet_metadata.get('sheets', []):
        if sheet['properties']['title'] == sheet_name:
            sheet_id = sheet['properties']['sheetId']
            break

    if not sheet_id:
        return

    requests = [
        # Header formatting
        {
            'repeatCell': {
                'range': {
                    'sheetId': sheet_id,
                    'startRowIndex': 0,
                    'endRowIndex': 1
                },
                'cell': {
                    'userEnteredFormat': {
                        'backgroundColor': {'red': 0.2, 'green': 0.2, 'blue': 0.5},
                        'textFormat': {
                            'foregroundColor': {'red': 1, 'green': 1, 'blue': 1},
                            'bold': True
                        }
                    }
                },
                'fields': 'userEnteredFormat(backgroundColor,textFormat)'
            }
        },
        # Auto-resize columns
        {
            'autoResizeDimensions': {
                'dimensions': {
                    'sheetId': sheet_id,
                    'dimension': 'COLUMNS',
                    'startIndex': 0,
                    'endIndex': 20
                }
            }
        }
    ]

    service.spreadsheets().batchUpdate(
        spreadsheetId=spreadsheet_id,
        body={'requests': requests}
    ).execute()
```

## Integration with Pandas
```python
def excel_to_google_sheets(excel_file, sheet_title):
    """Convert Excel file to Google Sheets"""
    # Read Excel
    df = pd.read_excel(excel_file)

    # Create Google Sheet
    manager = GoogleSheetsManager()
    spreadsheet_id = manager.create_spreadsheet(sheet_title, df)

    # Format
    format_spreadsheet(spreadsheet_id)

    return spreadsheet_id
```

## Best Practices
- Batch operations when possible
- Use service accounts for automation
- Implement exponential backoff for rate limits
- Cache frequently accessed data
- Use named ranges for important cells

## Anti-Patterns
- Making too many individual cell updates
- Not handling rate limits
- Hardcoding spreadsheet IDs
- Ignoring data types

## Testing
```python
def test_sheets_operations():
    manager = GoogleSheetsManager()

    # Create test data
    test_data = pd.DataFrame({
        'Name': ['Alice', 'Bob', 'Charlie'],
        'Score': [95, 87, 92]
    })

    # Create sheet
    sheet_id = manager.create_spreadsheet('Test Sheet', test_data)
    assert sheet_id is not None

    # Read back
    df = manager.read_data(sheet_id)
    assert len(df) == 3

    print(f"Test passed! Sheet ID: {sheet_id}")
```

## Evolution
- v1.0.0: Initial implementation with core patterns
EOF

# Create Google Docs skill
echo "📝 Creating Google Docs skill..."
cat > skills/documents/google-docs.md << 'EOF'
# Google Docs Automation Skill v1.0.0

## Purpose
Create and manipulate Google Docs programmatically

## Activation
- Keywords: document, doc, gdoc, writing, report, text
- Use when: Creating documents, reports, or written content

## Setup
```bash
pip install --upgrade google-auth google-auth-oauthlib google-auth-httplib2
pip install --upgrade google-api-python-client
pip install markdown2 python-docx
```

## Core Patterns

### Document Creation
```python
from google.oauth2 import service_account
from googleapiclient.discovery import build
import os

class GoogleDocsManager:
    def __init__(self):
        self.service = self.get_docs_service()
        self.drive_service = self.get_drive_service()

    def get_docs_service(self):
        SCOPES = ['https://www.googleapis.com/auth/documents']
        creds_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
        creds = service_account.Credentials.from_service_account_file(
            creds_file, scopes=SCOPES)
        return build('docs', 'v1', credentials=creds)

    def get_drive_service(self):
        SCOPES = ['https://www.googleapis.com/auth/drive']
        creds_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
        creds = service_account.Credentials.from_service_account_file(
            creds_file, scopes=SCOPES)
        return build('drive', 'v3', credentials=creds)

    def create_document(self, title):
        """Create a new Google Doc"""
        doc = self.service.documents().create(body={'title': title}).execute()
        return doc['documentId']

    def insert_text(self, doc_id, text, index=1):
        """Insert text at specific index"""
        requests = [{
            'insertText': {
                'location': {'index': index},
                'text': text
            }
        }]

        self.service.documents().batchUpdate(
            documentId=doc_id,
            body={'requests': requests}
        ).execute()

    def apply_formatting(self, doc_id, start_index, end_index, formatting):
        """Apply formatting to text range"""
        requests = [{
            'updateTextStyle': {
                'range': {
                    'startIndex': start_index,
                    'endIndex': end_index
                },
                'textStyle': formatting,
                'fields': ','.join(formatting.keys())
            }
        }]

        self.service.documents().batchUpdate(
            documentId=doc_id,
            body={'requests': requests}
        ).execute()
```

### Markdown to Google Docs
```python
import markdown2
import re

def markdown_to_google_doc(markdown_text, title):
    """Convert Markdown to formatted Google Doc"""
    manager = GoogleDocsManager()
    doc_id = manager.create_document(title)

    # Parse markdown to get structured content
    lines = markdown_text.split('\n')
    requests = []
    current_index = 1

    for line in lines:
        if line.startswith('# '):
            # H1 heading
            text = line[2:] + '\n'
            requests.extend([
                {
                    'insertText': {
                        'location': {'index': current_index},
                        'text': text
                    }
                },
                {
                    'updateParagraphStyle': {
                        'range': {
                            'startIndex': current_index,
                            'endIndex': current_index + len(text)
                        },
                        'paragraphStyle': {
                            'namedStyleType': 'HEADING_1'
                        },
                        'fields': 'namedStyleType'
                    }
                }
            ])
            current_index += len(text)

        elif line.startswith('## '):
            # H2 heading
            text = line[3:] + '\n'
            requests.extend([
                {
                    'insertText': {
                        'location': {'index': current_index},
                        'text': text
                    }
                },
                {
                    'updateParagraphStyle': {
                        'range': {
                            'startIndex': current_index,
                            'endIndex': current_index + len(text)
                        },
                        'paragraphStyle': {
                            'namedStyleType': 'HEADING_2'
                        },
                        'fields': 'namedStyleType'
                    }
                }
            ])
            current_index += len(text)

        elif line.startswith('- ') or line.startswith('* '):
            # Bullet point
            text = '• ' + line[2:] + '\n'
            requests.append({
                'insertText': {
                    'location': {'index': current_index},
                    'text': text
                }
            })
            current_index += len(text)

        else:
            # Regular paragraph
            text = line + '\n'
            requests.append({
                'insertText': {
                    'location': {'index': current_index},
                    'text': text
                }
            })
            current_index += len(text)

    # Execute all requests
    if requests:
        manager.service.documents().batchUpdate(
            documentId=doc_id,
            body={'requests': requests}
        ).execute()

    return doc_id
```

### Template-Based Document Generation
```python
def generate_from_template(template_id, replacements, new_title):
    """Generate document from template with replacements"""
    manager = GoogleDocsManager()

    # Copy template
    copy = manager.drive_service.files().copy(
        fileId=template_id,
        body={'name': new_title}
    ).execute()

    doc_id = copy['id']

    # Perform replacements
    requests = []
    for placeholder, value in replacements.items():
        requests.append({
            'replaceAllText': {
                'containsText': {
                    'text': '{{' + placeholder + '}}',
                    'matchCase': False
                },
                'replaceText': str(value)
            }
        })

    manager.service.documents().batchUpdate(
        documentId=doc_id,
        body={'requests': requests}
    ).execute()

    return doc_id
```

### Report Generation Pattern
```python
from datetime import datetime

def generate_report(data):
    """Generate formatted report from data"""
    manager = GoogleDocsManager()

    title = f"{data['type']} Report - {datetime.now().strftime('%Y-%m-%d')}"
    doc_id = manager.create_document(title)

    # Build document content
    requests = []
    index = 1

    # Title
    title_text = f"{data['title']}\n\n"
    requests.append({
        'insertText': {
            'location': {'index': index},
            'text': title_text
        }
    })
    requests.append({
        'updateParagraphStyle': {
            'range': {'startIndex': index, 'endIndex': index + len(data['title'])},
            'paragraphStyle': {'namedStyleType': 'TITLE'},
            'fields': 'namedStyleType'
        }
    })
    index += len(title_text)

    # Executive Summary
    if 'summary' in data:
        summary_text = f"Executive Summary\n\n{data['summary']}\n\n"
        requests.append({
            'insertText': {
                'location': {'index': index},
                'text': summary_text
            }
        })
        requests.append({
            'updateParagraphStyle': {
                'range': {'startIndex': index, 'endIndex': index + 17},
                'paragraphStyle': {'namedStyleType': 'HEADING_1'},
                'fields': 'namedStyleType'
            }
        })
        index += len(summary_text)

    # Sections
    for section in data.get('sections', []):
        section_text = f"{section['title']}\n\n{section['content']}\n\n"
        requests.append({
            'insertText': {
                'location': {'index': index},
                'text': section_text
            }
        })
        requests.append({
            'updateParagraphStyle': {
                'range': {'startIndex': index, 'endIndex': index + len(section['title'])},
                'paragraphStyle': {'namedStyleType': 'HEADING_2'},
                'fields': 'namedStyleType'
            }
        })
        index += len(section_text)

    # Execute all formatting
    manager.service.documents().batchUpdate(
        documentId=doc_id,
        body={'requests': requests}
    ).execute()

    return doc_id
```

## Best Practices
- Batch update requests
- Use named styles for consistency
- Implement proper error handling
- Cache template IDs
- Use Drive API for file operations

## Anti-Patterns
- Making individual character updates
- Ignoring rate limits
- Not validating indices
- Hardcoding document IDs

## Testing
```python
def test_document_creation():
    manager = GoogleDocsManager()

    # Create document
    doc_id = manager.create_document("Test Document")
    assert doc_id is not None

    # Add content
    manager.insert_text(doc_id, "Hello, World!")

    print(f"Test passed! Document ID: {doc_id}")
```

## Evolution
- v1.0.0: Initial implementation with core patterns
EOF

# Create Google Workspace integration skill
echo "📝 Creating Google Workspace integration skill..."
cat > skills/integrations/google-workspace.md << 'EOF'
# Google Workspace Integration Skill v1.0.0

## Purpose
Integrate Claude Code with Google Workspace (Drive, Docs, Sheets, Slides)

## Setup Instructions

### 1. Enable Google APIs
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create new project or select existing
3. Enable these APIs:
   - Google Drive API
   - Google Docs API
   - Google Sheets API
   - Google Slides API

### 2. Create Service Account
1. IAM & Admin → Service Accounts → Create
2. Grant roles:
   - Editor (for full access)
   - Or specific roles for limited access
3. Create key → JSON → Download
4. Save as: `~/.claude-code/credentials/google-service-account.json`

### 3. Set Environment Variable
```bash
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.claude-code/credentials/google-service-account.json"
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.claude-code/credentials/google-service-account.json"' >> ~/.bashrc
```

### 4. Share Resources with Service Account
- Copy service account email from JSON file
- Share Google Drive folders/files with this email
- Grant appropriate permissions (Viewer/Editor)

## Authentication Pattern
```python
import os
from google.oauth2 import service_account
from googleapiclient.discovery import build

class GoogleWorkspace:
    def __init__(self):
        self.creds = self._get_credentials()
        self.drive = build('drive', 'v3', credentials=self.creds)
        self.docs = build('docs', 'v1', credentials=self.creds)
        self.sheets = build('sheets', 'v4', credentials=self.creds)
        self.slides = build('slides', 'v1', credentials=self.creds)

    def _get_credentials(self):
        SCOPES = [
            'https://www.googleapis.com/auth/drive',
            'https://www.googleapis.com/auth/documents',
            'https://www.googleapis.com/auth/spreadsheets',
            'https://www.googleapis.com/auth/presentations'
        ]

        creds_file = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
        if not creds_file:
            raise ValueError("GOOGLE_APPLICATION_CREDENTIALS not set")

        return service_account.Credentials.from_service_account_file(
            creds_file, scopes=SCOPES)
```

## Common Patterns

### List Files in Drive
```python
def list_team_files(folder_id=None):
    workspace = GoogleWorkspace()

    query = f"'{folder_id}' in parents" if folder_id else ""

    results = workspace.drive.files().list(
        q=query,
        pageSize=100,
        fields="files(id, name, mimeType, modifiedTime)"
    ).execute()

    return results.get('files', [])
```

### Create Folder Structure
```python
def create_project_folders(project_name):
    workspace = GoogleWorkspace()

    # Create main project folder
    project_folder = workspace.drive.files().create(
        body={
            'name': project_name,
            'mimeType': 'application/vnd.google-apps.folder'
        },
        fields='id'
    ).execute()

    project_id = project_folder['id']

    # Create subfolders
    subfolders = ['Documents', 'Spreadsheets', 'Presentations', 'Resources']

    for folder_name in subfolders:
        workspace.drive.files().create(
            body={
                'name': folder_name,
                'mimeType': 'application/vnd.google-apps.folder',
                'parents': [project_id]
            }
        ).execute()

    return project_id
```

### Cross-Service Integration
```python
def create_project_dashboard(project_data):
    """Create dashboard with Doc, Sheet, and Slides"""
    workspace = GoogleWorkspace()

    # Create spreadsheet with data
    sheet = workspace.sheets.spreadsheets().create(
        body={'properties': {'title': f"{project_data['name']} - Data"}}
    ).execute()
    sheet_id = sheet['spreadsheetId']

    # Populate with data
    workspace.sheets.spreadsheets().values().update(
        spreadsheetId=sheet_id,
        range='A1',
        valueInputOption='RAW',
        body={'values': project_data['metrics']}
    ).execute()

    # Create document with summary
    doc = workspace.docs.documents().create(
        body={'title': f"{project_data['name']} - Summary"}
    ).execute()
    doc_id = doc['documentId']

    # Create presentation
    presentation = workspace.slides.presentations().create(
        body={'title': f"{project_data['name']} - Overview"}
    ).execute()
    pres_id = presentation['presentationId']

    # Move all to project folder
    folder_id = create_project_folders(project_data['name'])

    for file_id in [sheet_id, doc_id, pres_id]:
        workspace.drive.files().update(
            fileId=file_id,
            addParents=folder_id,
            removeParents='root',
            fields='id, parents'
        ).execute()

    return {
        'folder_id': folder_id,
        'sheet_id': sheet_id,
        'doc_id': doc_id,
        'presentation_id': pres_id
    }
```

## Team Collaboration Patterns

### Shared Templates
```python
TEAM_TEMPLATES = {
    'quarterly_report': '1abc...', # Template Doc ID
    'budget_sheet': '2def...',     # Template Sheet ID
    'sales_deck': '3ghi...'        # Template Slides ID
}

def create_from_team_template(template_type, new_name):
    workspace = GoogleWorkspace()

    template_id = TEAM_TEMPLATES.get(template_type)
    if not template_id:
        raise ValueError(f"Unknown template: {template_type}")

    # Copy template
    copy = workspace.drive.files().copy(
        fileId=template_id,
        body={'name': new_name}
    ).execute()

    return copy['id']
```

### Permission Management
```python
def share_with_team(file_id, email_list, role='reader'):
    workspace = GoogleWorkspace()

    for email in email_list:
        workspace.drive.permissions().create(
            fileId=file_id,
            body={
                'type': 'user',
                'role': role,
                'emailAddress': email
            },
            sendNotificationEmail=True
        ).execute()
```

## MCP Integration
Configure in `~/.claude-code/mcp-config.json`:
```json
{
  "mcpServers": {
    "google-workspace": {
      "command": "python",
      "args": ["-m", "mcp_google_workspace"],
      "env": {
        "GOOGLE_APPLICATION_CREDENTIALS": "${GOOGLE_APPLICATION_CREDENTIALS}"
      }
    }
  }
}
```

## Evolution
- v1.0.0: Initial Google Workspace integration patterns
EOF

# Create MCP setup script for Google Workspace
echo "🔧 Creating Google Workspace MCP setup..."
cat > mcp-servers/setup-google-workspace.sh << 'EOF'
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
EOF
chmod +x mcp-servers/setup-google-workspace.sh

# Create team setup script
echo "👥 Creating team onboarding script..."
cat > team-setup/onboard-team-member.sh << 'EOF'
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
EOF
chmod +x team-setup/onboard-team-member.sh

# Update main orchestrator to include document skills
echo "🔄 Updating orchestrator..."
cat >> orchestrator/main.md << 'EOF'

## Document Creation Skills
- documents/powerpoint - PowerPoint presentations
- documents/google-docs - Google Docs creation
- documents/google-sheets - Spreadsheet automation
- documents/google-slides - Google Slides
- documents/reports - Report generation

## Integration Skills
- integrations/google-workspace - Google Workspace integration

## Skill Loading for Documents
When task involves:
- "presentation", "slides", "deck" → load documents/powerpoint
- "document", "doc", "write" → load documents/google-docs
- "spreadsheet", "excel", "data" → load documents/google-sheets
- "report" → load documents/reports + relevant document skills
EOF

# Create README for document skills
echo "📚 Creating documentation..."
cat > skills/documents/README.md << 'EOF'
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
EOF

# Commit changes
echo "💾 Committing changes..."
git add -A
git commit -m "feat: Add document creation and Google Workspace skills

- Added PowerPoint, Google Docs, Sheets skills
- Google Workspace MCP integration
- Team onboarding scripts
- Document templates and patterns"

git push origin main

echo ""
echo "✅ Document skills successfully added!"
echo ""
echo "Next steps:"
echo "1. Run: ./mcp-servers/setup-google-workspace.sh"
echo "2. Share Google Drive folders with service account"
echo "3. Team members run: ./team-setup/onboard-team-member.sh"
echo ""
echo "Usage examples:"
echo "  claude-code --skill documents/powerpoint 'Create investor deck'"
echo "  claude-code --skill documents/google-sheets 'Analyze Q4 metrics'"
echo "  claude-workspace create-doc 'Project proposal'"