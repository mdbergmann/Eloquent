#!/bin/bash
# some variables have to be given like:
# $SRCROOT, $BUILD_DIR, $CONFIGURATION in this order

SRCROOT=`pwd`;
BUILD_DIR="build";
CONFIG="Release";
TARGET="Eloquent";

# check these values
if [ $SRCROOT = "" ]; then
	echo "Have no SRCROOT!";
	exit 1;
fi
if [ $BUILD_DIR = "" ]; then
	echo "Have no BUILD_DIR!";
	exit 1;
fi
if [ $CONFIG = "" ]; then
	echo "Have no CONFIGURATION!";
	exit 1;
fi
if [ $TARGET = "" ]; then
	echo "Have no TARGET!";
	exit 1;
fi

# increment "buildnumber" and write it to Info.plist
./increment_buildnumber.rb
./write_buildnumber.rb

# build Deployment version
xcodebuild -target "$TARGET" -configuration "$CONFIG" clean build
#echo "rc = $RC";
#if [ $RC != 0 ]; then
#	echo "build did not succeed!";
#	exit 1;
#fi

# generate deploy archive
BUNDLEVERSION=`$SRCROOT/get_bundle_version.rb`;
DESTPATH="$SRCROOT/../deploy/$TARGET-""$BUNDLEVERSION";

mkdir "$DESTPATH";
# copy app
cp -r "$BUILD_DIR/$CONFIG/$TARGET.app" "$DESTPATH/";
# copy stuff from docs dir
cp -r "$SRCROOT/../docs-ms20" "$DESTPATH/docs";
DMGARCHIVE="$TARGET-${BUNDLEVERSION}.dmg";
ZIPARCHIVE="$DMGARCHIVE.zip";
# create disk image
echo "Destpath: $DESTPATH";
hdiutil create -srcfolder "$DESTPATH" "$SRCROOT/../deploy/$DMGARCHIVE";
sleep 2;
# zip it
cd "$SRCROOT/../deploy/";
zip "$ZIPARCHIVE" "$DMGARCHIVE";

exit 0
