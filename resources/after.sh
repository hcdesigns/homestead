#!/bin/sh

sudo service mysql stop
sudo service postgresql stop
sudo service redis-server stop
sudo /etc/init.d/cron restart > /dev/null

end="\n\n##################################################\n###\t\t\t\t\t\t###\n###\t\tH C D E S I G N S\t\t###\n###\t\t   made by medic  \t\t\t###\n###\t\t\t\t\t\t###\n##################################################"
echo $end
