# Quick Start Guide - PKI and Tomcat Setup

## Prerequisites

```bash
sudo apt-get update
sudo apt-get install openssl default-jdk wget python3
```

## Automated Setup (Recommended)

### Step 1: Run PKI Setup
```bash
cd /home/nikhil/HW7
./setup-pki.sh
```

### Step 2: Convert Certificate for Tomcat
```bash
./convert-for-tomcat.sh
```

### Step 3: Install and Configure Tomcat
```bash
./setup-tomcat.sh
```

### Step 4: Start Tomcat
```bash
~/tomcat/bin/startup.sh
```

### Step 5: Test
```bash
curl -k https://localhost:8443
# Or open in browser: https://localhost:8443
```

## Manual Setup

See `STEP_BY_STEP_GUIDE.md` for detailed manual instructions.

## File Locations

### Certificates
- Root CA: `pki-example-1/ca/root-ca.crt`
- Signing CA: `pki-example-1/ca/signing-ca.crt`
- Server Cert: `pki-example-1/certs/server.crt`
- Server Key: `pki-example-1/certs/server.key`
- JKS Keystore: `pki-example-1/certs/server.jks`

### Tomcat
- Installation: `~/tomcat/`
- Configuration: `~/tomcat/conf/server.xml`
- Logs: `~/tomcat/logs/catalina.out`

## Verification

```bash
# Verify certificate chain
cd pki-example-1
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt

# View certificate details
openssl x509 -in certs/server.crt -text -noout

# Check Tomcat is running
netstat -tulpn | grep 8443
```

## Troubleshooting

### Certificate Issues
- Check keystore password matches in `server.xml`
- Verify keystore file path is absolute
- Check certificate alias is "server"

### Tomcat Issues
- Check logs: `tail -f ~/tomcat/logs/catalina.out`
- Verify Java is installed: `java -version`
- Check port 8443 is not in use: `netstat -tulpn | grep 8443`

## Documentation

- `README.md` - Complete project documentation
- `STEP_BY_STEP_GUIDE.md` - Detailed step-by-step instructions
- `HW7_SUBMISSION.md` - Submission document template

## Convert to Word

### Option 1: Using Pandoc
```bash
sudo apt-get install pandoc
pandoc HW7_SUBMISSION.md -o HW7_SUBMISSION.docx
```

### Option 2: Using Online Tools
1. Copy content from `HW7_SUBMISSION.md`
2. Paste into Google Docs or Microsoft Word Online
3. Save as .docx

### Option 3: Manual Conversion
1. Open `HW7_SUBMISSION.md` in a Markdown editor (VS Code, Typora, etc.)
2. Export to Word format (.docx)
3. Add screenshots and format as needed

