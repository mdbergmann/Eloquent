#!/bin/bash
# some variables have to be given like:
# $SRCROOT, $BUILD_DIR, $CONFIGURATION in this order

SRCROOT="/Users/mbergmann/_inProgress/Sources/macsword/macsword/trunk";
BUILD_DIR="$SRCROOT/build";
CONFIG="Release";
TARGET="MacSword";

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

# write build number (svn commit) to Info.plist
./writeBuildToInfoPlist.pl

# build Deployment version
xcodebuild -target "$TARGET" -configuration "$CONFIG" clean build
#echo "rc = $RC";
#if [ $RC != 0 ]; then
#	echo "build did not succeed!";
#	exit 1;
#fi

# generate deploy archive
BUILDSTR=`$SRCROOT/getLastSVNCommit.pl`;
BUNDLEVERSION=`$SRCROOT/getBundleVersion.pl`;
DESTPATH="$SRCROOT/../../$TARGET-""$BUNDLEVERSION""_""$BUILDSTR";

mkdir "$DESTPATH";
# copy app and userguide
cp -r "$BUILD_DIR/$CONFIG/$TARGET.app" "$DESTPATH/";
cp -r "$SRCROOT/Readmes" "$DESTPATH/";
DMGARCHIVE="$TARGET-${BUNDLEVERSION}.dmg";
ZIPARCHIVE="$DMGARCHIVE.zip";
# create disk image
echo "Destpath: $DESTPATH";
hdiutil create -srcfolder "$DESTPATH" "$SRCROOT/../../$DMGARCHIVE";
sleep 2;
# zip it
cd "$SRCROOT/../..";
zip "$ZIPARCHIVE" "$DMGARCHIVE";

exit 0
