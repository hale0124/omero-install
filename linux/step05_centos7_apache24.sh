#!/bin/bash

#start-copy
cp setup_omero_apache24.sh ~omero
#end-copy

#start-install
yum -y install httpd mod_wsgi

# Install OMERO.web requirements
file=~omero/OMERO.server/share/web/requirements-py27-apache.txt
p=apache
# introduce in 5.2.0
if [ -f $file ]; then
	pip install -r $file
else
	#for version 5.1.x
	p=apache-wsgi
fi

#start-setup-as-omero
# See setup_omero_apache.sh for the apache config file creation
su - omero -c "bash -eux setup_omero_apache24.sh $p"
#end-setup-as-omero

cp ~omero/OMERO.server/apache.conf.tmp /etc/httpd/conf.d/omero-web.conf

rm -rf /run/httpd/* /tmp/httpd*

systemctl enable httpd.service
if [ ! "${container:-}" = docker ]; then
    systemctl start httpd
fi