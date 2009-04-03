#!/usr/bin/perl -w

# extract Revision of HEAD of Repository
my $revStr = `svn info -r HEAD | grep "^Revision:"`;
#print "revStr = $revStr\n";

# get number only
$revStr =~ /\b(\d+)$/;
my $buildNumber = $1;

print "$buildNumber";