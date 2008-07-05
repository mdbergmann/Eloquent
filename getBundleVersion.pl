#!/usr/bin/perl -w
#===============================================================================
#
#         FILE:  bundleVersion.pl
#
#        USAGE:  ./bundleVersion.pl 
#
#  DESCRIPTION:  extracts the bundle version of the Info.Plist file
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  01/06/06 14:42:47 EST
#     REVISION:  ---
#===============================================================================

use strict;
use CamelBones qw(:Foundation);
use Getopt::Long;

# options
my $opt_infoplist = 'Info.plist';	# current dir

# get arguments
GetOptions(
	   "infoPlist=s"		=> \$opt_infoplist
	   );

my $versionStr = '';
if($opt_infoplist) {
	if(! -e $opt_infoplist) {
		die "The given info.plist file does not exist, check path!\n";
	}
	# extract version string from info.plist
	my $infoplistDict = NSDictionary->dictionaryWithContentsOfFile($opt_infoplist);
	if(! $infoplistDict) {
		die "Could not load dictionary from $opt_infoplist \n";
	}
	$versionStr = $infoplistDict->valueForKey('CFBundleVersion');
	if(! $versionStr) {
		die "Could not get CFBundleVersion from dictionary!\n";
	}
}

# write version to strout
print "$versionStr";


