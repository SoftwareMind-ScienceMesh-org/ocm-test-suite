#!/bin/bash
set -e

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

docker run --restart=always -d --network=testnet --name=revaoc1.docker -v $REPO_ROOT/reva:/reva -e HOST=revaoc1 revad
docker run --restart=always -d --network=testnet -e MARIADB_ROOT_PASSWORD=eilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek --name=maria1.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
echo mounting $REPO_ROOT/core/apps/files_sharing:/var/www/html/apps/files_sharing in oc1
docker run --restart=always -d --network=testnet --name=oc1.docker -v $REPO_ROOT/core/apps/files_sharing:/var/www/html/apps/files_sharing -v $REPO_ROOT/oc-sciencemesh:/var/www/html/apps/sciencemesh oc1
docker run --restart=always -d --network=testnet --name=revaoc2.docker -v $REPO_ROOT/reva:/reva -e HOST=revaoc2 revad
docker run --restart=always -d --network=testnet -e MARIADB_ROOT_PASSWORD=eilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek --name=maria2.docker mariadb --transaction-isolation=READ-COMMITTED --binlog-format=ROW --innodb-file-per-table=1 --skip-innodb-read-only-compressed
echo mounting $REPO_ROOT/core/apps/files_sharing:/var/www/html/apps/files_sharing in oc2
docker run --restart=always -d --network=testnet --name=oc2.docker -v $REPO_ROOT/core/apps/files_sharing:/var/www/html/apps/files_sharing -v $REPO_ROOT/oc-sciencemesh:/var/www/html/apps/sciencemesh oc2
docker run --restart=always -d --network=testnet --name=meshdir.docker  -v $REPO_ROOT/ocm-stub:/ocm-stub stub
docker run --restart=always -d --name=firefox -p 5800:5800 -v /tmp/shm:/config:rw --network=testnet --shm-size 2g jlesage/firefox:v1.17.1

waitForPort maria1.docker 3306
waitForPort oc1.docker 443
docker exec -e DBHOST=maria1.docker -e USER=einstein -e PASS=relativity  -u www-data oc1.docker sh /init.sh
docker exec maria1.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://revaoc1.docker/');"
docker exec maria1.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-1');"
docker exec maria1.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'meshDirectoryUrl', 'https://meshdir.docker/meshdir');"

waitForPort maria2.docker 3306
waitForPort oc2.docker 443
docker exec -e DBHOST=maria2.docker -e USER=marie -e PASS=radioactivity -u www-data oc2.docker sh /init.sh
docker exec maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'iopUrl', 'https://revaoc2.docker/');"
docker exec maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'revaSharedSecret', 'shared-secret-2');"
docker exec maria2.docker mariadb -u root -peilohtho9oTahsuongeeTh7reedahPo1Ohwi3aek owncloud -e "insert into oc_appconfig (appid, configkey, configvalue) values ('sciencemesh', 'meshDirectoryUrl', 'https://meshdir.docker/meshdir');"

echo Now browse to http://ocmhost:5800 and inside there to https://oc1.docker
echo Log in as einstein / relativity
echo Go to the ScienceMesh app and generate a token
echo And click 'View token' to go to the meshdir server.
