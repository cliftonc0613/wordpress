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
echo -e "${BYellowTerm} Wordpress Container Configuration Script ${NTerm}"
echo -e "${BGreenTerm} You can hit enter on any of the following fields to accept the default values. ${NTerm}"

# Set variable for the while loop
LOOP="true"

# While the LOOP variable is true, loop through the questions below. This will allow for a re-think
while [ "$LOOP" = "true" ] 
do
        echo -e "${GreyTerm} Wordpress instance domain name (without the www) {example.com} : ${RedTerm} [default:wordpress.local] ${NTerm}"
        read -e FQDN
		if [ "$FQDN" = "" ]; then
                        FQDN="wordpress.local"
                fi
        echo -e "\n"

	echo -e "${GreyTerm} Root MySQL password: ${RedTerm} [default:P@ssw0rd] ${NTerm}"
        read -e MYSQLPASS
        	if [ "$MYSQLPASS" = "" ]; then
                        MYSQLPASS="P@ssw0rd"
                fi
	echo -e "\n"
	
	echo -e "${GreyTerm} Database Server host name or IP address where the Wordpress database will reside: ${RedTerm} [default:localhost] ${NTerm}"
        read -e DBHOST
                if [ "$DBHOST" = "" ]; then
                        DBHOST="localhost"
                fi
        echo -e "\n"

	echo -e "${GreyTerm} MySQL Wordpress database name: ${RedTerm} [default:wordpress] ${NTerm}"
        read -e DATABASE
		if [ "$DATABASE" = "" ]; then
			DATABASE="wordpress"
		fi
        echo -e "\n"

        echo -e "${GreyTerm} MySQL Username that Wordpress will use to connect to the Wordpress database: ${RedTerm} [default:admin] ${NTerm}"
        read -e USER
        	if [ "$USER" = "" ]; then
                        USER="admin"
                fi
	echo -e "\n"

	echo -e "${GreyTerm} Password for the new MySQL Wordpress database user: ${RedTerm} [default:P@ssw0rd] ${NTerm}"
        read -e USERPASS
        	if [ "$USERPASS" = "" ]; then
                        USERPASS="P@ssw0rd"
                fi
	echo -e "\n"

	echo -e "${GreyTerm} Phrase to be used for Wordpress auth cookies: ${RedTerm} [default:Check...] ${NTerm}"
        read -e WPKEY
		if [ "$WPKEY" = "" ]; then
                        WPKEY="Check us out at www.appcontainers.com"
                fi
        echo -e "\n"

	echo -e "${RedTerm} Container Name (specified at docker run time): ${RedTerm} [default:wordpress] ${NTerm}"
        read -e RUNNAME
		if [ "$RUNNAME" = "" ]; then
                        RUNNAME="wordpress"
                fi
        echo -e "\n"

	echo -e "${GreyTerm} Wordpress container Host TCP Port: ${RedTerm} [default:80] ${NTerm}"
        read -e PORT
                if [ "$PORT" = "" ]; then
                        PORT="80"
                fi
        echo -e "\n"

        echo -e "${BYellowTerm} You entered the following information: ${Nterm}"

	echo -e "${GreyTerm} MySQL Host:                       ${GreenTerm} \"$DBHOST\" ${NTerm}"
	echo -e "${GreyTerm} MySQL Root Password:              ${GreenTerm} \"$MYSQLPASS\" ${NTerm}"
        echo -e "${GreyTerm} Wordpress Database Name:          ${GreenTerm} \"$DATABASE\" ${NTerm}"
	echo -e "${GreyTerm} Wordpress User:                   ${GreenTerm} \"$USER\" ${NTerm}"
	echo -e "${GreyTerm} Wordpress User Password:          ${GreenTerm} \"$USERPASS\" ${NTerm}"
	echo -e "${GreyTerm} Wordpress Cookie Auth Phrase:     ${GreenTerm} \"$WPKEY\" ${NTerm}"
	echo -e "${GreyTerm} Wordpress Container Name:         ${GreenTerm} \"$RUNNAME\" ${NTerm}"
	echo -e "${GreyTerm} Wordpress Container Port:         ${GreenTerm} \"$PORT\" ${NTerm}"	

        echo -e "${BRedTerm} Is this Information correct? (y/n) ${NTerm}"
        read -e CONFIRM
        echo -e "\n"

        if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
                LOOP="false"
        fi
done

echo -e "${BYellowTerm} Starting Wordpress Container... ${NTerm}"
docker run -d -i -t \
--name $RUNNAME \
-p $PORT:80 \
-e "APP_NAME=$FQDN" \
-e "APACHE_SVRALIAS=$FQDN localhost" \
-e "MYSQL_HOST=$DBHOST" \
-e "MYSQL_PASS=$MYSQLPASS" \
-e "MYSQL_DB=$DATABASE" \
-e "APP_USER=$USER" \
-e "APP_PASS=$USERPASS" \
-e "WP_KEY=$WPKEY" \
appcontainers/wordpress

echo -e "${BGreenTerm} [Complete] ${NTerm}"
echo -e "\n"
echo -e "\n"

echo -e "Scanning for Boot2Docker Path"
sleep 1
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
echo -e "\n"
sleep 1

# Adding Host File Entry (Linux and OSX Only)
echo -e "${BRedTerm} Be sure to add the following host file entry to your machine (/etc/hosts, C:/Windows/System32/Drivers/etc/hosts) ${NTerm}"
echo "$DOCKERIP          $FQDN"
echo -e "\n"
echo -e "\n"
sleep 1

echo -e "${BYellowTerm} You can now access the Wordpress install by opening a browser and accessing the following IP via a browser ${NTerm}"

# Display the open URL
URL="http://$DOCKERIP:$PORT"
echo -e $URL

# Chill for a minute to let the container load then open it up
sleep 5

# If on a machine running Boot2Docker then auto open the application page.
if [[ $B2D != "" ]]
	then
	open $URL
fi
