#! /bin/sh
cd varnish
mkdir pw
mkdir sql
mkdir db
sh generate-varnish.sh
cd ..
cd nginx
sh generate-nginx.sh
cd ..
sh generate-compose.sh
docker-compose -d up
