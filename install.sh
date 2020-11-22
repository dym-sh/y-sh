#!/bin/bash

# y install script

## use
# bash ./install.sh

PREFIX='~/.local'

git clone --depth 1 \
  https://dym.sh/y/ \
  $PREFIX/src/y/

chmod +x $PREFIX/src/y/y.sh

ln -s $PREFIX/src/y/y.sh \
      $PREFIX/bin/y
