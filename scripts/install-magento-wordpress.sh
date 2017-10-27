#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

if [ ! -f "/etc/php/5.6/mods-available/mcrypt.ini" ]; then
	echo "Install php 5.6 mcrypt"
	sudo apt-get install -y php5.6-mcrypt  > /dev/null 2>&1
fi

if [ ! -f "/etc/php/7.0/mods-available/mcrypt.ini" ]; then
	echo "Install php 7.0 mcrypt"
	sudo apt-get install -y php7.0-mcrypt  > /dev/null 2>&1
fi

if [ ! -f "/etc/php/7.1/mods-available/mcrypt.ini" ]; then
	echo "Install php 7.1 mcrypt"
	sudo apt-get install -y php7.1-mcrypt  > /dev/null 2>&1
fi


if [ ! -f "/usr/local/bin/magerun" ]; then
	echo "Installing magerun"
	curl -O -s https://files.magerun.net/n98-magerun.phar > /dev/null 2>&1
	chmod +x ./n98-magerun.phar
	sudo mv ./n98-magerun.phar /usr/local/bin/magerun
	echo "Magerun installed"
fi

if [ ! -f "/usr/local/bin/magerun2" ]; then
	echo "Installing magerun for magento 2"
	curl -O -s https://files.magerun.net/n98-magerun2.phar > /dev/null 2>&1
	chmod +x ./n98-magerun2.phar
	sudo mv ./n98-magerun2.phar /usr/local/bin/magerun2
	echo "Magerun voor magento 2 installed"
fi

if [ ! -f "/usr/local/bin/wp" ]; then
	echo "Installing WP-CLI"
	curl -O -s https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar > /dev/null 2>&1
	chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp
	echo "WP-CLI Installed"
fi