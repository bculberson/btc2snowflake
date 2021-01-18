#!/bin/bash
curl https://github.com/bculberson.keys > /home/ec2-user/.ssh/rsa-2021-01-15.pub
chown ec2-user: /home/ec2-user/.ssh/*
chmod 400 /home/ec2-user/.ssh/rsa-2021-01-15.pub
cat /home/ec2-user/.ssh/rsa-2021-01-15.pub >> /home/ec2-user/.ssh/authorized_keys
yum -y update
yum install -y jq docker xfsprogs
service docker start
usermod -a -G docker ec2-user
# mkfs -t xfs /dev/nvme1n1
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
echo "txindex=1" >> ~/.bitcoin/bitcoin.conf
/usr/local/bin/bitcoind -daemon -conf=/root/.bitcoin/bitcoin.conf
aws --region us-west-2 s3 cp s3://${start_bucket}/start.sh /root/start.sh
chmod 700 /root/start.sh
echo "@reboot /usr/local/bin/bitcoind -daemon -conf=/root/.bitcoin/bitcoin.conf" >> mycron
echo "@reboot /root/start.sh > /var/log/rpc2stage.log &" >> mycron
crontab mycron
rm mycron
/root/start.sh > /var/log/rpc2stage.log &