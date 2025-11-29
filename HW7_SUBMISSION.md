# HW #7 - Security: PKI Infrastructure and TLS Certificate Setup

**Student:** [Your Name]  
**Date:** [Submission Date]  
**Course:** [Course Name]

---

## Executive Summary

This document describes the design and implementation of a complete Public Key Infrastructure (PKI) system consisting of a Root Certificate Authority (CA), Signing CA, and TLS certificate. The TLS certificate is then used to configure Apache Tomcat web server with HTTPS support. The implementation follows industry-standard practices and demonstrates a working PKI hierarchy.

---

## 1. Introduction

### 1.1 Objective

The objective of this project is to:

1. Design and build a PKI infrastructure with:
   - Root CA (self-signed certificate authority)
   - Signing CA (intermediate CA signed by Root CA)
   - TLS certificate (server certificate signed by Signing CA)

2. Install and configure Apache Tomcat web server to use the TLS certificate for HTTPS connections

3. Document the entire process with detailed steps and verification

### 1.2 PKI Architecture Overview

The PKI architecture follows a hierarchical trust model:

```
                    Root CA (Self-Signed)
                           |
                    Signing CA
                           |
                  TLS Server Certificate
```

**Trust Chain:**
- Root CA → Signs Signing CA certificate
- Signing CA → Signs TLS server certificate
- TLS Certificate → Used by web server

This two-tier CA structure provides:
- **Security**: Root CA private key can be kept offline
- **Scalability**: Signing CA can issue multiple certificates
- **Flexibility**: Different policies can be applied at each level

---

## 2. Prerequisites and Environment Setup

### 2.1 System Requirements

- **Operating System**: Linux (Ubuntu/Debian/WSL2)
- **OpenSSL**: Version 1.1.1 or later (for PKI operations)
- **Java JDK**: Version 8 or later (for Tomcat and keytool)
- **Apache Tomcat**: Version 9.0 or later

### 2.2 Software Installation

```bash
# Install OpenSSL
sudo apt-get update
sudo apt-get install openssl

# Install Java JDK
sudo apt-get install default-jdk

# Verify installations
openssl version
java -version
keytool -help
```

### 2.3 Project Structure

```
HW7/
├── pki-example-1/          # PKI configuration repository
│   ├── etc/                # OpenSSL configuration files
│   │   ├── root-ca.conf    # Root CA configuration
│   │   ├── signing-ca.conf # Signing CA configuration
│   │   └── server.conf     # Server certificate configuration
│   ├── ca/                 # Certificate Authority files
│   │   ├── root-ca/        # Root CA directory
│   │   │   ├── private/    # Root CA private key
│   │   │   └── db/         # Root CA database
│   │   ├── signing-ca/     # Signing CA directory
│   │   │   ├── private/    # Signing CA private key
│   │   │   └── db/         # Signing CA database
│   │   ├── root-ca.crt     # Root CA certificate
│   │   └── signing-ca.crt  # Signing CA certificate
│   ├── certs/              # Issued certificates
│   │   ├── server.crt      # TLS server certificate
│   │   ├── server.key      # TLS server private key
│   │   ├── server-chain.pem # Certificate chain
│   │   ├── server.p12      # PKCS12 bundle
│   │   └── server.jks      # Java KeyStore for Tomcat
│   └── crl/                # Certificate Revocation Lists
├── setup-pki.sh            # Automated PKI setup script
├── convert-for-tomcat.sh   # Certificate conversion script
├── setup-tomcat.sh         # Tomcat installation script
├── README.md               # Project documentation
└── STEP_BY_STEP_GUIDE.md   # Detailed step-by-step guide
```

---

## 3. PKI Infrastructure Implementation

### 3.1 Root CA Creation

The Root CA is the foundation of the PKI hierarchy. It is self-signed and serves as the ultimate trust anchor.

#### 3.1.1 Directory Structure

```bash
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private  # Protect private key
```

#### 3.1.2 Database Initialization

```bash
cp /dev/null ca/root-ca/db/root-ca.db
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl
```

**Purpose:**
- `root-ca.db`: Tracks all certificates issued by the Root CA
- `root-ca.crt.srl`: Serial number counter for certificates
- `root-ca.crl.srl`: Serial number counter for CRLs

#### 3.1.3 Generate Root CA Certificate

```bash
# Create certificate request and private key
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key

# Create self-signed certificate
openssl ca -selfsign \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext
```

**Key Properties:**
- **Validity**: 10 years (3652 days)
- **Key Algorithm**: RSA 2048-bit
- **Hash Algorithm**: SHA-256
- **Key Usage**: Certificate Sign, CRL Sign
- **Basic Constraints**: CA:TRUE

**Subject Information:**
```
DC=org
DC=simple
O=Simple Inc
CN=Simple Root CA
```

**Verification:**
```bash
openssl x509 -in ca/root-ca.crt -text -noout
```

**Result:** Root CA certificate created and stored in `ca/root-ca.crt`

### 3.2 Signing CA Creation

The Signing CA is an intermediate CA that issues certificates for end entities. It is signed by the Root CA.

#### 3.2.1 Directory Structure

```bash
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private
```

#### 3.2.2 Database Initialization

```bash
cp /dev/null ca/signing-ca/db/signing-ca.db
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl
```

#### 3.2.3 Generate Signing CA Certificate

```bash
# Create certificate request
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key

# Sign with Root CA (note: using root-ca.conf)
openssl ca \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext
```

**Key Properties:**
- **Validity**: 10 years
- **Signed by**: Root CA
- **Key Usage**: Certificate Sign, CRL Sign
- **Basic Constraints**: CA:TRUE, pathlen:0 (cannot issue CA certificates)

**Subject Information:**
```
DC=org
DC=simple
O=Simple Inc
CN=Simple Signing CA
```

**Verification:**
```bash
openssl x509 -in ca/signing-ca.crt -text -noout
```

**Result:** Signing CA certificate created and signed by Root CA

### 3.3 TLS Server Certificate Creation

The TLS server certificate is used to secure HTTPS connections on the web server.

#### 3.3.1 Generate Certificate Request

```bash
SAN=DNS:localhost,DNS:www.localhost,IP:127.0.0.1 \
openssl req -new \
    -config etc/server.conf \
    -out certs/server.csr \
    -keyout certs/server.key \
    -subj "/DC=org/DC=simple/O=Simple Inc/CN=localhost"
```

**Key Features:**
- **Subject Alternative Names (SAN)**: 
  - DNS:localhost
  - DNS:www.localhost
  - IP:127.0.0.1
- **Private Key**: Unencrypted (for automated services)

#### 3.3.2 Sign Certificate with Signing CA

```bash
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/server.csr \
    -out certs/server.crt \
    -extensions server_ext
```

**Key Properties:**
- **Validity**: 2 years (730 days)
- **Signed by**: Signing CA
- **Key Usage**: Digital Signature, Key Encipherment
- **Extended Key Usage**: Server Authentication, Client Authentication

**Verification:**
```bash
openssl x509 -in certs/server.crt -text -noout
```

**Result:** TLS server certificate created and signed by Signing CA

### 3.4 Certificate Chain Creation

A certificate chain is required for browsers to validate certificates.

```bash
cat ca/signing-ca.crt ca/root-ca.crt > certs/server-chain.pem
```

**Chain Structure:**
```
Server Certificate
    ↓ (issued by)
Signing CA Certificate
    ↓ (issued by)
Root CA Certificate (self-signed)
```

**Verification:**
```bash
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt
```

**Expected Output:** `certs/server.crt: OK`

### 3.5 PKCS12 Bundle Creation

PKCS12 format bundles the certificate, private key, and chain for easy distribution.

```bash
openssl pkcs12 -export \
    -name "server" \
    -in certs/server.crt \
    -inkey certs/server.key \
    -out certs/server.p12 \
    -certfile certs/server-chain.pem \
    -passout pass:changeit
```

**Contents:**
- Server certificate
- Server private key
- Signing CA certificate
- Root CA certificate

---

## 4. Apache Tomcat Configuration

### 4.1 Java KeyStore Conversion

Tomcat requires certificates in Java KeyStore (JKS) format.

```bash
keytool -importkeystore \
    -srckeystore certs/server.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass changeit \
    -destkeystore certs/server.jks \
    -deststoretype JKS \
    -deststorepass changeit \
    -noprompt
```

**Result:** JKS keystore created at `certs/server.jks`

**Verification:**
```bash
keytool -list -v -keystore certs/server.jks -storepass changeit
```

### 4.2 Tomcat Installation

```bash
cd ~
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz
tar -xzf apache-tomcat-9.0.87.tar.gz
mv apache-tomcat-9.0.87 tomcat
rm apache-tomcat-9.0.87.tar.gz
chmod +x ~/tomcat/bin/*.sh
```

### 4.3 SSL/TLS Connector Configuration

Edit `~/tomcat/conf/server.xml` and add/configure the SSL connector:

```xml
<!-- Define an SSL HTTP/1.1 Connector on port 8443 -->
<Connector
    protocol="org.apache.coyote.http11.Http11NioProtocol"
    port="8443"
    maxThreads="200"
    scheme="https"
    secure="true"
    SSLEnabled="true"
    keystoreFile="/home/nikhil/HW7/pki-example-1/certs/server.jks"
    keystorePass="changeit"
    clientAuth="false"
    sslProtocol="TLS"
    keyAlias="server"/>
```

**Configuration Parameters:**
- `port="8443"`: HTTPS listening port
- `keystoreFile`: Absolute path to JKS keystore
- `keystorePass`: Keystore password
- `keyAlias`: Certificate alias in keystore
- `sslProtocol="TLS"`: TLS protocol version

**HTTP Connector Redirect:**
```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### 4.4 Starting Tomcat

```bash
~/tomcat/bin/startup.sh
```

**Verify Startup:**
```bash
tail -f ~/tomcat/logs/catalina.out
```

**Look for:**
```
Starting ProtocolHandler ["http-nio-8443"]
```

---

## 5. Testing and Verification

### 5.1 Certificate Verification

**Verify Certificate Chain:**
```bash
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt
```

**View Certificate Details:**
```bash
openssl x509 -in certs/server.crt -text -noout | grep -A 2 "Subject:\|Issuer:\|Not Before\|Not After"
```

**Output:**
```
Subject: DC = org, DC = simple, O = Simple Inc, CN = localhost
Issuer: DC = org, DC = simple, O = Simple Inc, CN = Simple Signing CA
Not Before: Nov 29 19:26:29 2025 GMT
Not After : Nov 29 19:26:29 2027 GMT
```

### 5.2 HTTPS Connection Testing

#### Using curl:
```bash
curl -k https://localhost:8443
```

#### Using Browser:
1. Navigate to: `https://localhost:8443`
2. Accept security warning (Root CA not in browser trust store)
3. Verify Tomcat default page loads

**Screenshot:** [Include screenshot of HTTPS page]

#### Certificate Details in Browser:
1. Click padlock icon in address bar
2. View certificate details
3. Verify certificate chain:
   - Server Certificate (CN=localhost)
   - Signing CA (CN=Simple Signing CA)
   - Root CA (CN=Simple Root CA)

**Screenshot:** [Include screenshot of certificate chain]

### 5.3 OpenSSL s_client Test

```bash
echo | openssl s_client -connect localhost:8443 -servername localhost 2>&1 | \
    grep -A 5 "Certificate chain"
```

---

## 6. Security Considerations

### 6.1 Private Key Protection

- Private keys stored in `ca/*/private/` with 700 permissions (owner read/write/execute only)
- Root CA private key should be kept offline in production
- Signing CA private key should have restricted access

### 6.2 Certificate Validity

- **Root CA**: 10 years validity
- **Signing CA**: 10 years validity  
- **Server Certificate**: 2 years validity (industry standard)

### 6.3 Password Management

- Default passwords used for demonstration: `changeit`
- **Production**: Use strong, unique passwords
- Store passwords securely (password manager, encrypted storage)

### 6.4 Certificate Revocation

CRLs can be generated to revoke compromised certificates:

```bash
openssl ca -gencrl \
    -config etc/signing-ca.conf \
    -out crl/signing-ca.crl
```

### 6.5 Production Recommendations

1. **Root CA**: Keep offline, use hardware security modules (HSM)
2. **Signing CA**: Implement strict access controls
3. **Certificate Lifecycle**: Implement automated renewal
4. **Monitoring**: Track certificate expiration dates
5. **Auditing**: Log all certificate issuance and revocation

---

## 7. Results and Conclusions

### 7.1 Achievements

✅ Successfully created a complete PKI infrastructure:
- Root CA with self-signed certificate
- Signing CA signed by Root CA
- TLS server certificate signed by Signing CA
- Certificate chain established

✅ Configured Apache Tomcat with SSL/TLS:
- Converted certificate to JKS format
- Configured HTTPS connector
- Verified secure connection

✅ Documentation:
- Comprehensive step-by-step guide
- Automated setup scripts
- Verification procedures

### 7.2 Certificate Summary

| Certificate | Type | Issued By | Validity | Purpose |
|------------|------|-----------|----------|---------|
| Root CA | CA | Self-signed | 10 years | Trust anchor |
| Signing CA | CA | Root CA | 10 years | Intermediate CA |
| Server | End Entity | Signing CA | 2 years | HTTPS/TLS |

### 7.3 Lessons Learned

1. **PKI Hierarchy**: Two-tier CA structure provides security and flexibility
2. **Certificate Chain**: Proper chain establishment is crucial for browser trust
3. **Format Conversion**: Different systems require different certificate formats (PEM, PKCS12, JKS)
4. **Configuration**: Careful configuration of OpenSSL and Tomcat is essential

### 7.4 Future Enhancements

- Implement OCSP (Online Certificate Status Protocol)
- Automated certificate renewal
- Certificate transparency logging
- Multiple server certificates for different domains
- Client certificate authentication

---

## 8. References

### 8.1 Documentation

1. **PKI Tutorial**: https://pki-tutorial.readthedocs.io/en/latest/simple/
   - Source: Stefan H. Holek
   - Description: Comprehensive PKI tutorial using OpenSSL

2. **Apache Tomcat SSL/TLS Configuration**: https://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html
   - Source: Apache Software Foundation
   - Description: Official Tomcat SSL/TLS configuration guide

### 8.2 Tools and Technologies

- **OpenSSL**: Cryptographic toolkit (https://www.openssl.org/)
- **Apache Tomcat**: Java web server (https://tomcat.apache.org/)
- **Java KeyTool**: Certificate management tool (part of JDK)

### 8.3 Standards

- **X.509**: ITU-T standard for public key certificates
- **PKCS#12**: Personal Information Exchange Syntax Standard
- **TLS/SSL**: Transport Layer Security protocols

---

## 9. GitHub Repository

**Repository URL:** [Your GitHub repository URL]

**Repository Structure:**
```
HW7/
├── pki-example-1/          # PKI configuration and certificates
├── setup-pki.sh            # PKI setup automation
├── convert-for-tomcat.sh   # Certificate conversion
├── setup-tomcat.sh         # Tomcat configuration
├── README.md               # Project documentation
├── STEP_BY_STEP_GUIDE.md   # Detailed instructions
└── HW7_SUBMISSION.md       # This document
```

**Commits:**
- Initial PKI setup
- Certificate generation
- Tomcat configuration
- Documentation

---

## 10. Appendices

### Appendix A: Configuration File Locations

- Root CA config: `pki-example-1/etc/root-ca.conf`
- Signing CA config: `pki-example-1/etc/signing-ca.conf`
- Server cert config: `pki-example-1/etc/server.conf`

### Appendix B: Certificate File Locations

- Root CA cert: `pki-example-1/ca/root-ca.crt`
- Signing CA cert: `pki-example-1/ca/signing-ca.crt`
- Server cert: `pki-example-1/certs/server.crt`
- Server key: `pki-example-1/certs/server.key`
- JKS keystore: `pki-example-1/certs/server.jks`

### Appendix C: Troubleshooting Commands

```bash
# Check certificate expiration
openssl x509 -in certs/server.crt -noout -enddate

# Verify certificate chain
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt

# Check Tomcat logs
tail -f ~/tomcat/logs/catalina.out

# Test HTTPS connection
openssl s_client -connect localhost:8443 -servername localhost
```

---

## 11. Screenshots

[Include screenshots of:]

1. Certificate details (Root CA, Signing CA, Server)
2. Tomcat HTTPS page (https://localhost:8443)
3. Browser certificate information
4. Certificate chain in browser
5. Command-line verification outputs

---

**End of Document**

