#!/usr/bin/env bash
# sudo add-apt-repository ppa:ondrej/php
# sudo apt-get update
# apt-get install -y php7.0 php7.0-fpm php7.0-mysql php7.0-mcrypt php7.0-intl php7.0-xml php7.0-curl php7.0-dom php7.0-gd php7.0-iconv php7.0-pdo

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
filename=$1
if [[ $domain == "*."* ]]; then
  filename=${domain:2}
fi

if [[ $domain == *"loc"  || $domain == *"vag" ]] ; then
    domain=${domain%.*}
    add_path=""
else
    add_path="$1 www.$1"
fi

block="
server {
    listen      80;
    listen      443 ssl;

    server_name $domain.vag $domain.loc
                $add_path;

    access_log /var/log/nginx/$1-access.log;
    error_log  /var/log/nginx/$1-error.log error;

    root        $2;

    index index.php;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

   location ~ ^/min/([a-z]=.*) {
        rewrite ^/min/([a-z]=.*) /min/index.php?\$1 last;
    }

    location ~ \.(x|ht)ml\$ {
        rewrite ^([a-zA-Z0-9\-_\/]+)(\.(x|ht)ml)?\$ /index.php?p=\$1 last;
    }

    location / {
        index index.html index.php; ## Allow a static html file to be shown first
        try_files \$uri \$uri/ @handler; ## If missing pass the URI to Magento's front handler
        expires 30d; ## Assume all files are cachable
    }

    # error pages
    error_page 404                       /index.php?page=error&code=404;
    error_page 500                       /index.php?page=error&code=500;

    # serve static files directly
    location ~* \.(bmp|gif|jpg|jpeg|png|tif|tiff|svg|js|css|pdf|ico)\$ {
        access_log        off;
        log_not_found     off;
        expires           360d;
        error_page 404 = /;
    }

    location ~ /(classes|imporo|includes|src)/(.*?) {
        deny all;
        return 404;
    }

    location  /\. { ## Disable .htaccess and other hidden files
        return 404;
    }

    location @handler { ## Magento uses a common front handler
        rewrite / /index.php;
    }

    location ~ \.php/ { ## Forward paths like /js/index.php/x.js to relevant handler
        rewrite ^(.*\.php)/ \$1 last;
    }

    location ~ \.php\$ { ## Execute PHP scripts
      try_files \$uri \$uri/ =404;
        expires        off; ## Do not cache dynamic content
        fastcgi_pass   unix:/var/run/php/php$5-fpm.sock;
        fastcgi_param  HTTPS \$https;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        $paramsTXT

        fastcgi_buffer_size             128k;
        fastcgi_buffers                 4 256k;
        fastcgi_busy_buffers_size       256k;

        include        fastcgi_params; ## See /etc/nginx/fastcgi_params


    }

    ssl_certificate     /etc/nginx/ssl/$1.crt; 
    ssl_certificate_key /etc/nginx/ssl/$1.key;
}

"

echo "$block" > "/etc/nginx/sites-available/$filename"
ln -fs "/etc/nginx/sites-available/$filename" "/etc/nginx/sites-enabled/$filename"