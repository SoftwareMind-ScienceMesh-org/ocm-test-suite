#!/bin/bash
set -e
#apt-get update
#apt-get install -yq docker.io
docker ps

#git clone https://github.com/sciencemesh/nc-sciencemesh
#git clone https://github.com/cs3org/reva
#/bin/bash ./install-reva.sh
#git clone https://github.com/cs3org/ocm-test-suite

git clone https://github.com/cs3org/ocm-test-suite
cd ocm-test-suite
git checkout main
./gitpod-init.sh

#git clone https://github.com/michielbdejong/ocm-stub

#/bin/bash ./gencerts.sh
#/bin/bash ./rebuild.sh
/bin/bash ./debug.sh

# There are really three ways to add a tester to the testnet,
# see debug.sh for more details.
