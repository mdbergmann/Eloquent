#!/usr/bin/env macruby

require 'HotCocoa'

prefix = "a"

buildstring = File.new("buildnumber", "r").gets
splitnum = buildstring.split(prefix)
number = splitnum[splitnum.length-1].to_i
number += 1
buildnumber = prefix + number.to_s
File.new("buildnumber", "w+").write(buildnumber)
