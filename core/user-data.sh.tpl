#!/bin/bash
curl https://github.com/bculberson.keys > /home/ec2-user/.ssh/rsa-2021-01-15.pub
chown ec2-user: /home/ec2-user/.ssh/*
chmod 400 /home/ec2-user/.ssh/rsa-2021-01-15.pub
cat /home/ec2-user/.ssh/rsa-2021-01-15.pub >> /home/ec2-user/.ssh/authorized_keys
amazon-linux-extras install -y epel
yum -y update
yum install -y jq docker xfsprogs tor golang git
service docker start
systemctl enable docker
usermod -a -G docker ec2-user
groupadd bitcoin
useradd -g bitcoin bitcoin
usermod -a -G docker bitcoin
usermod -a -G toranon bitcoin

fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

aws s3 cp s3://${start_bucket}/bitcoin-0.21.0-x86_64-linux-gnu.tar.gz /root/bitcoin.tar.gz
pushd /root && tar xzf /root/bitcoin.tar.gz && popd
install -m 0755 -o root -g root -t /usr/local/bin /root/bitcoin-0.21.0/bin/*

export NICK=`hostname | sed 's/\.//g; s/\-//g;' | cut -c -19`
echo "ControlSocket /run/tor/control" > /etc/tor/torrc
echo "ControlSocketsGroupWritable 1" >> /etc/tor/torrc
echo "CookieAuthentication 1" >> /etc/tor/torrc
echo "CookieAuthFile /run/tor/control.authcookie" >> /etc/tor/torrc
echo "CookieAuthFileGroupReadable 1" >> /etc/tor/torrc
echo "SOCKSPort 0" >> /etc/tor/torrc
echo "ControlPort 9051" >> /etc/tor/torrc
echo "ORPort 9001" >> /etc/tor/torrc
echo "Nickname $NICK" >> /etc/tor/torrc
echo "ExitRelay 0" >> /etc/tor/torrc
service tor start
systemctl start tor

mkdir /home/bitcoin/.bitcoin
echo "datadir=/data" > /home/bitcoin/.bitcoin/bitcoin.conf
echo "server=1" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcbind=0.0.0.0" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcallowip=0.0.0.0/0" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcport=8332" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcuser=bitcoin" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcpassword=${password}" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "txindex=1" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "dbcache=4096" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "rpcworkqueue=100" >> /home/bitcoin/.bitcoin/bitcoin.conf
echo "maxconnections=20" >> /home/bitcoin/.bitcoin/bitcoin.conf
chown -R bitcoin:bitcoin /home/bitcoin/.bitcoin

mkfs -t xfs /dev/nvme1n1
mkdir /data
mount /dev/nvme1n1 /data
cp /etc/fstab /etc/fstab.orig
UUID=`blkid | grep nvme1n1 | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p'`
echo "UUID=$UUID  /data  xfs  defaults,nofail  0  2" >> /etc/fstab
chown -R bitcoin:bitcoin /data

aws --region us-west-2 s3 cp s3://${start_bucket}/start.sh /home/bitcoin/start.sh
chmod 700 /home/bitcoin/start.sh
chown bitcoin:bitcoin /home/bitcoin/start.sh

echo "@reboot /usr/local/bin/bitcoind -daemon -conf=/home/bitcoin/.bitcoin/bitcoin.conf" >> mycron
echo "@reboot /root/start.sh &" >> mycron
crontab -u bitcoin mycron
rm -f mycron

sudo -u bitcoin /usr/local/bin/bitcoind -daemon -conf=/home/bitcoin/.bitcoin/bitcoin.conf
sudo -u bitcoin /home/bitcoin/start.sh &

