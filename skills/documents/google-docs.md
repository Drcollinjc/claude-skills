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
