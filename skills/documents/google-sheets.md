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
