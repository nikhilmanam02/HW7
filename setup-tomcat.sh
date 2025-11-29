#!/bin/bash

# Tomcat Setup Script for HW7
# This script installs and configures Tomcat with SSL/TLS using our PKI certificates

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

PKI_DIR="pki-example-1"
TOMCAT_VERSION="9.0.87"
TOMCAT_DIR="$HOME/tomcat"
KEYSTORE_FILE="$SCRIPT_DIR/$PKI_DIR/certs/server.jks"
KEYSTORE_PASS="changeit"

echo "=== Tomcat Setup with SSL/TLS ==="

# Check if JKS keystore exists
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo "Error: JKS keystore not found. Please run convert-for-tomcat.sh first."
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed. Please install Java JDK first."
    echo "On Ubuntu/Debian: sudo apt-get install default-jdk"
    exit 1
fi

# Check if Tomcat is already installed
if [ -d "$TOMCAT_DIR" ]; then
    echo "Tomcat directory already exists at $TOMCAT_DIR"
    read -p "Do you want to remove it and reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$TOMCAT_DIR"
    else
        echo "Using existing Tomcat installation."
    fi
fi

# Download Tomcat if not present
if [ ! -d "$TOMCAT_DIR" ]; then
    echo "Downloading Apache Tomcat $TOMCAT_VERSION..."
    cd /tmp
    wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    
    echo "Extracting Tomcat..."
    mkdir -p "$TOMCAT_DIR"
    tar -xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" -C "$TOMCAT_DIR" --strip-components=1
    rm "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
    
    echo "Tomcat installed to $TOMCAT_DIR"
fi

# Configure SSL connector
echo "Configuring SSL connector in server.xml..."

TOMCAT_SERVER_XML="$TOMCAT_DIR/conf/server.xml"
BACKUP_FILE="$TOMCAT_SERVER_XML.backup"

# Create backup
cp "$TOMCAT_SERVER_XML" "$BACKUP_FILE"

# Check if SSL connector is already configured
if grep -q 'port="8443"' "$TOMCAT_SERVER_XML"; then
    echo "SSL connector already configured. Updating..."
    # This is a simple approach - you may want to manually edit server.xml
else
    echo "Adding SSL connector configuration..."
    # We'll create a Python script to properly edit the XML
fi

# Create Python script to configure server.xml
python3 << 'PYTHON_SCRIPT'
import xml.etree.ElementTree as ET
import sys
import os

tomcat_dir = os.path.expanduser("~/tomcat")
server_xml = os.path.join(tomcat_dir, "conf/server.xml")
keystore_file = sys.argv[1]
keystore_pass = sys.argv[2]

if not os.path.exists(server_xml):
    print(f"Error: {server_xml} not found")
    sys.exit(1)

# Parse XML
tree = ET.parse(server_xml)
root = tree.getroot()

# Find Service element (usually the first one)
service = root.find('.//Service')
if service is None:
    print("Error: Could not find Service element")
    sys.exit(1)

# Remove existing SSL connector if present
for connector in service.findall('Connector'):
    port = connector.get('port')
    if port == '8443':
        service.remove(connector)
        print("Removed existing SSL connector")

# Create new SSL connector
ssl_connector = ET.Element('Connector')
ssl_connector.set('protocol', 'org.apache.coyote.http11.Http11NioProtocol')
ssl_connector.set('port', '8443')
ssl_connector.set('maxThreads', '200')
ssl_connector.set('scheme', 'https')
ssl_connector.set('secure', 'true')
ssl_connector.set('SSLEnabled', 'true')
ssl_connector.set('keystoreFile', keystore_file)
ssl_connector.set('keystorePass', keystore_pass)
ssl_connector.set('clientAuth', 'false')
ssl_connector.set('sslProtocol', 'TLS')
ssl_connector.set('keyAlias', 'server')

# Add connector to service
service.append(ssl_connector)

# Update HTTP connector redirectPort
for connector in service.findall('Connector'):
    port = connector.get('port')
    scheme = connector.get('scheme', 'http')
    if port == '8080' and scheme == 'http':
        connector.set('redirectPort', '8443')

# Write back
tree.write(server_xml, encoding='utf-8', xml_declaration=True)
print(f"SSL connector configured in {server_xml}")
PYTHON_SCRIPT "$(realpath $KEYSTORE_FILE)" "$KEYSTORE_PASS"

echo ""
echo "=== Tomcat Configuration Complete! ==="
echo ""
echo "Tomcat installation: $TOMCAT_DIR"
echo "Keystore: $KEYSTORE_FILE"
echo ""
echo "To start Tomcat:"
echo "  cd $TOMCAT_DIR"
echo "  ./bin/startup.sh"
echo ""
echo "To stop Tomcat:"
echo "  cd $TOMCAT_DIR"
echo "  ./bin/shutdown.sh"
echo ""
echo "Access your site at: https://localhost:8443"
echo ""
echo "Note: You may need to import the Root CA certificate into your browser"
echo "to avoid certificate warnings."

