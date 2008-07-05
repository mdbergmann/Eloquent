#!/usr/bin/perl -w
#===============================================================================
#
#         FILE:  genBuildNum.pl
#
#        USAGE:  ./svnCommitNum.pl 
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:   (), <>
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  05/19/06 07:55:35 CEST
#     REVISION:  ---
#===============================================================================

use strict;
use Camelbones qw(:Foundation);

# extract Revision of HEAD of Repository
my $revStr = `svn info -r HEAD | grep "^Revision:"`;
#print "revStr = $revStr\n";

# get number only
$revStr =~ /\b(\d+)$/;
my $buildNumber = $1;

print "$buildNumber";
