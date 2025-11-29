# Detailed Step-by-Step Guide: PKI Infrastructure and TLS Certificate Setup

## Overview

This guide walks you through creating a complete PKI infrastructure with Root CA, Signing CA, and TLS certificate, then configuring Apache Tomcat to use the certificate for secure HTTPS connections.

## Part 1: PKI Infrastructure Setup

### Understanding the PKI Hierarchy

```
Root CA (Self-Signed)
    └── Signing CA (Signed by Root CA)
            └── TLS Server Certificate (Signed by Signing CA)
```

### Step 1.1: Install Prerequisites

```bash
# Update package list
sudo apt-get update

# Install OpenSSL (required for PKI operations)
sudo apt-get install openssl

# Verify installation
openssl version
```

### Step 1.2: Prepare the PKI Directory Structure

```bash
cd /home/nikhil/HW7
cd pki-example-1

# The directory structure should be:
# pki-example-1/
#   ├── etc/          (configuration files)
#   ├── ca/           (CA certificates - to be created)
#   ├── certs/        (user certificates - to be created)
#   └── crl/          (certificate revocation lists - to be created)
```

### Step 1.3: Create Root CA

The Root CA is the top-level certificate authority. It is self-signed and serves as the trust anchor.

#### 1.3.1: Create Directories

```bash
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private  # Restrict access to private key
```

**Explanation:**
- `ca/root-ca/private/` - Stores the Root CA's private key
- `ca/root-ca/db/` - Stores the CA database and serial numbers
- `crl/` - Will store Certificate Revocation Lists
- `certs/` - Will store issued certificates

#### 1.3.2: Initialize Database

```bash
# Create empty database file
cp /dev/null ca/root-ca/db/root-ca.db

# Initialize serial number for certificates (hex format)
echo 01 > ca/root-ca/db/root-ca.crt.srl

# Initialize serial number for CRLs
echo 01 > ca/root-ca/db/root-ca.crl.srl
```

**Explanation:**
- The database file tracks all certificates issued by the CA
- Serial numbers ensure each certificate has a unique identifier

#### 1.3.3: Generate Root CA Private Key and Certificate Request

```bash
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key
```

**What happens:**
- `-config etc/root-ca.conf` - Uses the configuration file that defines CA settings
- `-out ca/root-ca.csr` - Creates a Certificate Signing Request (CSR)
- `-keyout ca/root-ca/private/root-ca.key` - Creates the private key

**You will be prompted for:**
- Passphrase to protect the private key (choose a strong password)

**Expected output:**
- `ca/root-ca.csr` - Certificate Signing Request
- `ca/root-ca/private/root-ca.key` - Private key (protected with passphrase)

#### 1.3.4: Create Self-Signed Root CA Certificate

```bash
openssl ca -selfsign \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext
```

**What happens:**
- `-selfsign` - Creates a self-signed certificate (Root CA signs its own certificate)
- `-extensions root_ca_ext` - Applies extensions that identify this as a CA certificate

**You will be prompted for:**
- Passphrase for the private key (enter the one you set in step 1.3.3)
- Confirmation to sign the certificate (type 'y' and press Enter)

**Expected output:**
- `ca/root-ca.crt` - Root CA certificate (self-signed, valid for 10 years)

**Verify the certificate:**
```bash
openssl x509 -in ca/root-ca.crt -text -noout
```

You should see:
- Subject: `CN=Simple Root CA, O=Simple Inc, DC=simple, DC=org`
- Issuer: Same as Subject (self-signed)
- Key Usage: Certificate Sign, CRL Sign
- Basic Constraints: CA:TRUE

### Step 1.4: Create Signing CA

The Signing CA is an intermediate CA that will issue certificates for end entities (servers, users, etc.).

#### 1.4.1: Create Directories

```bash
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private
```

#### 1.4.2: Initialize Database

```bash
cp /dev/null ca/signing-ca/db/signing-ca.db
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl
```

#### 1.4.3: Generate Signing CA Private Key and Certificate Request

```bash
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key
```

**You will be prompted for:**
- Passphrase to protect the Signing CA private key

#### 1.4.4: Sign Signing CA Certificate with Root CA

```bash
openssl ca \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext
```

**Important:** Note that we use `etc/root-ca.conf` here because the Root CA is signing this certificate.

**You will be prompted for:**
- Root CA private key passphrase
- Confirmation to sign (type 'y')

**Expected output:**
- `ca/signing-ca.crt` - Signing CA certificate (signed by Root CA, valid for 10 years)

**Verify the certificate:**
```bash
openssl x509 -in ca/signing-ca.crt -text -noout
```

You should see:
- Subject: `CN=Simple Signing CA, O=Simple Inc, DC=simple, DC=org`
- Issuer: `CN=Simple Root CA, O=Simple Inc, DC=simple, DC=org`
- Basic Constraints: CA:TRUE, pathlen:0 (cannot issue CA certificates)

### Step 1.5: Create TLS Server Certificate

Now we'll create a certificate for a web server (localhost in this example).

#### 1.5.1: Generate Server Certificate Request

```bash
SAN=DNS:localhost,DNS:www.localhost,IP:127.0.0.1 \
openssl req -new \
    -config etc/server.conf \
    -out certs/server.csr \
    -keyout certs/server.key \
    -subj "/DC=org/DC=simple/O=Simple Inc/CN=localhost"
```

**Explanation:**
- `SAN=...` - Sets Subject Alternative Names (SANs) that the certificate will be valid for
- `-subj` - Sets the Distinguished Name (DN) without prompting

**You will NOT be prompted for a passphrase** (server certificates typically don't use encrypted private keys for automated services)

**Expected output:**
- `certs/server.csr` - Server certificate request
- `certs/server.key` - Server private key (unencrypted)

#### 1.5.2: Sign Server Certificate with Signing CA

```bash
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/server.csr \
    -out certs/server.crt \
    -extensions server_ext
```

**Important:** Now we use `etc/signing-ca.conf` because the Signing CA is signing this certificate.

**You will be prompted for:**
- Signing CA private key passphrase
- Confirmation to sign (type 'y')

**Expected output:**
- `certs/server.crt` - Server certificate (signed by Signing CA, valid for 2 years)

**Verify the certificate:**
```bash
openssl x509 -in certs/server.crt -text -noout
```

You should see:
- Subject: `CN=localhost, O=Simple Inc, DC=simple, DC=org`
- Issuer: `CN=Simple Signing CA, O=Simple Inc, DC=simple, DC=org`
- Subject Alternative Name: DNS:localhost, DNS:www.localhost, IP Address:127.0.0.1
- Extended Key Usage: TLS Web Server Authentication, TLS Web Client Authentication

### Step 1.6: Create Certificate Chain

A certificate chain is needed to establish trust from the server certificate back to the Root CA.

```bash
# Create certificate chain (Signing CA + Root CA)
cat ca/signing-ca.crt ca/root-ca.crt > certs/server-chain.pem
```

**Explanation:**
- Browsers need the full chain to validate certificates
- The chain shows: Server → Signing CA → Root CA

### Step 1.7: Create PKCS12 Bundle

PKCS12 format bundles the certificate, private key, and chain into a single file.

```bash
openssl pkcs12 -export \
    -name "server" \
    -in certs/server.crt \
    -inkey certs/server.key \
    -out certs/server.p12 \
    -certfile certs/server-chain.pem \
    -passout pass:changeit
```

**Explanation:**
- `-name "server"` - Alias for the certificate in the bundle
- `-in certs/server.crt` - Server certificate
- `-inkey certs/server.key` - Server private key
- `-certfile certs/server-chain.pem` - Certificate chain
- `-passout pass:changeit` - Sets password to "changeit" (Tomcat default)

**Expected output:**
- `certs/server.p12` - PKCS12 bundle containing certificate, key, and chain

**Verify the bundle:**
```bash
openssl pkcs12 -in certs/server.p12 -nodes -info -passin pass:changeit
```

## Part 2: Tomcat Configuration

### Step 2.1: Install Java JDK

Tomcat requires Java to run, and we need `keytool` to convert certificates.

```bash
# Install default JDK
sudo apt-get install default-jdk

# Verify installation
java -version
keytool -help
```

### Step 2.2: Convert PKCS12 to JKS Format

Tomcat uses Java KeyStore (JKS) format. Convert the PKCS12 bundle:

```bash
cd /home/nikhil/HW7/pki-example-1

keytool -importkeystore \
    -srckeystore certs/server.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass changeit \
    -destkeystore certs/server.jks \
    -deststoretype JKS \
    -deststorepass changeit \
    -noprompt
```

**Explanation:**
- `-srckeystore` - Source PKCS12 file
- `-destkeystore` - Destination JKS file
- `-noprompt` - Don't prompt for confirmation

**Verify the keystore:**
```bash
keytool -list -v -keystore certs/server.jks -storepass changeit
```

You should see:
- Keystore type: JKS
- Entry type: PrivateKeyEntry
- Alias: server
- Certificate chain: 3 certificates (server, Signing CA, Root CA)

### Step 2.3: Download and Install Apache Tomcat

```bash
cd ~

# Download Tomcat 9.0.87
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz

# Extract
tar -xzf apache-tomcat-9.0.87.tar.gz

# Rename for convenience
mv apache-tomcat-9.0.87 tomcat

# Clean up
rm apache-tomcat-9.0.87.tar.gz
```

**Tomcat structure:**
```
~/tomcat/
├── bin/          (executables)
├── conf/         (configuration files)
├── lib/          (libraries)
├── logs/         (log files)
├── webapps/      (web applications)
└── work/         (temporary files)
```

### Step 2.4: Configure SSL Connector in Tomcat

Edit the server configuration:

```bash
nano ~/tomcat/conf/server.xml
```

**Find the existing Connector section** (around line 69) and **uncomment/modify** the SSL connector, or add this:

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

**Important configuration parameters:**
- `port="8443"` - HTTPS port (change to 443 for production, requires root)
- `keystoreFile` - Full path to your JKS keystore
- `keystorePass` - Password for the keystore
- `keyAlias` - Alias of the certificate in the keystore ("server")
- `sslProtocol="TLS"` - Use TLS protocol

**Also ensure the HTTP connector redirects to HTTPS:**

Find the HTTP connector (usually port 8080) and ensure it has:
```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### Step 2.5: Make Tomcat Executable

```bash
chmod +x ~/tomcat/bin/*.sh
```

### Step 2.6: Start Tomcat

```bash
~/tomcat/bin/startup.sh
```

**Verify it's running:**
```bash
ps aux | grep tomcat
# Or check the port
netstat -tulpn | grep 8443
```

**Check logs:**
```bash
tail -f ~/tomcat/logs/catalina.out
```

Look for messages like:
- "Starting ProtocolHandler ["http-nio-8443"]"
- No SSL errors

### Step 2.7: Test HTTPS Connection

#### Using curl:
```bash
curl -k https://localhost:8443
```

The `-k` flag ignores certificate warnings (since the Root CA isn't trusted).

#### Using browser:

1. Open browser and navigate to: `https://localhost:8443`
2. You will see a security warning (expected - Root CA is not in browser trust store)
3. Click "Advanced" → "Proceed to localhost (unsafe)"

You should see the Tomcat default page.

### Step 2.8: Stop Tomcat

When done testing:

```bash
~/tomcat/bin/shutdown.sh
```

## Part 3: Verification and Troubleshooting

### Verify Certificate Chain

```bash
cd /home/nikhil/HW7/pki-example-1

# Verify server certificate against the chain
openssl verify -CAfile ca/root-ca.crt \
    -untrusted ca/signing-ca.crt \
    certs/server.crt
```

**Expected output:** `certs/server.crt: OK`

### View Certificate Details

```bash
# View server certificate
openssl x509 -in certs/server.crt -text -noout | less

# View certificate chain
openssl crl2pkcs7 -nocrl -certfile ca/signing-ca.crt \
    -certfile ca/root-ca.crt | openssl pkcs7 -print_certs -text -noout
```

### Common Issues and Solutions

#### Issue 1: "Keystore was tampered with, or password was incorrect"

**Solution:**
- Verify the password in `server.xml` matches the keystore password
- Default password is `changeit`
- Check for typos in the `keystorePass` attribute

#### Issue 2: "SSL handshake error" or "No available certificate"

**Solution:**
- Verify `keystoreFile` path in `server.xml` is correct (use absolute path)
- Check that `keyAlias` matches the alias in the keystore
- Verify keystore contains the certificate:
  ```bash
  keytool -list -v -keystore /home/nikhil/HW7/pki-example-1/certs/server.jks -storepass changeit
  ```

#### Issue 3: Port 8443 already in use

**Solution:**
```bash
# Find what's using the port
sudo lsof -i :8443
# Or
sudo netstat -tulpn | grep 8443

# Stop the conflicting service or change the port in server.xml
```

#### Issue 4: Certificate warnings in browser

**Solution:**
This is normal for a self-signed PKI. To avoid warnings:

1. Export Root CA certificate:
   ```bash
   cp pki-example-1/ca/root-ca.crt root-ca.pem
   ```

2. Import into browser (see README.md for detailed instructions)

#### Issue 5: Tomcat won't start

**Solution:**
- Check Java is installed: `java -version`
- Check logs: `tail -f ~/tomcat/logs/catalina.out`
- Verify JAVA_HOME is set:
  ```bash
  export JAVA_HOME=/usr/lib/jvm/default-java
  ```

## Part 4: Certificate Management

### View All Certificates in Chain

```bash
cd /home/nikhil/HW7/pki-example-1

echo "=== Root CA ==="
openssl x509 -in ca/root-ca.crt -noout -subject -issuer -dates

echo -e "\n=== Signing CA ==="
openssl x509 -in ca/signing-ca.crt -noout -subject -issuer -dates

echo -e "\n=== Server Certificate ==="
openssl x509 -in certs/server.crt -noout -subject -issuer -dates
```

### Check Certificate Expiration

```bash
openssl x509 -in certs/server.crt -noout -enddate
```

### Revoke a Certificate (if needed)

```bash
# Revoke server certificate
openssl ca \
    -config etc/signing-ca.conf \
    -revoke ca/signing-ca/[SERIAL_NUMBER].pem \
    -crl_reason superseded

# Generate CRL
openssl ca -gencrl \
    -config etc/signing-ca.conf \
    -out crl/signing-ca.crl
```

## Summary

You have successfully:

1. ✅ Created a Root CA (self-signed)
2. ✅ Created a Signing CA (signed by Root CA)
3. ✅ Generated a TLS server certificate (signed by Signing CA)
4. ✅ Created certificate chain
5. ✅ Converted certificate to JKS format
6. ✅ Configured Tomcat with SSL/TLS
7. ✅ Tested HTTPS connection

## Next Steps

1. Document your setup in a Word document
2. Take screenshots of:
   - Certificate details
   - Tomcat HTTPS page
   - Browser certificate information
3. Create a GitHub repository with all files
4. Include references and citations

## Security Notes

- **Private Keys**: Always protect private keys. They are currently in `ca/*/private/` with restricted permissions (700)
- **Passwords**: Change default passwords in production
- **Certificate Validity**: Monitor expiration dates
- **CRL**: Implement Certificate Revocation Lists for production

## References

- PKI Tutorial: https://pki-tutorial.readthedocs.io/en/latest/simple/
- Tomcat SSL HOW-TO: https://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html
- OpenSSL Documentation: https://www.openssl.org/docs/

