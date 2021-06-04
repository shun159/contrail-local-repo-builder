#!/bin/sh

yum install -y wget
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py -P /var/www/html
python /var/www/html/get-pip.py

pip install pip2pi
yum makecache fast
mkdir -p /var/www/html/pip
cd /var/www/html/pip
pip download pyyaml==3.13
pip download configparser==3.5.0
pip download docker-compose==1.24.1
pip download pyparsing==2.4.5
pip download docker==3.7.3
pip download docker==3.7.1
pip download docker==3.4.1
pip download requests==2.20.1
pip download texttable==0.9.1
pip download dockerpty==0.4.1
pip download websocket_client==0.57.0
pip download enum34==1.1.10
pip download docopt==0.6.2
pip download jsonschema==2.6.0
pip download cached_property==1.5.1
pip download docker_pycreds==0.4.0
pip download paramiko==2.7.1
pip download idna==2.7
pip download chardet==3.0.4
pip download urllib3==1.24.3
pip download certifi==2020.4.5.1
pip download functools32==3.2.3-2
pip download PyNaCl==1.3.0
pip download cryptography==2.9.1
pip download kazoo==2.7.0
mkdir -p /var/www/html/pip/simple
dir2pi /var/www/html/pip
cd /var/www/html/pip/simple
mkdir pip
cd pip
pip download pip  
pip download pip==20.3.4
echo \<a href=\'pip-20.3.4-py2.py3-none-any.whl\'\>pip-20.3.4-py2.py3-none-any.whl\</a\>\<br /\> >> index.html

