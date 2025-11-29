# Next Steps - Complete Your Submission

## Step 1: Convert Documentation to Word Format

You have several options to convert `HW7_SUBMISSION.md` to Word format:

### Option A: Install Pandoc and Convert (Recommended)

```bash
cd /home/nikhil/HW7

# Install pandoc
sudo apt-get install pandoc

# Convert to Word
pandoc HW7_SUBMISSION.md -o HW7_SUBMISSION.docx
```

### Option B: Use Online Converter

1. Open `HW7_SUBMISSION.md` in a text editor
2. Copy all the content
3. Go to: https://cloudconvert.com/md-to-docx
4. Upload the file or paste the content
5. Download the converted `.docx` file

### Option C: Manual Copy-Paste

1. Open `HW7_SUBMISSION.md` in a text editor (VS Code, nano, etc.)
2. Select all and copy the content
3. Open Microsoft Word or Google Docs
4. Paste the content
5. Format headers, code blocks, and tables manually
6. Save as `.docx`

---

## Step 2: Open the Word Document

Open `HW7_SUBMISSION.docx` (or the converted file) in Microsoft Word or LibreOffice Writer.

---

## Step 3: Add Your Information

In the Word document, find and replace:
- `[Your Name]` → Your actual name
- `[Submission Date]` → Today's date
- `[Course Name]` → Your course name (if applicable)

---

## Step 4: Add Screenshots

Insert your screenshots in the appropriate sections:

### Section 5.2: HTTPS Connection Testing
Add screenshots of:
- Browser showing HTTPS page (https://localhost:8443)
- Certificate details in browser (click padlock icon)

### Section 5.1: Certificate Verification
Add screenshots of:
- Certificate details output (from `openssl x509 -in certs/server.crt -text -noout`)
- Certificate chain verification output (showing "OK")
- JKS keystore verification output

### Section 11: Screenshots (at the end)
Add all your screenshots here with captions:
1. Certificate details (Root CA, Signing CA, Server)
2. Certificate chain verification
3. Browser HTTPS page
4. Certificate chain in browser
5. Command-line verification outputs

**How to insert screenshots in Word:**
1. Place cursor where you want the image
2. Go to: Insert → Pictures → This Device (or Picture from File)
3. Select your screenshot file
4. Add a caption below: Right-click image → Insert Caption

---

## Step 5: Add GitHub Repository (Optional but Recommended)

### If you want to create a GitHub repository:

```bash
cd /home/nikhil/HW7

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "HW7: PKI Infrastructure and TLS Certificate Setup

- Created Root CA, Signing CA, and TLS certificate
- Configured certificate for Apache Tomcat
- Complete documentation included"

# Create a repository on GitHub.com, then:
# git remote add origin https://github.com/YOUR_USERNAME/HW7.git
# git push -u origin main
```

### Update the Word document:

Find this section in the document:
```
## 9. GitHub Repository

**Repository URL:** [Your GitHub repository URL]
```

Replace `[Your GitHub repository URL]` with your actual GitHub repository URL.

---

## Step 6: Review and Finalize

1. **Review all sections:**
   - Check that all placeholders are replaced
   - Verify all sections are present
   - Ensure code blocks are formatted properly
   - Check tables are readable

2. **Add page numbers:**
   - Insert → Page Number → Choose a style

3. **Create Table of Contents (optional):**
   - References → Table of Contents → Automatic Table 1

4. **Spell-check:**
   - Review → Spelling & Grammar

5. **Save the document:**
   - File → Save As → `HW7_SUBMISSION_FINAL.docx`

---

## Step 7: Final Checklist

Before submitting, verify:

- [ ] Your name and date are added
- [ ] All screenshots are inserted with captions
- [ ] GitHub repository URL is added (if applicable)
- [ ] Certificate details are accurate
- [ ] All sections are complete
- [ ] Code blocks and commands are readable
- [ ] Tables are properly formatted
- [ ] Page numbers are added
- [ ] Document is spell-checked
- [ ] File is saved as `.docx` format

---

## Step 8: Submit!

Submit your `HW7_SUBMISSION_FINAL.docx` file as required by your assignment instructions.

---

## Quick Commands Reference

If you need to verify anything:

```bash
cd /home/nikhil/HW7

# View certificate details (for screenshots)
openssl x509 -in pki-example-1/certs/server.crt -text -noout

# Verify certificate chain
openssl verify -CAfile pki-example-1/ca/root-ca.crt \
    -untrusted pki-example-1/ca/signing-ca.crt \
    pki-example-1/certs/server.crt

# View JKS keystore contents
keytool -list -v -keystore pki-example-1/certs/server.jks -storepass changeit
```

---

**You're almost done! Just convert to Word, add your info and screenshots, and submit! 🎉**

