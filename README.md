# HW7 - PKI Infrastructure and TLS Certificate Setup

This project demonstrates the setup of a complete PKI (Public Key Infrastructure) with Root CA, Signing CA, and TLS certificate, and configuring Apache Tomcat to use the certificate for HTTPS.

## Project Structure

```
HW7/
├── pki-example-1/          # PKI configuration and certificates
│   ├── etc/                # OpenSSL configuration files
│   ├── ca/                 # CA certificates and keys
│   ├── certs/              # Generated certificates
│   └── crl/                # Certificate Revocation Lists
├── setup-pki.sh            # Script to set up PKI infrastructure
├── convert-for-tomcat.sh   # Script to convert certificate for Tomcat
├── setup-tomcat.sh         # Script to install and configure Tomcat
└── README.md               # This file
```

## Prerequisites

1. **OpenSSL** - For PKI operations
   ```bash
   sudo apt-get update
   sudo apt-get install openssl
   ```

2. **Java JDK** - For Tomcat and keytool
   ```bash
   sudo apt-get install default-jdk
   ```

3. **Python 3** - For XML editing (if using automated setup)
   ```bash
   sudo apt-get install python3
   ```

4. **Wget** - For downloading Tomcat
   ```bash
   sudo apt-get install wget
   ```

## Step-by-Step Instructions

### Step 1: Set Up PKI Infrastructure

The PKI infrastructure consists of:
- **Root CA**: The top-level certificate authority
- **Signing CA**: An intermediate CA signed by the Root CA
- **TLS Certificate**: A server certificate signed by the Signing CA

#### 1.1 Clone the PKI Example Repository

The repository has already been cloned. If you need to clone it again:

```bash
cd /home/nikhil/HW7
git clone https://bitbucket.org/stefanholek/pki-example-1
```

#### 1.2 Run the PKI Setup Script

```bash
cd /home/nikhil/HW7
./setup-pki.sh
```

This script will:
- Create the Root CA with self-signed certificate
- Create the Signing CA signed by Root CA
- Generate a TLS server certificate for localhost
- Create certificate chain and PKCS12 bundle

**Expected Output:**
- Root CA certificate: `pki-example-1/ca/root-ca.crt`
- Signing CA certificate: `pki-example-1/ca/signing-ca.crt`
- Server certificate: `pki-example-1/certs/server.crt`
- Server private key: `pki-example-1/certs/server.key`
- Certificate chain: `pki-example-1/certs/server-chain.pem`
- PKCS12 bundle: `pki-example-1/certs/server.p12`

#### 1.3 Manual Steps (Alternative)

If you prefer to run commands manually, follow these steps:

**Create Root CA:**
```bash
cd pki-example-1

# Create directories
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private

# Create database
cp /dev/null ca/root-ca/db/root-ca.db
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl

# Create CA request
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

**Create Signing CA:**
```bash
# Create directories
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private

# Create database
cp /dev/null ca/signing-ca/db/signing-ca.db
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl

# Create CA request
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key

# Sign with Root CA
openssl ca \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext
```

**Create TLS Server Certificate:**
```bash
# Create certificate request
SAN=DNS:localhost,DNS:www.localhost,IP:127.0.0.1 \
openssl req -new \
    -config etc/server.conf \
    -out certs/server.csr \
    -keyout certs/server.key \
    -subj "/DC=org/DC=simple/O=Simple Inc/CN=localhost"

# Sign with Signing CA
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/server.csr \
    -out certs/server.crt \
    -extensions server_ext
```

### Step 2: Convert Certificate for Tomcat

Tomcat uses Java KeyStore (JKS) format. Convert the PKCS12 bundle to JKS:

```bash
cd /home/nikhil/HW7
./convert-for-tomcat.sh
```

This will create: `pki-example-1/certs/server.jks`

**Manual conversion (alternative):**
```bash
cd pki-example-1

keytool -importkeystore \
    -srckeystore certs/server.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass changeit \
    -destkeystore certs/server.jks \
    -deststoretype JKS \
    -deststorepass changeit \
    -noprompt
```

### Step 3: Install and Configure Tomcat

#### 3.1 Automated Setup

```bash
cd /home/nikhil/HW7
./setup-tomcat.sh
```

#### 3.2 Manual Setup

**Download and Install Tomcat:**
```bash
cd ~
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.87/bin/apache-tomcat-9.0.87.tar.gz
tar -xzf apache-tomcat-9.0.87.tar.gz
mv apache-tomcat-9.0.87 tomcat
rm apache-tomcat-9.0.87.tar.gz
```

**Configure SSL Connector:**

Edit `~/tomcat/conf/server.xml` and add/update the SSL connector:

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

Also ensure the HTTP connector has `redirectPort="8443"`:

```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443" />
```

### Step 4: Start Tomcat and Test

**Start Tomcat:**
```bash
~/tomcat/bin/startup.sh
```

**Stop Tomcat:**
```bash
~/tomcat/bin/shutdown.sh
```

**Test HTTPS Connection:**
```bash
curl -k https://localhost:8443
```

Or open in browser: `https://localhost:8443`

**Note:** You will see a certificate warning because the Root CA is not in your browser's trusted store. This is expected for a self-signed PKI.

### Step 5: Import Root CA Certificate (Optional)

To avoid certificate warnings in your browser, import the Root CA certificate:

1. Export Root CA to a format your browser can import:
   ```bash
   cp pki-example-1/ca/root-ca.crt root-ca.pem
   ```

2. **Firefox:**
   - Go to Preferences > Privacy & Security > Certificates > View Certificates
   - Click "Import" and select `root-ca.pem`
   - Check "Trust this CA to identify websites"

3. **Chrome/Chromium:**
   - On Linux: Copy `root-ca.crt` to `/usr/local/share/ca-certificates/`
   - Run: `sudo update-ca-certificates`
   - Restart browser

## Verification

### Verify Certificates

**View Root CA certificate:**
```bash
openssl x509 -in pki-example-1/ca/root-ca.crt -text -noout
```

**View Signing CA certificate:**
```bash
openssl x509 -in pki-example-1/ca/signing-ca.crt -text -noout
```

**View Server certificate:**
```bash
openssl x509 -in pki-example-1/certs/server.crt -text -noout
```

**Verify certificate chain:**
```bash
openssl verify -CAfile pki-example-1/ca/root-ca.crt \
    -untrusted pki-example-1/ca/signing-ca.crt \
    pki-example-1/certs/server.crt
```

### Verify Keystore

```bash
keytool -list -v -keystore pki-example-1/certs/server.jks \
    -storepass changeit
```

## Certificate Details

- **Root CA**: Self-signed, valid for 10 years
- **Signing CA**: Signed by Root CA, valid for 2 years
- **Server Certificate**: Signed by Signing CA, valid for 2 years
- **Subject Alternative Names**: localhost, www.localhost, 127.0.0.1

## Troubleshooting

### Common Issues

1. **"Keystore was tampered with, or password was incorrect"**
   - Check that the password in `server.xml` matches the keystore password
   - Default password is `changeit`

2. **"SSL handshake error"**
   - Verify the keystore file path in `server.xml` is correct
   - Check that the key alias matches (default: `server`)

3. **Certificate warnings in browser**
   - This is normal for a self-signed PKI
   - Import the Root CA certificate to trust it

4. **Port 8443 already in use**
   - Change the port in `server.xml` or stop the conflicting service
   - Check: `netstat -tulpn | grep 8443`

### Log Files

Tomcat logs are located at:
- `~/tomcat/logs/catalina.out` - Main log file
- `~/tomcat/logs/localhost.YYYY-MM-DD.log` - Application logs

## Security Considerations

1. **Private Keys**: Keep private keys secure. Files in `ca/*/private/` are protected with permissions (700).

2. **Passwords**: The scripts use default passwords (`changeit`). For production, use strong passwords.

3. **Certificate Validity**: Check certificate expiration dates regularly.

4. **CRL**: Implement Certificate Revocation Lists (CRLs) for production use.

## References

- PKI Tutorial: https://pki-tutorial.readthedocs.io/en/latest/simple/
- Tomcat SSL/TLS HOW-TO: https://tomcat.apache.org/tomcat-7.0-doc/ssl-howto.html
- OpenSSL Documentation: https://www.openssl.org/docs/

## Project Status

✅ Root CA created
✅ Signing CA created
✅ TLS Certificate generated
✅ Certificate chain created
✅ PKCS12 bundle created
✅ JKS keystore created
✅ Tomcat configured with SSL

## GitHub Reference

This project is located at: `/home/nikhil/HW7`

To create a GitHub repository:
```bash
cd /home/nikhil/HW7
git init
git add .
git commit -m "HW7: PKI Infrastructure and TLS Certificate Setup"
# Then push to your GitHub repository
```

