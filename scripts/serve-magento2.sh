#!/usr/bin/env bash
# FILE_BACKSTREAM="magento2_backstream"
# PATH_BACKSTREAM="/etc/nginx/sites-available/${FILE_BACKSTREAM}"

# if [ ! -f $PATH_BACKSTREAM ]
# then
#     echo "Install nginx upstream"
#     upstream_block="upstream fastcgi_backend_5.6 {
#     # socket
#         server unix:/var/run/php/php5.6-fpm.sock;
#     }
#     upstream fastcgi_backend_7.0 {
#     # socket
#         server unix:/var/run/php/php7.0-fpm.sock;
#     }
#     upstream fastcgi_backend_7.1 {
#     # socket
#         server unix:/var/run/php/php7.1-fpm.sock;
#     }

#     upstream fastcgi_backend_7.2 {
#     # NOT IN USE BY MAGENTO 2.2!
#     # socket
#         server unix:/var/run/php/php7.0-fpm.sock;
#     }
#     "

#     echo "$upstream_block" > "${PATH_BACKSTREAM}"
#     ln -fs "${PATH_BACKSTREAM}" "/etc/nginx/sites-enabled/${FILE_BACKSTREAM}"
# fi

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
if [[ $php_version == "7.3" ]]; then
    echo "Magento 2 cannot use php 7.3"
    echo "Setting up php 7.2 for $domain"
    php_version="7.2"
fi
echo "Use php version $php_version"

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

    root \$MAGE_ROOT/pub;

    index index.php;
    autoindex off;
    charset UTF-8;
    error_page 404 403 = /errors/404.php;
    #add_header \"X-UA-Compatible\" \"IE=Edge\";

    # PHP entry point for setup application
    location ~* ^/setup(\$|/) {
        root \$MAGE_ROOT;
        location ~ ^/setup/index.php {
            fastcgi_pass   fastcgi_backend_$php_version;

            fastcgi_param  PHP_FLAG  \"session.auto_start=off \n suhosin.session.cryptua=off\";
            fastcgi_param  PHP_VALUE \"memory_limit=768M \n max_execution_time=600\";
            fastcgi_read_timeout 600s;
            fastcgi_connect_timeout 600s;

            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            include        fastcgi_params;
        }

        location ~ ^/setup/(?!pub/). {
            deny all;
        }

        location ~ ^/setup/pub/ {
            add_header X-Frame-Options \"SAMEORIGIN\";
        }
    }

    # PHP entry point for update application
    location ~* ^/update(\$|/) {
        root \$MAGE_ROOT;

        location ~ ^/update/index.php {
            fastcgi_split_path_info ^(/update/index.php)(/.+)\$;
            fastcgi_pass   fastcgi_backend_$php_version;
            fastcgi_index  index.php;
            fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
            fastcgi_param  PATH_INFO        \$fastcgi_path_info;
            include        fastcgi_params;
        }

        # Deny everything but index.php
        location ~ ^/update/(?!pub/). {
            deny all;
        }

        location ~ ^/update/pub/ {
            add_header X-Frame-Options \"SAMEORIGIN\";
        }
    }

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
    }

    location /pub/ {
        location ~ ^/pub/media/(downloadable|customer|import|theme_customization/.*\.xml) {
            deny all;
        }
        alias \$MAGE_ROOT/pub/;
        add_header X-Frame-Options \"SAMEORIGIN\";
    }

    location /static/ {
        # Uncomment the following line in production mode
        # expires max;

        # Remove signature of the static files that is used to overcome the browser cache
        location ~ ^/static/version {
            rewrite ^/static/(version\d*/)?(.*)\$ /static/\$2 last;
        }

        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control \"public\";
            add_header X-Frame-Options \"SAMEORIGIN\";
            expires +1y;

            if (!-f \$request_filename) {
                rewrite ^/static/?(.*)\$ /static.php?resource=\$1 last;
            }
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control \"no-store\";
            add_header X-Frame-Options \"SAMEORIGIN\";
            expires    off;

            if (!-f \$request_filename) {
               rewrite ^/static/?(.*)\$ /static.php?resource=\$1 last;
            }
        }
        if (!-f \$request_filename) {
            rewrite ^/static/?(.*)\$ /static.php?resource=\$1 last;
        }
        add_header X-Frame-Options \"SAMEORIGIN\";
    }

    location /media/ {
        try_files \$uri \$uri/ /get.php\$is_args\$args;

        location ~ ^/media/theme_customization/.*\.xml {
            deny all;
        }

        location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)\$ {
            add_header Cache-Control \"public\";
            add_header X-Frame-Options \"SAMEORIGIN\";
            expires +1y;
            try_files \$uri \$uri/ /get.php\$is_args\$args;
        }
        location ~* \.(zip|gz|gzip|bz2|csv|xml)\$ {
            add_header Cache-Control \"no-store\";
            add_header X-Frame-Options \"SAMEORIGIN\";
            expires    off;
            try_files \$uri \$uri/ /get.php\$is_args\$args;
        }
        add_header X-Frame-Options \"SAMEORIGIN\";
    }

    location /media/customer/ {
        deny all;
    }

    location /media/downloadable/ {
        deny all;
    }

    location /media/import/ {
        deny all;
    }

    # PHP entry point for main application
    location ~ (index|get|static|report|404|503)\.php\$ {
        try_files \$uri =404;
        fastcgi_pass   fastcgi_backend_$php_version;
        fastcgi_buffers 1024 4k;

        fastcgi_param  PHP_FLAG  \"session.auto_start=off \n suhosin.session.cryptua=off\";
        fastcgi_param  PHP_VALUE \"memory_limit=768M \n max_execution_time=18000\";
        fastcgi_read_timeout 600s;
        fastcgi_connect_timeout 600s;

        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
        include        fastcgi_params;
    }

    gzip on;
    gzip_disable \"msie6\";

    gzip_comp_level 6;
    gzip_min_length 1100;
    gzip_buffers 16 8k;
    gzip_proxied any;
    gzip_types
        text/plain
        text/css
        text/js
        text/xml
        text/javascript
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/xml+rss
        image/svg+xml;
    gzip_vary on;

    # Banned locations (only reached if the earlier PHP entry point regexes don't match)
    location ~* (\.php\$|\.htaccess\$|\.git) {
        deny all;
    }
}
"

echo "$block" > "/etc/nginx/sites-available/$1"
ln -fs "/etc/nginx/sites-available/$1" "/etc/nginx/sites-enabled/$1"

#cron_block="* * * * * vagrant /usr/bin/php$php_version $2/bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $2/var/log/magento.cron.log
#* * * * * vagrant /usr/bin/php$php_version $2/bin/magento setup:cron:run >> $2/var/log/setup.cron.log
#* * * * * vagrant /usr/bin/php$php_version $2/update/cron.php >> $2/var/log/update.cron.log"
#cronfile=$1
#cronfile=${cronfile//[-._]/}
#echo "$cron_block" > "/etc/cron.d/mag${cronfile}"