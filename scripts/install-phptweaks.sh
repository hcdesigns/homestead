#!/usr/bin/env bash
opcache="
; configuration for php opcache module
; priority=10
zend_extension=opcache.so
opcache.revalidate_freq = 2
opcache.memory_consumption=512
opcache.max_accelerated_files=50000
opcache.max_wasted_percentage=5
"

echo "${opcache}" | sudo tee /etc/php/5.6/fpm/conf.d/10-opcache.ini > /dev/null 2>&1
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/5.6/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/5.6/fpm/php.ini
sudo sed -i -e 's/date.timezone = UTC/date.timezone = Europe\/Amsterdam/g' /etc/php/5.6/fpm/php.ini

sudo service php5.6-fpm restart

echo "${opcache}" | sudo tee /etc/php/7.0/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.0/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.0/fpm/php.ini
sudo sed -i -e 's/date.timezone = UTC/date.timezone = Europe\/Amsterdam/g' /etc/php/7.0/fpm/php.ini
sudo service php7.0-fpm restart


echo "${opcache}" | sudo tee /etc/php/7.1/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.1/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.1/fpm/php.ini
sudo sed -i -e 's/date.timezone = UTC/date.timezone = Europe\/Amsterdam/g' /etc/php/7.1/fpm/php.ini
sudo service php7.1-fpm restart

echo "${opcache}" | sudo tee /etc/php/7.2/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.2/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.2/fpm/php.ini
sudo sed -i -e 's/date.timezone = .*/date.timezone = Europe\/Amsterdam/g' /etc/php/7.2/fpm/php.ini
sudo service php7.2-fpm restart