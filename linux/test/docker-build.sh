#!/bin/bash

if [ $# -lt 1 ]; then
	echo "USAGE: `basename $0` distribution"
	exit 2
fi

OMEROVER=${OMEROVER:-latest}
JAVAVER=${JAVAVER:-openjdk11}
ICEVER=${ICEVER:-ice36}
PGVER=${PGVER:-pg11}

set -e

rm -rf omero-install-test
mkdir omero-install-test
cp ../*.sh ../*.env ../*init.d ../*.service omero-install-test
zip -r $1/omero-install-test.zip omero-install-test
rm -rf omero-install-test

IMAGE=omero_install_test_${1%*/}
echo "Building image $IMAGE"

docker build -t $IMAGE --no-cache --build-arg OMEROVER=${OMEROVER} \
	--build-arg JAVAVER=${JAVAVER} --build-arg ICEVER=${ICEVER} \
	--build-arg PGVER=${PGVER} $1

if [[ "$1" =~ "centos7" ]]; then
	echo "Test this image by running ./test_services.sh"
else
	echo "Test this image by running docker run -it [...] $IMAGE"
fi
