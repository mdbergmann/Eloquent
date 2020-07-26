//
//  FolderUtil.swift
//  Eloquent
//
//  Created by Manfred Bergmann on 01.03.16.
//  Copyright © 2016 Crosswire. All rights reserved.
//

import Cocoa

@objc class FolderUtil: NSObject {

    private static var libraryFolder: URL?
    private static var appSupportFolder: URL?
    private static var appInAppSupportFolder: URL?
    private static var notesFolder: URL?
    private static var indexFolder: URL?
    private static var modulesFolder: URL?
    private static var installMgrFolder: URL?
    
    @objc class func urlForLibraryFolder() -> URL? {
        if libraryFolder == nil {
            let urls = FileManager.default.urls(for:.libraryDirectory, in:.userDomainMask)
            if urls.count > 0 {
                libraryFolder = urls[0]
            }
        }
        return libraryFolder
    }
    
    @objc class func urlForLogFolder() -> URL? {
        return urlForLibraryFolder()?.appendingPathComponent("Logs")
    }

    @objc class func urlForLogfile() -> URL? {
        return urlForLogFolder()?.appendingPathComponent("\(APPNAME).log")
    }

    @objc class func urlForAppSupportFolder() -> URL? {
        if appSupportFolder == nil {
            let urls = FileManager.default.urls(for:.applicationSupportDirectory, in:.userDomainMask)
            if urls.count > 0 {
                appSupportFolder = urls[0]
            }
        }
        return appSupportFolder
    }
    
    @objc class func urlForAppInAppSupport() -> URL? {
        if appInAppSupportFolder == nil {
            appInAppSupportFolder = urlForAppSupportFolder()?.appendingPathComponent(APPNAME)
            if !FileManager.default.fileExists(atPath:appInAppSupportFolder!.path) {
                try! FileManager.default.createDirectory(atPath:appInAppSupportFolder!.path, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return appInAppSupportFolder
    }

    @objc class func urlForNotesFolder() -> URL? {
        if notesFolder == nil {
            notesFolder = urlForAppInAppSupport()?.appendingPathComponent("Notes")
            if !FileManager.default.fileExists(atPath:notesFolder!.path) {
                try! FileManager.default.createDirectory(atPath:notesFolder!.path, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return notesFolder
    }

    @objc class func urlForIndexFolder() -> URL? {
        if indexFolder == nil {
            indexFolder = urlForAppInAppSupport()?.appendingPathComponent("Index")
            if !FileManager.default.fileExists(atPath:indexFolder!.path) {
                try! FileManager.default.createDirectory(atPath:indexFolder!.path, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return indexFolder
    }

    @objc class func urlForModulesFolder() -> URL? {
        if modulesFolder == nil {
            modulesFolder = urlForAppSupportFolder()?.appendingPathComponent("Sword")
            if !FileManager.default.fileExists(atPath:modulesFolder!.path) {
                try! FileManager.default.createDirectory(atPath:modulesFolder!.path, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return modulesFolder
    }

    @objc class func urlForModsdInModulesFolder() -> URL? {
        let folder = urlForModulesFolder()?.appendingPathComponent("mods.d")
        if !FileManager.default.fileExists(atPath:folder!.path) {
            try! FileManager.default.createDirectory(atPath:folder!.path, withIntermediateDirectories:false, attributes:nil)
        }
        return folder
    }

    @objc class func urlForInstallMgrModulesFolder() -> URL? {
        if installMgrFolder == nil {
            installMgrFolder = urlForModulesFolder()?.appendingPathComponent(SWINSTALLMGR_NAME)
            if !FileManager.default.fileExists(atPath:installMgrFolder!.path) {
                try! FileManager.default.createDirectory(atPath:installMgrFolder!.path, withIntermediateDirectories:false, attributes:nil)
            }
        }
        return installMgrFolder
    }
    
    @objc class func urlForBookmarks() -> URL? {
        return urlForAppInAppSupport()?.appendingPathComponent("Bookmarklist.plist")
    }

    @objc class func urlForDefaultSession() -> URL? {
        return urlForAppInAppSupport()?.appendingPathComponent("DefaultSession.mssess")
    }

    @objc class func urlForDefaultSearchBooksets() -> URL? {
        return urlForAppInAppSupport()?.appendingPathComponent("DefaultSearchBookSets.plist")
    }
}
