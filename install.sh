#!/bin/bash

# y-sh install script

## use
# bash ./install.sh

PREFIX='/usr/local/'

git clone --depth 1 \
  https://github.com/dym-sh/y-sh.git \
  $PREFIX/src/y-sh/

chmod +x $PREFIX/src/y-sh/y.sh

ln -s $PREFIX/src/y-sh/y.sh \
      $PREFIX/bin/y
