#! /usr/bin/env bash

x1=$( cat /proc/net/dev | grep wlan0 | awk '{ print $2}' )
dt=5

while true
do
  sleep $dt

  x2=$( cat /proc/net/dev | grep wlan0 | awk '{ print $2}' )
  d=$(expr $x2 - $x1 )
  r=$(expr $d / $dt )
  rk=$(expr $r / 1024 )
  x2m=$(expr $x2 / 1073741824 )
  dk=$(expr $d / 1024 )
  pushd $HOME/.local/share/cinnamon/applets/try1@abgoyal
  cat try1.properties.in | sed -e s/DATARX/$x2m/ -e s/DATARATE/$rk/ > try1.properties
  popd
  x1=$x2

done
