#!/bin/sh -e
# script by Manfred Bergmann in 2006
#

# dependencies for this script are:
# either "BuildSWORDFromPointRelease.sh" or "BuildSWORDFromSVNTrunk.sh" have been executed in "fat" mode and
# successfully created a "build_lib" folder with directories: "ppc_inst" and "intel_inst"

BDIR=.
SWORDBUILD=$BDIR/build_lib
PPCPREFIX=$SWORDBUILD/ppc_inst
INTELPREFIX=$SWORDBUILD/intel_inst
RESULTPREFIX=$SWORDBUILD/result_inst

# Create install dirs if they doesn't exist
if [ ! -d $SWORDBUILD ]; then
    echo "build folder doesn't exist!\n"
    exit 1
fi
if [ ! -d $PPCPREFIX ]; then
    echo "ppc installation folder doesn't exist!\n"
    exit 1
fi
if [ ! -d $INTELPREFIX ]; then
    echo "intel installation folder doesn't exist!\n"
    exit 1
fi
if [ ! -d $RESULTPREFIX ]; then
    echo "result(fat) installation folder doesn't exist!\n"
    exit 1
fi

BINDESTINATION=$RESULTPREFIX/bin
if [ -d $BINDESTINATION ]; then
    rm $BINDESTINATION
fi
mkdir $BINDESTINATION

function callLipo {
    lipo -create $INTELPREFIX/bin/$1 $PPCPREFIX/bin/$1 -output $BINDESTINATION/$1    
}

callLipo imp2gbs
callLipo imp2ld
callLipo imp2vs
callLipo installmgr
callLipo mod2imp
callLipo mod2osis
callLipo mod2vpl
callLipo mod2zmod
callLipo osis2mod
callLipo tei2mod
callLipo vpl2mod
callLipo vs2osisref
callLipo vs2osisreftxt
callLipo xml2gbs
