#!/bin/bash
set -x

# Directory where all your repositories are located:
REPODIR="~/repos"

# Package name of Survloop extension
REPONAME="survlooporg"

cd $REPODIR
rm -r zipz-repos
mkdir zipz-repos

cd $REPODIR/survloop
tar -czvf survloop.tar.gz ./src
mv survloop.tar.gz ../zipz-repos/survloop.tar.gz

cd $REPODIR/survloop-libraries
tar -czvf survloop-libraries.tar.gz ./src
mv survloop-libraries.tar.gz ../zipz-repos/survloop-libraries.tar.gz

cd $REPODIR/$REPONAME
tar -czvf $REPONAME.tar.gz ./src
mv $REPONAME.tar.gz ../zipz-repos/$REPONAME.tar.gz
