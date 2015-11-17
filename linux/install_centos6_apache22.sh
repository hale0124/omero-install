#!/bin/bash

set -e -u -x

OMEROVER=omero
#OMEROVER=omerodev

source settings.env

bash -eux step01_centos6_deps.sh

bash -eux step02_all_setup.sh
bash -eux step03_all_postgres.sh

cp settings.env step04_all_$OMEROVER.sh ~omero
cp setup_omero_apache.sh ~omero

su - omero -c "bash -eux step04_all_$OMEROVER.sh"

su - omero -c "bash -eux setup_omero_apache.sh"
bash -eux step05_centos6_apache22.sh

bash -eux setup_centos6_selinux.sh

#If you don't want to use the init.d scripts you can start OMERO manually:
#su - omero -c "OMERO.server/bin/omero admin start"
#su - omero -c "OMERO.server/bin/omero web start"

bash -eux step06_centos6_daemon_no_web.sh

bash -eux step07_all_perms.sh

bash -eux step08_all_cron.sh

#service omero start
#service omero-web start
