#!/bin/bash

set -e -u -x

source `pwd`/../settings.env

if [[ "darwin" == "${OSTYPE//[0-9.]/}" ]]; then
    docker run -d --privileged -p 8888:80 --name omeroinstall omero_install_test_$ENV
else
    docker run -d --name omeroinstall -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /run omero_install_test_$ENV
fi

docker inspect -f {{.State.Running}} omeroinstall

docker exec -it omeroinstall /bin/bash -c 'until [ -f /home/omero/OMERO.server/var/log/Blitz-0.log ]; do sleep 5; done; echo "File found"; exit'

docker exec -it omeroinstall /bin/bash -c 'while ! grep "OMERO.blitz now accepting connections" /home/omero/OMERO.server/var/log/Blitz-0.log; do sleep 10; done'

docker exec -it omeroinstall /bin/bash -c "service omero status -l"
docker exec -it omeroinstall /bin/bash -c "service omero-web status -l"
docker exec -it omeroinstall /bin/bash -c "su - omero -c \"/home/omero/OMERO.server/bin/omero login -s localhost -p 4064 -u root -w ${OMERO_ROOT_PASS}\""

if [[ "darwin" == "${OSTYPE//[0-9.]/}" ]]; then
  curl -I http://$(docker-machine ip omerodev):8888/webclient
  WEB_HOST=$(docker-machine ip omerodev):8888 ./test_login_to_web.sh
else
  curl -I http://`docker inspect --format '{{ .NetworkSettings.IPAddress }}' omeroinstall`/webclient
  WEB_HOST=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' omeroinstall` ./test_login_to_web.sh
fi

docker stop omeroinstall
docker rm omeroinstall
# Sadly, no test for Windows or OS X here.