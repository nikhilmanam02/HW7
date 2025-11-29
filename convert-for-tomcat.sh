#!/bin/bash

# Convert PKCS12 to JKS for Tomcat
# This script converts the PKCS12 certificate bundle to Java KeyStore (JKS) format

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

PKI_DIR="pki-example-1"
KEYSTORE_PASS="changeit"
KEY_PASS="changeit"

echo "=== Converting Certificate to JKS Format for Tomcat ==="

# Check if Java keytool is available
if ! command -v keytool &> /dev/null; then
    echo "Error: keytool is not found. Please install Java JDK."
    echo "On Ubuntu/Debian: sudo apt-get install default-jdk"
    exit 1
fi

# Check if PKCS12 file exists
if [ ! -f "$PKI_DIR/certs/server.p12" ]; then
    echo "Error: PKCS12 file not found. Please run setup-pki.sh first."
    exit 1
fi

# Convert PKCS12 to JKS
echo "Converting PKCS12 to JKS format..."
keytool -importkeystore \
    -srckeystore "$PKI_DIR/certs/server.p12" \
    -srcstoretype PKCS12 \
    -srcstorepass "$KEYSTORE_PASS" \
    -destkeystore "$PKI_DIR/certs/server.jks" \
    -deststoretype JKS \
    -deststorepass "$KEYSTORE_PASS" \
    -noprompt

echo "JKS keystore created: $PKI_DIR/certs/server.jks"

# Verify the keystore
echo ""
echo "Verifying keystore contents..."
keytool -list -v -keystore "$PKI_DIR/certs/server.jks" -storepass "$KEYSTORE_PASS" | head -30

echo ""
echo "=== Conversion Complete! ==="
echo "Keystore location: $PKI_DIR/certs/server.jks"
echo "Keystore password: $KEYSTORE_PASS"
echo "Key alias: server"
echo ""
echo "You can now configure Tomcat to use this keystore."

