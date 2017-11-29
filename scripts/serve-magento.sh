#!/usr/bin/env bash
declare -A params=$6     # Create an associative array
paramsTXT=""
if [ -n "$6" ]; then
   for element in "${!params[@]}"
   do
      paramsTXT="${paramsTXT}
      fastcgi_param ${element} ${params[$element]};"
   done
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

php_version=$5
if [[ $php_version == "7.1" || $php_version == "7.2" ]]; then
    echo "Magento 1 cannot use php 7.1 or 7.2"
    echo "Setting up php 5.6 for $domain"
    php_version="5.6"
fi

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl http2;
    server_name $domain.vag www.$domain.vag
                $domain.loc www.$domain.loc
                $add_path;
                
    root \"$2\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$1-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php$php_version-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        $paramsTXT

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 256k;
        fastcgi_buffers 64 512k;
        fastcgi_busy_buffers_size 512k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$1.crt;
    ssl_certificate_key /etc/nginx/ssl/$1.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"

cronfile=$1
cronfile=${cronfile//[-._]/}
cron_block="* * * * * vagrant /usr/bin/php$php_version $2/cron.php"
echo "$cron_block" > "/etc/cron.d/mag${cronfile}"
