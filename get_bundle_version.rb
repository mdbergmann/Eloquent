#!/usr/bin/env macruby

info_dict = NSDictionary.dictionaryWithContentsOfFile("./Info.plist")
if !info_dict 
  puts "Couldn't load Info.plist"
end

print info_dict["CFBundleShortVersionString"]
