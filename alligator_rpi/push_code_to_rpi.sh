# /bin/bash

# Copy the content from $PI_FOLDER to the raspberry through scp

PI_ADDR='192.168.0.111'
PI_USER='pi'
PI_FOLDER='~/workspace/alligator'

scp -rp * $PI_USER@$PI_ADDR:$PI_FOLDER

