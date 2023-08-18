#!/bin/bash

# Enable logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install Git
echo "Installing Git"
yum update -y
yum install git -y
yum install iptables -y

# Install NodeJS
echo "Installing NodeJS"
touch .bashrc
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. /.nvm/nvm.sh
nvm install --lts

# Clone website code
echo "Cloning website"
mkdir -p /demo-website
cd /demo-website
git clone https://github.com/academind/aws-demos.git .
cd dynamic-website-basic

# Install dependencies
echo "Installing dependencies"
sudo npm install

# Create data directory (later => EBS)
echo "Configuring and mounting EBS volume"
if [ ! -d "/demo/data" ];
then  
    sudo mkfs -t xfs /dev/sdh
    echo "Creating data directory & file"
    mkdir -p /demo/data
    echo '{"topics": []}' | tee "/demo/data/data-storage.json"    
fi 

sudo su
echo "/dev/sdh /demo xfs defaults,nofail  0  2" >> /etc/fstab 
mount -a
exit

# Forward port 80 traffic to port 3000
echo "Forwarding 80 -> 3000"
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 3000

# Install & use pm2 to run Node app in background
echo "Installing & starting pm2"
sudo npm install pm2@latest -g
sudo pm2 start app.js
