#!/usr/bin/env python3
"""Convert PROJECT_EXPLANATION.md to a professionally styled PDF."""

import markdown
from weasyprint import HTML

# Read the markdown
with open('/Users/mac/StudioProjects/mundial_manager/PROJECT_EXPLANATION.md', 'r') as f:
    md_content = f.read()

# Convert markdown to HTML
html_body = markdown.markdown(
    md_content,
    extensions=['tables', 'fenced_code', 'codehilite', 'toc', 'nl2br'],
    extension_configs={
        'codehilite': {'css_class': 'code'},
    }
)

# Full HTML with professional styling
html_full = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
@page {{
    size: A4;
    margin: 2cm 2.2cm;
    @top-center {{
        content: "Mundial Manager - Code Explanation Guide";
        font-size: 8pt;
        color: #888;
        font-family: 'Helvetica Neue', Arial, sans-serif;
    }}
    @bottom-center {{
        content: "Page " counter(page) " of " counter(pages);
        font-size: 8pt;
        color: #888;
        font-family: 'Helvetica Neue', Arial, sans-serif;
    }}
}}

@page :first {{
    @top-center {{ content: none; }}
}}

body {{
    font-family: 'Helvetica Neue', Arial, sans-serif;
    font-size: 10.5pt;
    line-height: 1.6;
    color: #1a1a2e;
    max-width: 100%;
}}

/* Title */
h1 {{
    font-size: 26pt;
    color: #0F253D;
    border-bottom: 3px solid #27506D;
    padding-bottom: 12px;
    margin-top: 0;
    margin-bottom: 6px;
    page-break-before: avoid;
}}

h1 + p {{
    font-size: 11pt;
    color: #6C8BA6;
    font-style: italic;
    margin-top: 0;
}}

/* Section headers */
h2 {{
    font-size: 17pt;
    color: #27506D;
    border-bottom: 2px solid #6FAEC9;
    padding-bottom: 6px;
    margin-top: 32px;
    page-break-after: avoid;
}}

h3 {{
    font-size: 13pt;
    color: #2F5A7D;
    margin-top: 22px;
    page-break-after: avoid;
}}

h4 {{
    font-size: 11pt;
    color: #27506D;
    font-weight: 700;
    margin-top: 16px;
}}

/* Paragraphs */
p {{
    margin: 8px 0;
    text-align: justify;
}}

/* Links */
a {{
    color: #007AFF;
    text-decoration: none;
}}

/* Lists */
ul, ol {{
    margin: 6px 0;
    padding-left: 24px;
}}

li {{
    margin: 3px 0;
}}

/* Tables */
table {{
    width: 100%;
    border-collapse: collapse;
    margin: 14px 0;
    font-size: 9.5pt;
    page-break-inside: avoid;
}}

thead {{
    background: #0F253D;
    color: white;
}}

th {{
    padding: 8px 10px;
    text-align: left;
    font-weight: 600;
    font-size: 9pt;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}}

td {{
    padding: 7px 10px;
    border-bottom: 1px solid #e0e0e0;
}}

tr:nth-child(even) {{
    background-color: #f5f7fa;
}}

/* Code blocks */
pre {{
    background: #0D1B2A;
    color: #E0E0E0;
    padding: 14px 16px;
    border-radius: 8px;
    font-size: 8.5pt;
    line-height: 1.5;
    overflow-x: auto;
    margin: 12px 0;
    page-break-inside: avoid;
    border-left: 4px solid #6FAEC9;
}}

code {{
    font-family: 'SF Mono', 'Fira Code', 'Consolas', monospace;
    font-size: 8.5pt;
}}

p code, li code, td code {{
    background: #EEF2F7;
    color: #c7254e;
    padding: 2px 5px;
    border-radius: 3px;
    font-size: 9pt;
}}

pre code {{
    background: none;
    color: inherit;
    padding: 0;
}}

/* Blockquotes */
blockquote {{
    border-left: 4px solid #FF9500;
    background: #FFF8E7;
    padding: 10px 16px;
    margin: 12px 0;
    font-style: italic;
    color: #5a4a00;
}}

/* Horizontal rules */
hr {{
    border: none;
    border-top: 2px solid #e0e0e0;
    margin: 24px 0;
}}

/* Strong / Bold */
strong {{
    color: #0F253D;
}}

/* Cover-like first section */
h1:first-of-type {{
    font-size: 30pt;
    text-align: center;
    border-bottom: none;
    margin-top: 60px;
    margin-bottom: 4px;
}}

/* Table of contents styling */
h2#table-of-contents + ol,
h2#table-of-contents + ul {{
    columns: 2;
    column-gap: 24px;
    font-size: 10pt;
}}

/* Emoji-like indicators */
.emoji {{
    font-size: 12pt;
}}

/* Keep sections together */
h2, h3, h4 {{
    page-break-after: avoid;
}}

h2 + *, h3 + *, h4 + * {{
    page-break-before: avoid;
}}

/* Special box for important notes */
p:has(strong:first-child) {{
    page-break-inside: avoid;
}}
</style>
</head>
<body>
{html_body}
</body>
</html>"""

# Write HTML for reference
html_path = '/Users/mac/StudioProjects/mundial_manager/PROJECT_EXPLANATION.html'
with open(html_path, 'w') as f:
    f.write(html_full)

# Generate PDF
pdf_path = '/Users/mac/StudioProjects/mundial_manager/PROJECT_EXPLANATION.pdf'
HTML(string=html_full).write_pdf(pdf_path)

print(f"PDF generated: {pdf_path}")
