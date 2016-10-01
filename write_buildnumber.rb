#!/usr/bin/env ruby

buildnumber = File.new("buildnumber", "r").gets
propkey = "CFBundleVersion"

`./PlistUtil 'Info.plist' put #{propkey} #{buildnumber}`
`./PlistUtil 'Eloquent-AppStore-Info.plist' put #{propkey} #{buildnumber}`
