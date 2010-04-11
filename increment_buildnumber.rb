#!/usr/bin/env macruby

buildstring = File.new("buildnumber", "r").gets
number = buildstring.to_i
number += 1
File.new("buildnumber", "w+").write(number.to_s)
