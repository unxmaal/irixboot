#!/bin/bash

## Display some useful info about the IRIX files
cd /vagrant/irix

echo "__________________  Partitioners found __________________"
find . -name "fx.*" -type f | sed 's#./#bootp():/#' | sort 

echo "__________________ Paths for Inst __________________"
find . -name dist -type d | sed 's#./#irixboot:#' | sort

echo "__________________ Paths for extra bundles __________________"
find . -name "*.tardist" | sed 's#./#irixboot:#' | sort

exit 0