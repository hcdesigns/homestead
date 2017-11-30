#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

declare modules_needed=(
	"mcrypt"
	"soap"
	"xml"
	"curl"
	"dom"
	"gd"
	"hash"
	"iconv"
	"pcre"
	);

declare php56modules=$(/usr/bin/php5.6 -m)
declare php70modules=$(/usr/bin/php7.0 -m)
declare php71modules=$(/usr/bin/php7.1 -m)
declare php72modules=$(/usr/bin/php7.2 -m)

for module in "${modules_needed[@]}"
do
	if [[ $php56modules != *"$module"* ]]; then
		php56install="$php56install php5.6-${module}";
	fi

	if [[ $php70modules != *"$module"* ]]; then
		php70install="$php70install php7.0-${module}";
	fi

	if [[ $php71modules != *"$module"* ]]; then
		php71install="$php71install php7.1-${module}";
	fi
done

if [[ ! -z $php56install ]]; then
	sudo apt-get install -y $php56install > /dev/null 2>&1
fi

if [[ ! -z $php70install ]]; then
	sudo apt-get install -y $php70install > /dev/null 2>&1
fi

if [[ ! -z $php71install ]]; then
	sudo apt-get install -y $php71install > /dev/null 2>&1
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