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
