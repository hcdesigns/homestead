FILE_BACKSTREAM="magento2_backstream"
PATH_BACKSTREAM="/etc/nginx/sites-available/${FILE_BACKSTREAM}"

if [ ! -f $PATH_BACKSTREAM ]
then
    echo "Install nginx upstream"
    upstream_block="upstream fastcgi_backend_5.6 {
    # socket
        server unix:/var/run/php/php5.6-fpm.sock;
    }
    upstream fastcgi_backend_7.0 {
    # socket
        server unix:/var/run/php/php7.0-fpm.sock;
    }
    upstream fastcgi_backend_7.1 {
    # socket
        server unix:/var/run/php/php7.1-fpm.sock;
    }

    upstream fastcgi_backend_7.2 {
    # NOT IN USE BY MAGENTO 2.2!
    # socket
        server unix:/var/run/php/php7.0-fpm.sock;
    }
    "

    echo "$upstream_block" > "${PATH_BACKSTREAM}"
    ln -fs "${PATH_BACKSTREAM}" "/etc/nginx/sites-enabled/${FILE_BACKSTREAM}"
fi