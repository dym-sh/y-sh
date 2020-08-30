#!/bin/bash

# y-sh install script

## use
# bash ./install.sh

PREFIX='/usr/local'

git clone \
  https://github.com/dym-sh/y-sh/ \
  $PREFIX/src/y-sh/

cd $PREFIX/src/y-sh/
chmod +x ./y.sh
ln -s ./y.sh $PREFIX/bin/y
