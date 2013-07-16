#! /usr/bin/env bash
xset q | grep Caps | awk '{print $2$3, $4, $6$7, $8}'
