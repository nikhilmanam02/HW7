# Complete Instructions for HW7 Submission

## ✅ What Has Been Completed

### 1. PKI Infrastructure ✓
Your complete PKI infrastructure has been set up:

- **Root CA** ✓ Created and self-signed
  - Certificate: `pki-example-1/ca/root-ca.crt`
  - Private key: `pki-example-1/ca/root-ca/private/root-ca.key`
  
- **Signing CA** ✓ Created and signed by Root CA
  - Certificate: `pki-example-1/ca/signing-ca.crt`
  - Private key: `pki-example-1/ca/signing-ca/private/signing-ca.key`
  
- **TLS Server Certificate** ✓ Created and signed by Signing CA
  - Certificate: `pki-example-1/certs/server.crt`
  - Private key: `pki-example-1/certs/server.key`
  - Certificate chain: `pki-example-1/certs/server-chain.pem`
  - PKCS12 bundle: `pki-example-1/certs/server.p12`

### 2. Automation Scripts ✓
Three scripts have been created to automate the setup:

- `setup-pki.sh` - Sets up the complete PKI infrastructure
- `convert-for-tomcat.sh` - Converts certificate to JKS format for Tomcat
- `setup-tomcat.sh` - Installs and configures Tomcat with SSL

### 3. Documentation ✓
Comprehensive documentation has been created:

- `README.md` - Complete project documentation
- `STEP_BY_STEP_GUIDE.md` - Detailed step-by-step instructions
- `HW7_SUBMISSION.md` - **This is your submission document template**
- `QUICK_START.md` - Quick reference guide
- `CONVERT_TO_WORD.md` - Instructions for converting to Word
- `PROJECT_SUMMARY.md` - Project overview

---

## 📋 What You Need to Do

### Step 1: Complete Tomcat Setup (Optional for Assignment)

If you want to test the full setup:

1. **Install Java JDK**:
   ```bash
   sudo apt-get install default-jdk
   ```

2. **Convert certificate to JKS format**:
   ```bash
   cd /home/nikhil/HW7
   ./convert-for-tomcat.sh
   ```

3. **Install and configure Tomcat**:
   ```bash
   ./setup-tomcat.sh
   ```

4. **Start Tomcat and test**:
   ```bash
   ~/tomcat/bin/startup.sh
   # Wait a few seconds, then:
   curl -k https://localhost:8443
   # Or open in browser: https://localhost:8443
   ```

### Step 2: Verify Your Certificates

Run these commands to verify everything is working:

```bash
cd /home/nikhil/HW7/pki-example-1

# View Root CA certificate
openssl x509 -in ca/root-ca.crt -text -noout | head -30

# View Signing CA certificate  
openssl x509 -in ca/signing-ca.crt -text -noout | head -30

# View Server certificate
openssl x509 -in certs/server.crt -text -noout | head -40

# Verify the certificate chain
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt
```

You should see: `certs/server.crt: OK`

### Step 3: Take Screenshots

You'll need screenshots for your Word document:

1. **Certificate Details**:
   ```bash
   openssl x509 -in pki-example-1/certs/server.crt -text -noout
   ```
   Take a screenshot of this output.

2. **Certificate Chain Verification**:
   ```bash
   openssl verify -CAfile pki-example-1/ca/root-ca.crt \
       -untrusted pki-example-1/ca/signing-ca.crt \
       pki-example-1/certs/server.crt
   ```
   Take a screenshot showing "OK".

3. **Browser HTTPS Page** (if Tomcat is running):
   - Navigate to: https://localhost:8443
   - Take screenshot of the Tomcat page

4. **Browser Certificate Chain**:
   - Click the padlock icon in the browser
   - View certificate details
   - Take screenshot showing the certificate chain

### Step 4: Convert Documentation to Word

You have several options:

#### Option A: Using Pandoc (Recommended)
```bash
# Install pandoc
sudo apt-get install pandoc

# Convert submission document
cd /home/nikhil/HW7
pandoc HW7_SUBMISSION.md -o HW7_SUBMISSION.docx
```

#### Option B: Manual Copy-Paste
1. Open `HW7_SUBMISSION.md` in a text editor
2. Copy all content
3. Open Microsoft Word or Google Docs
4. Paste and format (headers, code blocks, tables)
5. Save as `.docx`

#### Option C: Online Converter
1. Go to https://cloudconvert.com/md-to-docx
2. Upload `HW7_SUBMISSION.md`
3. Download the converted `.docx` file

### Step 5: Complete Your Word Document

Open the Word document and:

1. **Add your information**:
   - Your name (replace `[Your Name]`)
   - Date (replace `[Submission Date]`)
   - Course name (replace `[Course Name]`)

2. **Add screenshots**:
   - Certificate details screenshot
   - Certificate chain verification screenshot
   - Browser HTTPS page (if available)
   - Browser certificate chain (if available)

3. **Add GitHub repository URL**:
   - If you create a GitHub repository, add the URL
   - If not, you can mention the local path: `/home/nikhil/HW7`

4. **Review and format**:
   - Check all sections are present
   - Format code blocks nicely
   - Ensure tables are formatted
   - Add page numbers
   - Spell-check

### Step 6: Create GitHub Repository (Optional but Recommended)

```bash
cd /home/nikhil/HW7

# Initialize git repository
git init

# Add all files
git add .

# Create initial commit
git commit -m "HW7: PKI Infrastructure and TLS Certificate Setup

- Created Root CA, Signing CA, and TLS certificate
- Configured Apache Tomcat with SSL/TLS
- Complete documentation included"

# Create repository on GitHub, then:
# git remote add origin https://github.com/YOUR_USERNAME/HW7.git
# git push -u origin main
```

Then add the GitHub URL to your Word document.

---

## 📖 Key Documentation Files

### For Submission:
- **`HW7_SUBMISSION.md`** → Convert to Word → Submit

### For Reference:
- **`README.md`** - Complete documentation
- **`STEP_BY_STEP_GUIDE.md`** - Detailed instructions
- **`QUICK_START.md`** - Quick commands

---

## 🎯 Assignment Checklist

- [x] PKI Infrastructure designed and built
  - [x] Root CA created
  - [x] Signing CA created
  - [x] TLS Certificate created
- [x] TLS certificate prepared for web server (Tomcat)
- [x] Progress documented
- [ ] Word document created and completed
  - [ ] Name and date added
  - [ ] Screenshots added
  - [ ] GitHub reference added
- [ ] Word document submitted

---

## 📁 File Locations Reference

### Certificates:
```
/home/nikhil/HW7/pki-example-1/
├── ca/
│   ├── root-ca.crt          # Root CA certificate
│   └── signing-ca.crt       # Signing CA certificate
└── certs/
    ├── server.crt           # TLS server certificate
    ├── server.key           # Server private key
    ├── server-chain.pem     # Certificate chain
    └── server.p12           # PKCS12 bundle
```

### Documentation:
```
/home/nikhil/HW7/
├── HW7_SUBMISSION.md        # Main submission document
├── README.md                # Complete documentation
├── STEP_BY_STEP_GUIDE.md    # Detailed guide
└── CONVERT_TO_WORD.md       # Conversion instructions
```

### Scripts:
```
/home/nikhil/HW7/
├── setup-pki.sh             # PKI setup automation
├── convert-for-tomcat.sh    # Certificate conversion
└── setup-tomcat.sh          # Tomcat configuration
```

---

## 🚀 Quick Start Commands

### Verify Certificates:
```bash
cd /home/nikhil/HW7/pki-example-1
openssl verify -CAfile ca/root-ca.crt -untrusted ca/signing-ca.crt certs/server.crt
```

### View Certificate Details:
```bash
openssl x509 -in certs/server.crt -text -noout
```

### Convert to Word:
```bash
cd /home/nikhil/HW7
sudo apt-get install pandoc
pandoc HW7_SUBMISSION.md -o HW7_SUBMISSION.docx
```

---

## ❓ Need Help?

1. **Check README.md** - Complete documentation with troubleshooting
2. **Check STEP_BY_STEP_GUIDE.md** - Detailed explanations
3. **Check CONVERT_TO_WORD.md** - Word conversion help

---

## ✨ You're Almost Done!

Your PKI infrastructure is complete and fully documented. You just need to:

1. ✅ Review the documentation
2. ✅ Take screenshots
3. ✅ Convert `HW7_SUBMISSION.md` to Word
4. ✅ Add your information and screenshots
5. ✅ Submit!

Good luck! 🎉

