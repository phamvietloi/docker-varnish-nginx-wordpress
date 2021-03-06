#! /bin/bash

cat > docker-compose.yml <<:EOF:
version: '2'
services:
    ssl-terminate:
        image: nginx:1.13.6
        ports:
            - 443:443
        volumes:
            - $PWD/nginx/ssl:/etc/nginx/conf.d
            - /etc/letsencrypt:/etc/letsencrypt
        links:
            - varnish
    mariadb:
        image: mariadb
        volumes:
            - $PWD/db:/var/lib/mysql
            - $PWD/sql:/sql
        env_file:
            - $PWD/pw/mysql
:EOF:

for site in `ls sites`
do
    SITENAME="`echo $site|tr -d .`"
cat >> docker-compose.yml <<:EOF:
    $SITENAME:
        image: nginx:1.13.6
        links:
            - mariadb
            - php-$SITENAME:php
        volumes:
            - $PWD/sites/$site:/var/www/$site
            - $PWD/nginx-base-conf:/etc/nginx/
            - $PWD/nginx/non-ssl:/etc/nginx/conf.d
    php-$SITENAME:
        image: php-mod
        volumes:
            - $PWD/sites/$site:/var/www/$site
            - $PWD/php/logging.conf:/usr/local/etc/php-fpm.d/logging.conf
            - $PWD/php/php.ini:/usr/local/etc/php/php.ini
        links:
            - mariadb
        environment:
            - TIMEZONE=Europe/Helsinki
:EOF:
done
cat >> docker-compose.yml << :EOF:
    varnish:
        ports:
            - 80:80
        image: million12/varnish
        environment:
            - VCL_CONFIG=/data/generated.vcl
        volumes:
            - $PWD/varnish/vcl:/data
        links:
:EOF:
for site in `ls sites`
do
    SITENAME="`echo $site|tr -d .`"
cat >> docker-compose.yml <<:EOF:
            - $SITENAME
:EOF:

done
