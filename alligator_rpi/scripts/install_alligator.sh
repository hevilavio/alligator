# /bin/bash

INSTALL_DIR=/usr/local/bin/alligator/
LOG_FILE=/tmp/alligator.log
USER_TO_INSTALL='pi'

set -e

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "cleaning previous installation..."
rm -rfv $INSTALL_DIR
mkdir $INSTALL_DIR && cp ../python_code/*.py $INSTALL_DIR
chmod +x "$INSTALL_DIR"main.py

echo "creating log file..."
echo "<<installation>>" > $LOG_FILE
chown $USER_TO_INSTALL $LOG_FILE

echo "creating start script..."
rm -fv /etc/init.d/alligator*;
cp alligator.sh /etc/init.d/alligator
chmod +x /etc/init.d/alligator

echo "Script finished!"
echo "To start the service, use:"
echo "sudo /etc/init.d/alligator start"