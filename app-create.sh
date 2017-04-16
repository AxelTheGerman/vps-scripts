APP_NAME=$1
HOST_URL=$2

echo "Create new application $APP_NAME on $HOST_URL"

# This creates a new user for a new rails application
adduser $APP_NAME --disabled-password --gecos "" --ingroup rails-apps
cp app-config.sh /home/$APP_NAME
echo -e "  \xE2\x9C\x93 user"

mkdir -p /var/www/$APP_NAME/.ssh
cp ~/.ssh/authorized_keys /var/www/$APP_NAME/.ssh/
chown $APP_NAME /var/www/$APP_NAME/.ssh -R
chmod go-rwx /var/www/$APP_NAME/.ssh -R
echo -e "  \xE2\x9C\x93 application directory in /var/www"

# create a postgres user and database for the application
sudo -u postgres createuser $APP_NAME
sudo -u postgres createdb $APP_NAME --owner=$APP_NAME
echo -e "  \xE2\x9C\x93 Postgres user"
# echo "Note: can safely ignore error could not change directory Permission denied"



# Configure nginx

# create nginx site for the application
cat <<EOT > /etc/nginx/sites-available/$APP_NAME
upstream $APP_NAME {
  server unix:///var/www/$APP_NAME/app/shared/puma.sock fail_timeout=0;
}

server {
  listen 80;
  server_name $APP_NAME.$HOST_URL;

  root /var/www/$APP_NAME/app/current/public;

  location ~ ^/(assets)/  {
    gzip_static on; # to serve pre-gzipped version
    # Per RFC2616 - 1 year maximum expiry
    expires 1y;
    add_header Cache-Control public;
  }

  location / {
    try_files \$uri @app;
  }

  location @app {
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header Host \$http_host;
    proxy_redirect off;
    proxy_pass http://$APP_NAME;
  }
}
EOT

# enable the site configuration
ln -s /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/$APP_NAME
# test and reload nginx
nginx -t && service nginx reload
echo -e "  \xE2\x9C\x93 nginx configuration"

# enable port 80 in firewall
ufw allow 80

# # allow the app user to restart the server
# cat <<EOT >> /etc/sudoers
# # Allow app user to restart the server
# $APP_USER ALL=(ALL) NOPASSWD: /usr/sbin/service $APP_USER restart
# EOT

