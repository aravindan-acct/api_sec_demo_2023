#! /bin/bash

### This script sets up the ubuntu server for the apifrontend
### It uses nginx for ssl offloading of the apifrontend traffic 
### 
###
### 1. Initial setup - package installations
### 2. Generating the certificates for NGINX configuration
### 3. NGINX Configuration file
### 4. Setting up NGINX
###

# Initial Setup

sudo apt-get -y update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
wget -q --show-progress --https-only --timestamping \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssl \
  https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/1.4.1/linux/cfssljson

chmod +x cfssl cfssljson
sudo mv cfssl cfssljson /usr/local/bin/
sudo apt-get -y install nginx
wget https://raw.githubusercontent.com/aravindan-acct/frontend_UI_app/waas/scripts/IMDS_Script_Customized.py
python3 IMDS_Script_Customized.py
echo "Public IP set for the JS code to work"
echo "Generating the  certificates for nginx configuration"


# Generating the certificates for NGINX configuration

{

cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "apifrontend": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF

cat > ca-csr.json <<EOF
{
  "CN": "admin.cuda.local",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "SF",
      "O": "APIFrontend",
      "OU": "CA",
      "ST": "CA"
    }
  ]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

}


# Server certificate
{ 

cat > apifrontend-csr.json <<EOF
{
  "CN": "apifrontend.cuda.local",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "SF",
      "O": "cudase",
      "OU": "API SEC demo",
      "ST": "CA"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=apifrontend.cudanet.local \
  -profile=apifrontend \
  apifrontend-csr.json | cfssljson -bare apifrontend

}
echo "moving the certificates"
sudo cp apifrontend-key.pem /etc/nginx/cert.key
sudo cp apifrontend.pem /etc/nginx/cert.crt 
# NGINX Configuration
{
cat > nginxconfig.conf << EOF
server {
    
    listen 80;
    listen 443 default ssl;
    server_name apifrontend.cudanet.local;

    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;

    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    access_log            /var/log/nginx/access.log;

    location / {
      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$remote_addr;
      proxy_set_header        X-Forwarded-Proto \$scheme;

      # Fix the “It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://localhost:7979;
      proxy_read_timeout  90;

      proxy_redirect      http://localhost:7979 https://apifrontend.cudanet.local;
      
    }
  }
EOF
}
sudo cp nginxconfig.conf nginxconfig.conf.bak
sudo mv nginxconfig.conf /etc/nginx/sites-enabled/default
git clone -b waas https://github.com/aravindan-acct/frontend_UI_app.git
cd frontend_UI_app
nohup python3 starturl.py &
echo "Script run completed"
