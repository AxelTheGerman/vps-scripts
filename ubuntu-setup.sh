# Download and install latest OS updates
apt-get update && apt-get upgrade -y

# Configure local timezone
# US/Pacific US/Eastern US/Central US/Mountain
ln -fs /usr/share/zoneinfo/US/Pacific /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

# Disable SSH password authentication
sed -i -e 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i -e 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# Check open ports - should only be SSH
netstat --listening --tcp
echo "the above should only show SSH ports being open"


# Enable Ubuntu firewall and allow SSH
ufw allow 22
ufw logging off
ufw enable -y
ufw status


# Install Postgres
add-apt-repository "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.6 libpq-dev -y
# disable local port access - local socket is enough for rails
sed -i -e 's/^host/#host/g' /etc/postgresql/9.*/main/pg_hba.conf


# Web server setup - nginx
apt-get install nginx -y
# Disable default page
rm /etc/nginx/sites-enabled/default



# Ruby on rails setup
apt-get install git nodejs rng-tools -y



# Install RVM dependencies
apt-get install g++ gcc make libyaml-dev libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev libgmp-dev libreadline6-dev -y
# disable rdoc and ri for gem installs
echo "gem: --no-rdoc --no-ri" >> /etc/gemrc

# create a group to bundle all application users
addgroup rails-apps

echo "FINISHED SERVER SETUP"
