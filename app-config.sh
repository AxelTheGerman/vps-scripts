# THIS SHOULD BE RUN AS APP USER NOT AS ROOT
if [[ `whoami` == "root" ]]; then
  echo "Do not run as root"
  exit 1
fi

RUBY_VERSION=2.4.0


# Install RVM
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc

rvm install $RUBY_VERSION --autolibs=read-fail
rvm --default use $RUBY_VERSION
gem update --system
gem install bundler

# generate SSH keypair without password as deployment key
ssh-keygen -N "" -f ~/.ssh/id_rsa
ssh-keygen -y -f ~/.ssh/id_rsa

