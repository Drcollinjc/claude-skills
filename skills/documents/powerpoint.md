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
