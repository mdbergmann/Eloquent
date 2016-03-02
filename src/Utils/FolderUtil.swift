//
//  FolderUtil.swift
//  Eloquent
//
//  Created by Manfred Bergmann on 01.03.16.
//  Copyright © 2016 Crosswire. All rights reserved.
//

import Cocoa

@objc class FolderUtil: NSObject {

    private static var libraryFolder: NSURL?
    private static var appSupportFolder: NSURL?
    private static var appInAppSupportFolder: NSURL?
    private static var notesFolder: NSURL?
    private static var indexFolder: NSURL?
    private static var modulesFolder: NSURL?
    private static var installMgrFolder: NSURL?
    
    class func urlForLibraryFolder() -> NSURL? {
        if libraryFolder == nil {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains:.UserDomainMask)
            if urls.count > 0 {
                libraryFolder = urls[0]
            }
        }
        return libraryFolder
    }
    
    class func urlForLogFolder() -> NSURL? {
        return urlForLibraryFolder()?.URLByAppendingPathComponent("Logs")
    }

    class func urlForLogfile() -> NSURL? {
        return urlForLogFolder()?.URLByAppendingPathComponent("\(APPNAME).log")
    }

    class func urlForAppSupportFolder() -> NSURL? {
        if appSupportFolder == nil {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains:.UserDomainMask)
            if urls.count > 0 {
                appSupportFolder = urls[0]
            }
        }
        return appSupportFolder
    }
    
    class func urlForAppInAppSupport() -> NSURL? {
        if appInAppSupportFolder == nil {
            appInAppSupportFolder = urlForAppSupportFolder()?.URLByAppendingPathComponent(APPNAME)
            if !NSFileManager.defaultManager().fileExistsAtPath(appInAppSupportFolder!.path!) {
                try! NSFileManager.defaultManager().createDirectoryAtPath(appInAppSupportFolder!.path!, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return appInAppSupportFolder
    }

    class func urlForNotesFolder() -> NSURL? {
        if notesFolder == nil {
            notesFolder = urlForAppInAppSupport()?.URLByAppendingPathComponent("Notes")
            if !NSFileManager.defaultManager().fileExistsAtPath(notesFolder!.path!) {
                try! NSFileManager.defaultManager().createDirectoryAtPath(notesFolder!.path!, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return notesFolder
    }

    class func urlForIndexFolder() -> NSURL? {
        if indexFolder == nil {
            indexFolder = urlForAppInAppSupport()?.URLByAppendingPathComponent("Index")
            if !NSFileManager.defaultManager().fileExistsAtPath(indexFolder!.path!) {
                try! NSFileManager.defaultManager().createDirectoryAtPath(indexFolder!.path!, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return indexFolder
    }

    class func urlForModulesFolder() -> NSURL? {
        if modulesFolder == nil {
            modulesFolder = urlForAppSupportFolder()?.URLByAppendingPathComponent("Sword")
            if !NSFileManager.defaultManager().fileExistsAtPath(modulesFolder!.path!) {
                try! NSFileManager.defaultManager().createDirectoryAtPath(modulesFolder!.path!, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return modulesFolder
    }

    class func urlForModsdInModulesFolder() -> NSURL? {
        let folder = urlForModulesFolder()?.URLByAppendingPathComponent("mods.d")
        if !NSFileManager.defaultManager().fileExistsAtPath(folder!.path!) {
            try! NSFileManager.defaultManager().createDirectoryAtPath(folder!.path!, withIntermediateDirectories:false, attributes:nil)
        }
        return folder
    }

    class func urlForInstallMgrModulesFolder() -> NSURL? {
        if installMgrFolder == nil {
            installMgrFolder = urlForModulesFolder()?.URLByAppendingPathComponent(SWINSTALLMGR_NAME)
            if !NSFileManager.defaultManager().fileExistsAtPath(installMgrFolder!.path!) {
                try! NSFileManager.defaultManager().createDirectoryAtPath(installMgrFolder!.path!, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return installMgrFolder
    }
    
    class func urlForBookmarks() -> NSURL? {
        return urlForAppInAppSupport()?.URLByAppendingPathComponent("Bookmarklist.plist")
    }

    class func urlForDefaultSession() -> NSURL? {
        return urlForAppInAppSupport()?.URLByAppendingPathComponent("DefaultSession.mssess")
    }

    class func urlForDefaultSearchBooksets() -> NSURL? {
        return urlForAppInAppSupport()?.URLByAppendingPathComponent("DefaultSearchBookSets.plist")
    }
}
