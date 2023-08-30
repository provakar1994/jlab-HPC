#!/bin/bash

## --------
## Creates symlinks for all files for a given directory
## --------
## P. Datta <pdbforce@jlab.org> CREATED 06/16/23

# arguments
sourcedir=$1  # directory that contains the original files (name w/ path)
destndir=$2   # directory where the symlinks are desired to be created (name w/ path)

pushd $destndir >/dev/null
for i in $(ls $sourcedir); do
    echo -e "Creating soft symlink for" $sourcedir/$i ".."
    ln -s $sourcedir/$i $i
done
popd >/dev/null
