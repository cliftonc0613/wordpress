#!/bin/bash

# Set Colors we will use for different prompts
# Yellow and Bold Yellow
YellowTerm='\e[0;33m'
BYellowTerm='\e[1;33m'

# Red and Bold Red
RedTerm='\e[0;31m'
BRedTerm='\e[1;31m'

# Green and Bold Green
GreenTerm='\e[0;32m'
BGreenTerm='\e[1;32m'

# Grey and Bold Grey
GreyTerm='\e[0;37m'
BGreyTerm='\e[1;37m'

# Normal Term
NTerm='\e[0m'

# New Line
echo -e "\n"

# Message to user
echo -e "${BYellowTerm} Wordpress Container Configuration Script  ${NTerm}"

# Set variable for the while loop
LOOP="true"

# While the LOOP variable is true, loop through the questions below. This will allow for a re-think
while [ "$LOOP" = "true" ] 
do
        echo -e "${BRedTerm} Please input the wordpress instance FQDN (example.com) [without the www]: ${NTerm}"
        read -e FQDN
        echo -e "\n"

	echo -e "${BRedTerm} Please input a root MySQL password: ${NTerm}"
        read -e MYSQLPASS
        echo -e "\n"
	
	echo -e "${BRedTerm} Please type the Database Server host name or IP where the wordpress db will reside [default:localhost]:  ${NTerm}"
        read -e DBHOST
                if [ "$DBHOST" = "" ]; then
                        DBHOST="localhost"
                fi
        echo -e "\n"

	echo -e "${BRedTerm} Please select a name for mysql wordpress database [default:wordpress]:  ${NTerm}"
        read -e DATABASE
		if [ "$DATABASE" = "" ]; then
			DATABASE="wordpress"
		fi
        echo -e "\n"

        echo -e "${BRedTerm} Please type a mysql user name that wordpress will use to connect to the wordpress database: ${NTerm}"
        read -e WPUSER
        echo -e "\n"

	echo -e "${BRedTerm} Please type a password for the new mysql wordpress database user: ${NTerm}"
        read -e WPPASS
        echo -e "\n"

	echo -e "${BRedTerm} Please type a phrase, any phrase to be used for wordpress auth cookies or press enter to use the defaults ${NTerm}"
        read -e WPKEY
        echo -e "\n"
		if [ "$WPKEY" = "" ]; then
                        WPKEY="Check us out at www.appcontainers.com"
                fi

	echo -e "${BRedTerm} Please name for the container (specified at docker run time): [default:wordpress1] ${NTerm}"
        read -e RUNNAME
        echo -e "\n"
		if [ "$RUNNAME" = "" ]; then
                        RUNNAME="wordpress1"
                fi

	echo -e "${BRedTerm} Please the host port that you would like to use for the wordpress container: [default:80] ${NTerm}"
        read -e PORT
        echo -e "\n"
                if [ "$PORT" = "" ]; then
                        PORT="80"
                fi

        echo -e "${BRedTerm} You entered the following information: ${Nterm}"

	echo -e "${BYellowTerm} MySQL Host:			${BGreenTerm} \"$DBHOST\" ${NTerm}"
	echo -e "${BYellowTerm} MySQL Root Password:    	${BGreenTerm} \"$MYSQLPASS\" ${NTerm}"
        echo -e "${BYellowTerm} Wordpress Database Name:    	${BGreenTerm} \"$DATABASE\" ${NTerm}"
	echo -e "${BYellowTerm} Wordpress User:    		${BGreenTerm} \"$WPUSER\" ${NTerm}"
	echo -e "${BYellowTerm} Wordpress User Password:	${BGreenTerm} \"$WPPASS\" ${NTerm}"
	echo -e "${BYellowTerm} Wordpress Cookie Auth Phrase:	${BGreenTerm} \"$WPKEY\" ${NTerm}"
	echo -e "${BYellowTerm} Wordpress Container Name:   	${BGreenTerm} \"$RUNNAME\" ${NTerm}"
	echo -e "${BYellowTerm} Wordpress Container Port:	${BGreenTerm} \"$PORT\" ${NTerm}"	

        echo -e "${BRedTerm} Is this Information correct? (y/n) ${NTerm}"
        read -e CONFIRM

        echo -e "\n"

        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
                LOOP="false"
        fi
done

#echo -e "${BRedTerm} Would you like to build a fresh wordpress container image? (y/Y) or use an exiting image and run a new instance (n/N) ${NTerm}"
#        read -e CONFIRM
#
#        echo -e "\n"
#
#        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
#               echo -e "${BRedTerm} To build the container issue the following: ${BGreenTerm} docker build -t appcontainers/wordpress . ${NTerm}"
#		echo -e "\n"
#
#		echo -e " ${BYellowTerm} Building Wordpress Container... ${NTerm}"
#		docker build -t appcontainers/wordpress .
#		echo -e "${BGreenTerm} [Complete] ${NTerm}"
#		echo -e "\n"
#        fi

echo -e "${BYellowTerm} Starting Wordpress Container... ${NTerm}"
docker run -d -i -t \
--name $RUNNAME \
-p $PORT:80 \
-e "APP_NAME=$FQDN" \
-e "APACHE_SRVALIAS=$FQDN localhost" \
-e "MYSQL_HOST=$DBHOST" \
-e "MYSQL_PASS=$MYSQLPASS" \
-e "MYSQL_DB=$DATABASE" \
-e "WP_USER=$WPUSER" \
-e "WP_PASS=$WPPASS" \
-e "WP_KEY=$WPKEY" \
appcontainers/wordpress

echo -e "${BGreenTerm} [Complete] ${NTerm}"
echo -e "\n"

echo "Scanning for Boot2Docker Path"
B2D=`which boot2docker`

if [[ $B2D != "" ]]
        then
        echo "Boot2Docker detected, caching the boot2docker IP address"
        DOCKERIP=`boot2docker ip`
else
        echo "Boot2Docker Not Found, continuing to scan for IP"
        DOCKERIP=`ip addr | awk '/inet [0-9]/ && !/127\.0\.|172\.17/ {split($2, ip, "/"); print ip[1]; exit}'`
fi

echo -e "\n"

# Adding Host File Entry (Linux and OSX Only)
echo -e "${BRedTerm} Be sure to add the following host file entry to your machine (/etc/hosts, C:/Windows/System32/Drivers/etc/hosts) ${NTerm}"
echo "$DOCKERIP          $FQDN"
echo -e "\n"

echo -e "${BYellowTerm} You can now access the Wordpress install by opening a browser and accessing the following IP via a browser ${NTerm}"

# Display the open URL
URL="http://$DOCKERIP:$PORT"
echo $URL

# Chill for a minute to let the container load then open it up
sleep 5

# If on a machine running Boot2Docker then auto open the application page.
if [[ $B2D != "" ]]
	then
	open $URL
fi
