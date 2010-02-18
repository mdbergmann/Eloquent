#!/usr/bin/env macruby

# the prefix is incremented for every minor/major version number increment
# the actual number begins at 1
prefix = "a"

buildstring = File.new("buildnumber", "r").gets
splitnum = buildstring.split(prefix)
number = splitnum[splitnum.length-1].to_i
number += 1
buildnumber = prefix + number.to_s
File.new("buildnumber", "w+").write(buildnumber)
