#!/bin/bash

# PKI Setup Script for HW7
# This script creates Root CA, Signing CA, and TLS Certificate

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${GREEN}=== PKI Infrastructure Setup ===${NC}"

# Check if openssl is installed
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}Error: openssl is not installed. Please install it first.${NC}"
    exit 1
fi

PKI_DIR="pki-example-1"
if [ ! -d "$PKI_DIR" ]; then
    echo -e "${RED}Error: $PKI_DIR directory not found.${NC}"
    exit 1
fi

cd "$PKI_DIR"

# Export common password (you can change this)
export ROOT_CA_PASS="rootcapassword"
export SIGNING_CA_PASS="signingcapassword"

echo -e "\n${GREEN}Step 1: Creating Root CA${NC}"

# 1.1 Create directories
echo "Creating directories..."
mkdir -p ca/root-ca/private ca/root-ca/db crl certs
chmod 700 ca/root-ca/private

# 1.2 Create database
echo "Creating database..."
cp /dev/null ca/root-ca/db/root-ca.db
echo 01 > ca/root-ca/db/root-ca.crt.srl
echo 01 > ca/root-ca/db/root-ca.crl.srl

# 1.3 Create CA request
echo "Creating Root CA certificate request..."
openssl req -new \
    -config etc/root-ca.conf \
    -out ca/root-ca.csr \
    -keyout ca/root-ca/private/root-ca.key \
    -passout env:ROOT_CA_PASS

# 1.4 Create CA certificate (self-signed)
echo "Creating Root CA certificate (self-signed)..."
openssl ca -selfsign \
    -config etc/root-ca.conf \
    -in ca/root-ca.csr \
    -out ca/root-ca.crt \
    -extensions root_ca_ext \
    -passin env:ROOT_CA_PASS \
    -batch

echo -e "\n${GREEN}Step 2: Creating Signing CA${NC}"

# 2.1 Create directories
echo "Creating directories..."
mkdir -p ca/signing-ca/private ca/signing-ca/db crl certs
chmod 700 ca/signing-ca/private

# 2.2 Create database
echo "Creating database..."
cp /dev/null ca/signing-ca/db/signing-ca.db
echo 01 > ca/signing-ca/db/signing-ca.crt.srl
echo 01 > ca/signing-ca/db/signing-ca.crl.srl

# 2.3 Create CA request
echo "Creating Signing CA certificate request..."
openssl req -new \
    -config etc/signing-ca.conf \
    -out ca/signing-ca.csr \
    -keyout ca/signing-ca/private/signing-ca.key \
    -passout env:SIGNING_CA_PASS

# 2.4 Create CA certificate (signed by Root CA)
echo "Creating Signing CA certificate (signed by Root CA)..."
openssl ca \
    -config etc/root-ca.conf \
    -in ca/signing-ca.csr \
    -out ca/signing-ca.crt \
    -extensions signing_ca_ext \
    -passin env:ROOT_CA_PASS \
    -batch

echo -e "\n${GREEN}Step 3: Creating TLS Server Certificate${NC}"

# 3.1 Create TLS server request
echo "Creating TLS server certificate request..."
SAN=DNS:localhost,DNS:www.localhost,IP:127.0.0.1 \
openssl req -new \
    -config etc/server.conf \
    -out certs/server.csr \
    -keyout certs/server.key \
    -subj "/DC=org/DC=simple/O=Simple Inc/CN=localhost"

# 3.2 Create TLS server certificate
echo "Creating TLS server certificate (signed by Signing CA)..."
openssl ca \
    -config etc/signing-ca.conf \
    -in certs/server.csr \
    -out certs/server.crt \
    -extensions server_ext \
    -passin env:SIGNING_CA_PASS \
    -batch

echo -e "\n${GREEN}Step 4: Creating Certificate Chain${NC}"

# Create certificate chain (Signing CA + Root CA)
cat ca/signing-ca.crt ca/root-ca.crt > certs/server-chain.pem

echo -e "\n${GREEN}Step 5: Creating PKCS12 bundle for Tomcat${NC}"

# Create PKCS12 bundle (certificate + private key + chain)
# Note: We'll use a temporary password, you should change it
export PKCS12_PASS="changeit"

openssl pkcs12 -export \
    -name "server" \
    -in certs/server.crt \
    -inkey certs/server.key \
    -out certs/server.p12 \
    -certfile certs/server-chain.pem \
    -passout env:PKCS12_PASS \
    -passin pass:

echo -e "\n${GREEN}Step 6: Creating DER formats${NC}"

# Create DER certificate
openssl x509 \
    -in certs/server.crt \
    -out certs/server.cer \
    -outform der

# Create DER CRL
if [ -f crl/signing-ca.crl ]; then
    openssl crl \
        -in crl/signing-ca.crl \
        -out crl/signing-ca.crl.der \
        -outform der
fi

echo -e "\n${GREEN}=== PKI Setup Complete! ===${NC}"
echo ""
echo "Generated files:"
echo "  - Root CA certificate: ca/root-ca.crt"
echo "  - Signing CA certificate: ca/signing-ca.crt"
echo "  - TLS Server certificate: certs/server.crt"
echo "  - TLS Server private key: certs/server.key"
echo "  - Certificate chain: certs/server-chain.pem"
echo "  - PKCS12 bundle for Tomcat: certs/server.p12"
echo ""
echo "Next steps:"
echo "  1. Import the PKCS12 file into a Java keystore for Tomcat"
echo "  2. Configure Tomcat to use the keystore"
echo "  3. Test HTTPS connection"

