#!/usr/bin/env macruby

buildnumber = File.new("buildnumber", "r").gets
infoDict = NSMutableDictionary.dictionaryWithContentsOfFile("./Info.plist")
infoDict["CFBundleVersion"] = buildnumber
#svs = infoDict["CFBundleShortVersionString"]
#svs = "%s-%s" % [svs.split("-")[0], buildnumber]
#infoDict["CFBundleShortVersionString"] = svs
infoDict.writeToFile("./Info.plist", atomically: 1)
