#!/bin/bash
KEY_FILE_NAME=/home/ec2-user/.ssh/rsa-2021-01-15.pub
curl https://github.com/bculberson.keys > "$KEY_FILE_NAME"
chown ec2-user: /home/ec2-user/.ssh/*
chmod 400 "$KEY_FILE_NAME"
cat "$KEY_FILE_NAME" >> /home/ec2-user/.ssh/authorized_keys
yum -y update
yum -y install xfsprogs
mkfs -t xfs /dev/nvme1n1
mkdir /data
mount /dev/nvme1n1 /data
cp /etc/fstab /etc/fstab.orig
UUID=`blkid | grep nvme1n1 | sed -n 's/.*UUID=\"\([^\"]*\)\".*/\1/p'`
echo "UUID=$UUID  /data  xfs  defaults,nofail  0  2" >> /etc/fstab
curl -o bitcoin.tar.gz https://bitcoin.org/bin/bitcoin-core-0.21.0/bitcoin-0.21.0-aarch64-linux-gnu.tar.gz
tar xzf bitcoin.tar.gz
install -m 0755 -o root -g root -t /usr/local/bin bitcoin-0.21.0/bin/*
mkdir /root/.bitcoin
echo "datadir=/data" > ~/.bitcoin/bitcoin.conf
echo "server=1" >> ~/.bitcoin/bitcoin.conf
echo "rpcbind=0.0.0.0" >> ~/.bitcoin/bitcoin.conf
echo "rpcallowip=0.0.0.0/0" >> ~/.bitcoin/bitcoin.conf
echo "rpcport=8332" >> ~/.bitcoin/bitcoin.conf
echo "rpcuser=bitcoin" >> ~/.bitcoin/bitcoin.conf
echo "rpcpassword=${password}" >> ~/.bitcoin/bitcoin.conf
echo "@reboot /usr/local/bin/bitcoind -daemon -conf=/root/.bitcoin/bitcoin.conf" >> mycron
crontab mycron
rm mycron
/usr/local/bin/bitcoind -daemon -conf=/root/.bitcoin/bitcoin.conf