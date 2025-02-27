#!/bin/bash
set -e

export EFSS=cloud.pondersource.org
export REVA=mesh.pondersource.org

echo Please edit this file and run the commands one-by-one so you can check if it all works
exit 0

apt install -y certbot docker.io
certbot certonly --standalone
git clone https://github.com/cs3org/ocm-test-suite
cd ocm-test-suite
./gitpod-init.sh
docker network create testnet

export REPO_ROOT=`pwd`
[ ! -d "./scripts" ] && echo "Directory ./scripts DOES NOT exist inside $REPO_ROOT, are you running this from the repo root?" && exit 1

function waitForPort {
  x=$(docker exec -it $1 ss -tulpn | grep $2 | wc -l)
  until [ $x -ne 0 ]
  do
    echo Waiting for $1 to open port $2, this usually takes about 10 seconds ... $x
    sleep 1
    x=$(docker exec -it $1 ss -tulpn | grep $2 | wc -l)
  done
  echo $1 port $2 is open
}

docker run -d --network=testnet -e MARIADB_ROOT_PASSWORD=eilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek --name=maria1.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
docker run -d --network=testnet -p 443:443 -e HOST=$EFSS --name=nc1.docker nc1

docker container cp /etc/letsencrypt/archive/$EFSS/fullchain1.pem nc1.docker:/tls/nc1.crt
docker container cp /etc/letsencrypt/archive/$EFSS/privkey1.pem nc1.docker:/tls/nc1.key
docker restart nc1.docker
docker exec -it nc1.docker sed -i "13 i\      5 => '$EFSS'," /var/www/html/config/config.php

waitForPort maria1.docker 3306
waitForPort nc1.docker 443

docker exec -e DBHOST=maria1.docker -e USER=einstein -e PASS=relativity  -u www-data nc1.docker sh /init.sh
docker exec maria1.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://$REVA/');"
docker exec maria1.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek nextcloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-1');"

echo Now you should be able to log in at https://$EFSS as einstein / relativity.