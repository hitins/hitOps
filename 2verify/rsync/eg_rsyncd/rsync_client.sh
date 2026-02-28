#!/bin/sh

rsync -avR --delete --password-file=rsync_remote.se --exclude=/dev /works  one@192.168.1.2::server
