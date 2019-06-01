#!/usr/bin/env bash

set -xe

sudo apt-get -qq clean
sudo apt-get -qq update
sudo apt-get -qq install -y python-pip
sudo pip install ansible==2.7.11
