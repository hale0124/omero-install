#!/bin/bash

set  -x

VENV_SERVER=${VENV_SERVER:-/opt/omero/server/venv3}
#start-ice-py
# Create a virtual env and activate it
python3 -mvenv $VENV_SERVER

# Install the Ice Python binding
$VENV_SERVER/bin/pip install https://github.com/ome/zeroc-ice-py-debian9/releases/download/0.2.0/zeroc_ice-3.6.5-cp35-cp35m-linux_x86_64.whl

# Install pytables
$VENV_SERVER/bin/pip install "tables==3.4.4"
#end-ice-py
