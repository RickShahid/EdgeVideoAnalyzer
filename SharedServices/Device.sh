#!/bin/bash

# create the local group and user for the edge module
sudo groupadd -g 1010 localedgegroup
sudo useradd --home-dir /home/localedgeuser --uid 1010 --gid 1010 localedgeuser
sudo mkdir -p /home/localedgeuser

# give the local user access
sudo chown -R localedgeuser:localedgegroup /home/localedgeuser/

# set up folders for use by the Video Analyzer module
sudo mkdir -p /var/lib/videoanalyzer
sudo chown -R localedgeuser:localedgegroup /var/lib/videoanalyzer/
sudo mkdir -p /var/lib/videoanalyzer/tmp/
sudo chown -R localedgeuser:localedgegroup /var/lib/videoanalyzer/tmp/
sudo mkdir -p /var/lib/videoanalyzer/logs
sudo chown -R localedgeuser:localedgegroup /var/lib/videoanalyzer/logs

# output folder for file sink
sudo mkdir -p /var/media
sudo chown -R localedgeuser:localedgegroup /var/media/
