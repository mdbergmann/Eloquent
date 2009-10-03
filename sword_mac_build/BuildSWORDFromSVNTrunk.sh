#!/bin/sh -e
# script by Manfred Bergmann in 2006
#

APP=sword
VERS=1.6.0-svn
BDIR=`pwd`

DEBUG=0
FAT=0
PPC=0
INTEL=0

# check commandline
for arg in "$@" 
do
	if [ "$arg" = "debug" ]; then
		DEBUG=1
		echo "building debug version"
	fi
	if [ "$arg" = "fat" ]; then
		FAT=1
		PPC=1
		INTEL=1
		echo "building fat version"
	fi
	if [ "$arg" = "ppc" ]; then
		PPC=1
		echo "building ppc version"
	else
		PPC=0
	fi
	if [ "$arg" = "intel" ]; then
		INTEL=1
		echo "building intel version"
	else
		INTEL=0
	fi
done

# using seperate build dirs and building in them doesn't work with sword
SWORDBUILD=$BDIR/build_lib
PPCPREFIX=$SWORDBUILD/ppc_inst
INTELPREFIX=$SWORDBUILD/intel_inst
#PPCBUILDDIR=$BDIR/ppc_build
#INTELBUILDDIR=$BDIR/intel_build
RESULTPREFIX=$SWORDBUILD/result_inst

# Create install dirs if they doesn't exist
if [ ! -d $SWORDBUILD ]; then
	mkdir -p $SWORDBUILD
fi
if [ ! -d $PPCPREFIX ]; then
	mkdir -p $PPCPREFIX
fi
if [ ! -d $INTELPREFIX ]; then
	mkdir -p $INTELPREFIX
fi
if [ ! -d $RESULTPREFIX ]; then
	mkdir -p $RESULTPREFIX
	if [ ! -d $RESULTPREFIX/lib ]; then
		mkdir -p $RESULTPREFIX/lib
	fi
fi

# Create build dirs if they doesn't exist
#if [ ! -d $PPCBUILDDIR ]; then
#	mkdir -p $PPCBUILDDIR
#fi
#if [ ! -d $INTELBUILDDIR ]; then
#	mkdir -p $INTELBUILDDIR
#fi

# delete old source dir
#/bin/rm -rf $APP-$VERS
# ungzip src
#gzip -dc $APP-$VERS.tar.gz | tar xvf -
# ==> we use svn trunk here

# add icu tools to path
export PATH="$PATH:/opt/icu-3.6/bin"
export DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH:/opt/icu-3.6/lib"

# build stuff
if [ $PPC -eq 1 ] || [ $FAT -eq 1 ]; then
    echo "building ppc version of library..."
	cd sword-trunk
#	make distclean
	./autogen.sh
	export CC=gcc
	export CXX=g++
	export SDK=/Developer/SDKs/MacOSX10.5.sdk
	if [ $DEBUG -eq 1 ]; then
		export CFLAGS="-O0 -g -arch ppc -mmacosx-version-min=10.5 -isysroot $SDK -I$SDK/usr/include -I/sw/include"
	else
	    export CFLAGS="-O2 -g0 -arch ppc -mmacosx-version-min=10.5 -isysroot $SDK -I$SDK/usr/include -I/sw/include"
	fi
	export CXXFLAGS="$CFLAGS"
	export LDFLAGS="-isysroot $SDK -Wl,-syslibroot,$SDK"
	#export PATH=$PATH:$PPCPREFIX/bin
	./configure --prefix=$PPCPREFIX --with-zlib --with-conf --with-icu --with-curl --disable-tests --disable-shared --enable-utilities
	make all install
	make clean		
	cd $BDIR
	# copy to result dir
	cp $PPCPREFIX/lib/lib$APP.a $RESULTPREFIX/lib/lib$APP-$VERS-ppc.a
    echo "building ppc version of library...done"
fi

# then build intel version to SDK 10.5
if [ $INTEL -eq 1 ] || [ $FAT -eq 1 ]; then
	#cd $APP-$VERS
	cd sword-trunk
#	make distclean
	./autogen.sh
	export CC=gcc
	export CXX=g++
	export SDK=/Developer/SDKs/MacOSX10.5.sdk
	if [ $DEBUG -eq 1 ]; then
		export CFLAGS="-O0 -g -arch i686 -mmacosx-version-min=10.5 -isysroot $SDK -I$SDK/usr/include -I/sw/include"
	else
	    export CFLAGS="-O2 -g0 -arch i686 -mmacosx-version-min=10.5 -isysroot $SDK -I$SDK/usr/include -I/sw/include"
	fi
	export CXXFLAGS="$CFLAGS"
	export LDFLAGS="-isysroot $SDK -Wl,-syslibroot,$SDK"
	#export PATH=$PATH:$INTELPREFIX/bin
	./configure --prefix=$INTELPREFIX --with-zlib --with-conf --with-icu --with-curl --enable-tests --disable-shared --enable-utilities
	make all install
	make clean		
	cd $BDIR
	# copy to result dir
	cp $INTELPREFIX/lib/lib$APP.a $RESULTPREFIX/lib/lib$APP-$VERS-intel.a

	# only for fat version
	if [ $FAT -eq 1 ]; then
		# creating result
		# build fat binary with lipo
		lipo -create $RESULTPREFIX/lib/lib$APP-$VERS-ppc.a $RESULTPREFIX/lib/lib$APP-$VERS-intel.a -output $RESULTPREFIX/lib/lib$APP-$VERS-fat.a
	fi
fi

# run runlib to update the library content
#ranlib $RESULTPREFIX/lib/*

# check which folder we can use for copying the includes and locales
TARGETPREFIX=$INTELPREFIX
if [ $INTEL -eq 1 ] || [ $FAT -eq 1 ]; then
	TARGETPREFIX=$INTELPREFIX
else
    TARGETPREFIX=$PPCPREFIX
fi

# copy include and headers
cp -r $TARGETPREFIX/include $RESULTPREFIX/
# copy locale.d and mods.d directory from ppc to result_inst
cp -r $TARGETPREFIX/share/sword/locales.d $RESULTPREFIX/
