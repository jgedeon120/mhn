#!/bin/bash

set -e

apt-get update
apt-get install -y libffi-dev build-essential python-pip python-dev git libssl-dev

SCRIPTS=`dirname $0`
bash $SCRIPTS/install_mongo.sh

pip install virtualenv

cd /tmp
wget https://github.com/threatstream/hpfeeds/releases/download/libev-4.15/libev-4.15.tar.gz
tar zxvf libev-4.15.tar.gz 
cd libev-4.15
./configure && make && make install
ldconfig

cd /opt
git clone https://github.com/threatstream/hpfeeds
chmod 755 -R hpfeeds
cd hpfeeds
virtualenv env
. env/bin/activate

pip install cffi
pip install pyopenssl==0.14
pip install pymongo
pip install -e git+https://github.com/rep/evnet.git#egg=evnet-dev
pip install .

apt-get install -y supervisor

cat >> /etc/supervisor/conf.d/hpfeeds-broker.conf <<EOF 
[program:hpfeeds-broker]
command=/opt/hpfeeds/env/bin/python /opt/hpfeeds/broker/feedbroker.py
directory=/opt/hpfeeds
stdout_logfile=/var/log/hpfeeds-broker.log
stderr_logfile=/var/log/hpfeeds-broker.err
autostart=true
autorestart=true
startsecs=10
EOF

supervisorctl update
