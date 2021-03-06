#! /bin/sh
mkdir -p pw
mkdir -p sql
mkdir -p db
mkdir -p nginx/ssl
mkdir -p nginx/non-ssl
cd varnish
sh generate-varnish.sh
cd ..
cd nginx
sh generate-nginx.sh
cd ..
sh generate-compose.sh
docker-compose up -d
