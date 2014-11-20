#!/bin/bash
# This script is used for create virtual hosts for Apache.
# Created by Ke Ma <kema2012@gmail.com>
# Feel free to modify it
# Argument = -n servername -r documentroot -i interaction

usage()
{
cat << EOF
Automate create new vhost for Apache.

usage: $0 [OPTIONS]

OPTIONS:
	-h Help
	-n Site URL without 'http://' or 'https://' e.g. 'kinder.local'
	-r Documentroot, where your website scripts are, e.g. /var/www/kinder
	-C Creat virtual host
	-D Delete virtual host
	-i Interaction mode.
EOF
}

vhostsDir='/etc/apache2/vhosts/'
vhostsConf=
owner=$(who am i | awk '{print $1}')

SERVERNAME=
DOCUMENTROOT=
INTERACTIVEMODE=0
ACTION=

#Check if you execute the script as root user
if [ "$(whoami)" != 'root' ]; then
	echo "You have no permission to run $0 as non-root user. Use sudo"
	exit 1;
fi

while getopts "hn:r:iCD" OPTION
do 
	case $OPTION in
  	h)
    		usage
    		exit 1
    		;;
  	n)
    		SERVERNAME=$OPTARG
		vhostsConf=$vhostsDir.$SERVERNAME.conf
    		;;
  	r)
    		DOCUMENTROOT=$OPTARG
    		;;
  	C)
		ACTION=1 #create virtual host
		;;
	D)
		ACTION=0 #delete virtual host
		;;
	i)
    		INTERACTIVEMODE=1
    		;;
  	?)
    		usage
    		exit
    		;;
 	esac
done

if [[ -z $SERVERNAME ]] || [[ -z $DOCUMENTROOT ]]
then
	usage
    	exit 1
fi

#Check whether is create or delete vhost
if [[ -z $ACTION ]]
then
	echo "You need to prompt for action (create -C or delete -D) --Uppercase only"
	exit 1;
fi

if [ "$ACTION" == 1 ] 
then
	### check if domain already exists
	if [ -e $vhostsConf ]; then
		echo -e 'This virtual host already exists.\nPlease Try Another name'
		exit;
	fi
	
	### check if document directory exists or not
	if ! [ -d $DOCUMENTROOT ]; then
		### Create document root
		mkdir $DOCUMENTROOT
		### Give permission to root dir
		chmod 755 $DOCUMENTROOT
		### Write test file in the new domain document root dir
		if ! echo "<?php echo phpinfo(); ?>" > $DOCUMENTROOT/phpinfo.php
		then
			echo "Error: Not able to write in file "$DOCUMENTROOT"/phpinfo.php. Please check permissions."
			exit;
		else
			echo "Successfully create website document root directory as at "$DOCUMENTROOT", Please add your site scripts."
		fi
	fi


echo $ACTION
echo $SERVERNAME
echo $DOCUMENTROOT

