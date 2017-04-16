APP_NAME=$1

echo "Create new application $APP_NAME on $HOST_URL"

userdel -r $APP_NAME
echo -e "  \xE2\x9C\x93 user"

rm -rf /var/www/$APP_NAME
echo -e "  \xE2\x9C\x93 application directory in /var/www"

# create a postgres user and database for the application
sudo -u postgres dropuser --if-exists myapp
sudo -u postgres dropdb --if-exists $APP_NAME
echo -e "  \xE2\x9C\x93 Postgres user"
# echo "Note: can safely ignore error could not change directory Permission denied"


# remove nginx configuration for the application
rm /etc/nginx/sites-enabled/$APP_NAME
rm /etc/nginx/sites-available/$APP_NAME
# test and reload nginx
nginx -t && service nginx reload
echo -e "  \xE2\x9C\x93 nginx configuration"

# enable port 80 in firewall
# ufw allow 80
