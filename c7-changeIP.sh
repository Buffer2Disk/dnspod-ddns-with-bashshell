#!/usr/bin/env bash
#centos7换ip脚本，centos6也适用，dns会被重置，可以自己去改回来
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
# maybe centos6 is also suitable for this script
dhclient -r -v
rm -rf /var/lib/dhclient/*
#reset dhclient will change dns to default , pls modify  dns to whatever you want
dhclient -v
service network restart

