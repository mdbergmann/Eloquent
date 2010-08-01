#!/bin/sh
#
# copyright in 2009/2010 Manfred Bergmann
#
# this script will create symlinks in /usr/local/bin to the SWORD utilities in Resources/bin

echo "Creating symlinks to $1"
ln -s $1/imp2gbs /usr/local/bin/imp2gbs
ln -s $1/imp2ld /usr/local/bin/imp2ld
ln -s $1/imp2vs /usr/local/bin/imp2vs
ln -s $1/installmgr /usr/local/bin/installmgr
ln -s $1/mod2imp /usr/local/bin/mod2imp
ln -s $1/mod2osis /usr/local/bin/mod2osis
ln -s $1/mod2vpl /usr/local/bin/mod2vpl
ln -s $1/mod2zmod /usr/local/bin/mod2zmod
ln -s $1/osis2mod /usr/local/bin/osis2mod
ln -s $1/tei2mod /usr/local/bin/tei2mod
ln -s $1/vpl2mod /usr/local/bin/vpl2mod
ln -s $1/vs2osisref /usr/local/bin/vs2osisref
ln -s $1/vs2osisreftxt /usr/local/bin/vs2osisreftxt
ln -s $1/xml2gbs /usr/local/bin/xml2gbs
