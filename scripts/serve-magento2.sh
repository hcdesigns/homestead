#!/usr/bin/env bash
FILE_BACKSTREAM="magento2_backstream"
PATH_BACKSTREAM="/etc/nginx/sites-available/${FILE_BACKSTREAM}"

if [ ! -f $PATH_BACKSTREAM ]
then
    echo "Install nginx upstream"
    upstream_block="upstream fastcgi_backend {
    # socket
        server unix:/var/run/php/php7.0-fpm.sock;
    }
    "

    echo "$upstream_block" > "${PATH_BACKSTREAM}"
    ln -fs "${PATH_BACKSTREAM}" "/etc/nginx/sites-enabled/${FILE_BACKSTREAM}"
fi

domain=$1
if [[ $domain == "www."* ]]; then
  domain=${domain:4}
fi

if [[ $domain == *"loc"  || $domain == *"vag" ]] ; then
    domain=${domain%.*}
    add_path=""
else
    add_path="$1 www.$1"
fi

block="
server {
    listen ${3:-80};
    listen ${4:-443} ssl http2;
    server_name $domain.vag www.$domain.vag
                $domain.loc www.$domain.loc
                $add_path;
    set \$MAGE_ROOT \"$2\";


    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    ssl_certificate     /etc/nginx/ssl/$1.crt;
    ssl_certificate_key /etc/nginx/ssl/$1.key;

    include $2/nginx.conf.sample;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"
echo "Don't forget! Magento only works with php 7.0 (for now)"

echo "Magento 2 installation succeeded"

cron_block="* * * * * vagrant /usr/bin/php7.0 $2/bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $2/var/log/magento.cron.log
* * * * * vagrant /usr/bin/php7.0 $2/bin/magento setup:cron:run >> $2/var/log/setup.cron.log
* * * * * vagrant /usr/bin/php7.0 $2/update/cron.php >> $2/var/log/update.cron.log"
cronfile=$1
cronfile=${cronfile//[-._]/}
echo "$cron_block" > "/etc/cron.d/mag${cronfile}"
echo "Magento 2 cron installation succeeded"