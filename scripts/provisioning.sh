#! /bin/bash

touch /home/testfile.txt
sleep 30
#exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
apt update
apt-get -y install php php-mysql mariadb-server git python3 python3-pip
apt update
systemctl enable mariadb
systemctl start  mariadb
mysqladmin -u root password TiUtpgDKlbVJpXpaADrTiSfhkphDznym
mysql -u root --password=TiUtpgDKlbVJpXpaADrTiSfhkphDznym -e "quit"
mysql -u root --password=TiUtpgDKlbVJpXpaADrTiSfhkphDznym  -e  "CREATE DATABASE awsdevdays; CREATE USER  'wafdemodbuser'@'localhost' IDENTIFIED BY 'h6d7GEujNYW06idiNG1qaeuemqZWzZyO';  GRANT ALL ON awsdevdays.* TO  wafdemodbuser@localhost; FLUSH PRIVILEGES;"
export DBUSER=wafdemodbuser
export DBPASSWORD=h6d7GEujNYW06idiNG1qaeuemqZWzZyO
git clone https://github.com/aravindan-acct/petstore.git
cd petstore && pip3 install --user -r requirements.txt
pip3 install --user connexion[swagger-ui]
cd api_server/
nohup python3 -m swagger_server &
