#!/bin/bash
clear
echo "Make sure you double check before hitting enter! Only one shot at these!"

read -t 1 -n 10000 discard 
read -e -p "Server IP Address : " ip
read -t 1 -n 10000 discard 
read -e -p "Masternode Private Key (e.g. 28L11p9KSUQMyw5z6QYay8q68WnNxuH5BbeyAhWutwav1TSNC4S # THE KEY YOU GENERATED EARLIER) : " key

clear
echo "Updating system and installing required packages..."
sleep 5

# update packages and upgrade Ubuntu
cd ~
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y autoremove
sudo apt-get -y install wget nano htop git
sudo apt-get -y install libzmq3-dev
sudo apt-get -y install libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev
sudo apt-get -y install libevent-dev

sudo apt -y install software-properties-common

sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get -y update
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev

sudo apt-get -y install libminiupnpc-dev

sudo apt-get -y install fail2ban
sudo service fail2ban restart

sudo apt-get install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 13058/tcp
sudo ufw --force enable

#Generating Random Passwords
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
password2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

#Installing Daemon
cd ~

#sudo rm reden_ubuntu16_1.0.0_linux.gz
#wget https://github.com/NicholasAdmin/Reden/releases/download/Wallet/reden_ubuntu16_1.0.0_linux.gz
#sudo tar -xzvf reden_ubuntu16_1.0.0_linux.gz --strip-components 1 --directory /usr/bin
#sudo rm reden_ubuntu16_1.0.0_linux.gz

# Copy binaries to /usr/bin
sudo cp RedenMasternodeSetup/Reden-v1.0-Ubuntu16.04/reden* /usr/bin/

sudo chmod 775 /usr/bin/reden*

#Starting daemon first time
redend -daemon
echo "sleep for 10 seconds..."
sleep 10
reden-cli stop

#Create eden.conf
echo '
rpcuser='$password'
rpcpassword='$password2'
rpcallowip=127.0.0.1
onlynet=ipv4
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=32
externalip='$ip'
masternode=1
masternodeprivkey='$key'
' | sudo -E tee ~/.redencore/reden.conf >/dev/null 2>&1

#Starting daemon second time
redend

sleep 10

#Starting coin
(
  crontab -l 2>/dev/null
  echo '@reboot sleep 30 && redend'
) | crontab

cd ~

clear

echo "Coin setup complete..."
echo ""
echo "Now, you need to finally issue a start command for your masternode in the following order:"
echo "1) Wait for the node wallet on this VPS to sync with other nodes on the network. Eventually the IsSynced status will change to 'true'. It may take several minutes."
echo "2) Go to your windows wallet (hot wallet with your Reden funds) and from debug console (Tools->Debug Console) enter:"
echo "    masternode start-alias <mymnalias>"
echo ""
echo "where <mymnalias> is the name of your masternode alias (without brackets) as it was entered in the masternode.conf file."
echo "once completed please return to this VPS console and wait for the masternode status to change to 'Started'. This will indicate that your masternode is fully functional."
echo ""
echo "Your masternode is currently syncing in the background. When you press a key to continue, this message will self-destruct, so please memorize it!"
echo "The following screen will display current status of this masternode and it's synchronization progress. The data will update in real time every 10 seconds. You can interrupt it at any moment by Ctrl-C."
echo ""
echo ""

read -p "Press any key to continue... " -n1 -s
cd ~

echo ""
echo "Here are some useful tools and commands for troubleshooting your masternode:"
echo "(copy/paste without $)"
echo ""
echo "Redend debug log showing all MN network activity in real time:"
echo "$ tail -f ~/.redencore/debug.log"
echo ""
echo "To monitor HW and system resource utilization and running processes:"
echo "$ htop "
echo ""
echo "To monitor MN state and its sync status:"
echo "$ watch -n 10 'reden-cli masternode status && reden-cli mnsync status'"
echo ""
echo "If you found this script and MN setup guide helpful, please donate REDEN to: RCdYg5yq3YfymwrZi8EMBSFHxcwR7acniS"

watch -n 10 'reden-cli masternode status && reden-cli mnsync status'

