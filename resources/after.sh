#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.
sudo service mysql stop
sudo service postgresql stop
sudo service redis-server stop
sudo /etc/init.d/cron restart > /dev/null

opcache="
; configuration for php opcache module
; priority=10
zend_extension=opcache.so
opcache.revalidate_freq = 2
opcache.memory_consumption=512
opcache.max_accelerated_files=50000
opcache.max_wasted_percentage=5
"

echo "Tweak php 5.6"
echo "${opcache}" | sudo tee /etc/php/5.6/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/5.6/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/5.6/fpm/php.ini
sudo service php5.6-fpm restart

echo "Tweak php 7.0"
echo "${opcache}" | sudo tee /etc/php/7.0/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.0/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.0/fpm/php.ini
sudo service php7.0-fpm restart


echo "Tweak php 7.1"
echo "${opcache}" | sudo tee /etc/php/7.1/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.1/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.1/fpm/php.ini
sudo service php7.1-fpm restart

echo "Tweak php 7.2"
echo "${opcache}" | sudo tee /etc/php/7.2/fpm/conf.d/10-opcache.ini > /dev/null
sudo sed -i -e 's/;realpath_cache_size = .*/realpath_cache_size = 4M/g' /etc/php/7.2/fpm/php.ini
sudo sed -i -e 's/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/g' /etc/php/7.2/fpm/php.ini
sudo service php7.2-fpm restart

# No longer used, performance boost is good, but has alot of cache issues when saving from host
# if [ ! -f "/etc/default/cachefilesd" ]; then
#     echo "Install cachefilesd"
#     sudo apt-get install -y cachefilesd  > /dev/null
#     sudo sed -i -e 's/#RUN=.*/RUN=YES/g' /etc/default/cachefilesd
# fi

if [ ! -f "/usr/local/bin/magerun" ]; then
    echo "Installing magerun"
    curl -O -s https://files.magerun.net/n98-magerun.phar > /dev/null
    chmod +x ./n98-magerun.phar
    sudo mv ./n98-magerun.phar /usr/local/bin/magerun
    echo "Magerun installed"
else
    echo "Magerun already installed"
fi

if [ ! -f "/usr/local/bin/magerun2" ]; then
    echo "Installing magerun for magento 2"
    curl -O -s https://files.magerun.net/n98-magerun2.phar > /dev/null
    chmod +x ./n98-magerun2.phar
    sudo mv ./n98-magerun2.phar /usr/local/bin/magerun2
    echo "Magerun voor magento 2 installed"
else
    echo "Magerun for magento 2 already installed"
fi

if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Installing WP-CLI"
    curl -O -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null
    chmod +x wp-cli.phar
    sudo mv wp-cli.phar /usr/local/bin/wp
    echo "WP-CLI Installed"
else
    echo "WP-CLI already installed"
fi


end="\n\n##################################################\n###\t\t\t\t\t\t###\n###\t\tH C D E S I G N S\t\t###\n###\t\t   made by medic  \t\t\t###\n###\t\t\t\t\t\t###\n##################################################"
echo $end