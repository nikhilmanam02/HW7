# Converting Documentation to Word Format

## Method 1: Using Pandoc (Recommended)

Pandoc is a universal document converter that can convert Markdown to Word format.

### Installation
```bash
sudo apt-get update
sudo apt-get install pandoc
```

### Conversion
```bash
cd /home/nikhil/HW7

# Convert submission document
pandoc HW7_SUBMISSION.md -o HW7_SUBMISSION.docx

# Convert step-by-step guide
pandoc STEP_BY_STEP_GUIDE.md -o STEP_BY_STEP_GUIDE.docx

# Convert README
pandoc README.md -o README.docx
```

### Advanced Conversion with Formatting
```bash
pandoc HW7_SUBMISSION.md \
    -o HW7_SUBMISSION.docx \
    --reference-doc=/path/to/template.docx \
    --toc \
    --number-sections
```

## Method 2: Using Online Converters

### Option A: CloudConvert
1. Visit: https://cloudconvert.com/md-to-docx
2. Upload `HW7_SUBMISSION.md`
3. Download converted `.docx` file

### Option B: Dillinger
1. Visit: https://dillinger.io/
2. Import `HW7_SUBMISSION.md`
3. Export as Word document

## Method 3: Using Markdown Editors

### Typora (Paid)
1. Open `HW7_SUBMISSION.md` in Typora
2. File → Export → Word (.docx)

### VS Code with Extension
1. Install "Markdown PDF" extension in VS Code
2. Open `HW7_SUBMISSION.md`
3. Right-click → "Markdown PDF: Export (docx)"

### Mark Text (Free)
1. Open `HW7_SUBMISSION.md` in Mark Text
2. File → Export → Word Document

## Method 4: Manual Copy-Paste

1. Open `HW7_SUBMISSION.md` in a text editor
2. Open Microsoft Word or Google Docs
3. Copy content and paste
4. Format headers, code blocks, and tables
5. Add screenshots
6. Save as .docx

## Adding Screenshots

After converting, add screenshots to your Word document:

1. **Certificate Details Screenshot**
   - Run: `openssl x509 -in pki-example-1/certs/server.crt -text -noout`
   - Take screenshot of terminal output

2. **Browser HTTPS Page Screenshot**
   - Navigate to: https://localhost:8443
   - Take screenshot of the page

3. **Certificate Chain in Browser Screenshot**
   - Click padlock icon in browser
   - View certificate details
   - Take screenshot showing the chain

4. **Command Verification Screenshots**
   - Screenshot of certificate verification command
   - Screenshot of Tomcat startup logs

## Formatting Tips

### Headers
- Use Word's built-in heading styles (Heading 1, Heading 2, etc.)

### Code Blocks
- Use Word's "Code" style or Courier New font
- For better formatting, use tables or text boxes

### Tables
- Recreate tables from Markdown in Word's table format
- Use Word's table styles for better appearance

### Lists
- Use Word's bullet/numbered list features

## Final Checklist

- [ ] All sections converted
- [ ] Headers properly formatted
- [ ] Code blocks preserved
- [ ] Tables formatted correctly
- [ ] Screenshots added
- [ ] GitHub repository URL added
- [ ] Date and name added
- [ ] Spell-checked
- [ ] Page numbers added
- [ ] Table of contents generated (optional)

## File to Submit

Submit `HW7_SUBMISSION.docx` containing:
1. Executive Summary
2. Introduction
3. Prerequisites
4. PKI Implementation
5. Tomcat Configuration
6. Testing and Verification
7. Results
8. References
9. GitHub Repository link
10. Screenshots

