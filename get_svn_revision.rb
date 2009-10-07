#!/usr/bin/env macruby
 
revstr = `svn info -r HEAD | grep "^Revision:"`
print revstr.split()[1]
