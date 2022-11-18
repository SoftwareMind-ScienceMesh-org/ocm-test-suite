# OCM Test Suite
This test suite tests various implementations of [Open Cloud Mesh (OCM)](https://github.com/cs3org/OCM-API) against each other.


## Running in Github Actions

The current main branch of this repo runs a github action to test the share-with flow from each of the following servers
to the ocm-stub server:
* ocm-stub
* Nextcloud
* OC-10
* Reva

## Running in CDE
There is a .gitpod.yml file that points to a gitpod-init.sh script and a gitpod-command.sh script. Use it to your liking
with GitPod, GitHub Codespaces, or similar!

## Running interactively on Digital Ocean (or similar)
The following script sets up the testnet on an empty Ubuntu droplet on Digital Ocean (this takes about 15 minutes):
```sh
./doctl-up.sh
```

Then from your laptop connect using VNC (e.g. open `vnc://ocmhost` in Safari), password 1234, you should see an Ubuntu desktop.
You can test that you made it into the testnet by opening Start->Internet->Firefox Web Browser and browsing to https://nc1.docker, once you
click 'accept the risk and continue', you should be able to log in to Nextcloud with 'alice'/'alice123'.

Now to run the tests, open a terminal (Start->System Tools->LXTerminal) and type (sudo password for user 'tester' is '1234'):
```sh
/bin/bash /ubuntu-init-script.sh
cd ~/ocm-test-suite
npm run debug
```

## Known Issues
NB: We recently switched from vps-hosted to in-Docker, and the test suite is still a bit young.

Please join https://gitter.im/cs3org/OCM and ping @michielbdejong if you want more up-to-date info and guidance.


There are tests for four flows:

### Public-link flow (login first)
In the public-link flow, the provider gives the consumer a public link, and the consumer clicks 'save to my personal cloud' on there.
In this flow, it is assumed that the consumer is already logged in to their personal cloud account before clicking 'save to my personal cloud' on the public link. After clicking, the consumer is redirected to their personal cloud account GUI, accepts the share, and then leaves it again.

### Public-link flow (login after)
Same as the previous flow, except the consumer is not logged in to their own personal cloud account yet when they get redirected to it
from the public link.

### Share-with flow
In this flow, the provider uses their own personal cloud account GUI to share a resource with the consumer, and the consumer notices this from the notification in their personal cloud acccount GUI, accepts the share, then leaves it again.

### Invite-first flow
Currently only supported by Reva, Nextcloud+Reva, and Stub. First an invite code is shared as a sort of friend request between sender and receiver. Then share-with flow is followed after that.
