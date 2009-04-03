#!/usr/bin/env macruby

require 'HotCocoa'

svnrev = `./get_svn_revision.rb`
infoDict = NSMutableDictionary.dictionaryWithContentsOfFile("./Info.plist")
infoDict["CFBundleVersion"] = svnrev
svs = infoDict["CFBundleShortVersionString"]
svs = "%s-%s" % [svs.split("-")[0], svnrev]
infoDict["CFBundleShortVersionString"] = svs
infoDict.writeToFile("./Info.plist", atomically: 1)
