/*	SwordCommentary.mm - Sword API wrapper for Commentaries.

    Copyright 2008 Manfred Bergmann
    Based on code by Will Thimbleby

	This program is free software; you can redistribute it and/or modify it under the terms of the
	GNU General Public License as published by the Free Software Foundation version 2.

	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
	even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
	General Public License for more details. (http://www.gnu.org/licenses/gpl.html)
*/

#import "SwordCommentary.h"
#import "globals.h"

// Well this is pretty much an empty sub-class of SwordBible
@implementation SwordCommentary

/** 
 creates a new empty editable commentary module 
 caller has to make sure the module doesn't exist yet
 @return path of the created module
 */
+ (NSString *)createCommentaryWithName:(NSString *)aName {
    NSString *ret = nil;
    
    // let's create the directory for storing our module
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // modulePath
    NSString *modPath = [DEFAULT_MODULE_PATH stringByAppendingFormat:@"/%@.swd", aName];
    if([fm fileExistsAtPath:modPath]) {
        MBLOGV(MBLOG_ERR, @"[SwordCommentary -createCommentaryWithName:] path exists already for mod: %@", aName);
    } else {
        ret = modPath;
        
        // create folder
        [fm createDirectoryAtPath:modPath attributes:nil];
        
        // create mods.d folder
        NSString *modsdPath = [modPath stringByAppendingPathComponent:@"mods.d"];
        [fm createDirectoryAtPath:modsdPath attributes:nil];
        // create module folder
        NSString *dataPath = [modPath stringByAppendingPathComponent:@"modules"];
        [fm createDirectoryAtPath:dataPath attributes:nil];
        dataPath = [dataPath stringByAppendingPathComponent:@"comments"];
        [fm createDirectoryAtPath:dataPath attributes:nil];
        dataPath = [dataPath stringByAppendingPathComponent:@"rawfiles"];
        [fm createDirectoryAtPath:dataPath attributes:nil];
        dataPath = [dataPath stringByAppendingPathComponent:aName];
        [fm createDirectoryAtPath:dataPath attributes:nil];
        
        // let's create a brand new empty module
        sword::RawFiles::createModule([dataPath UTF8String]);
        // let's add our .conf file
        sword::SWConfig newConf([[modsdPath stringByAppendingFormat:@"/%@.conf", aName] UTF8String]);
        const char *aNameCStr = [aName UTF8String];
        newConf[aNameCStr]["DataPath"] = [[NSString stringWithFormat:@"./modules/comments/rawfiles/%@", aName] UTF8String];
        newConf[aNameCStr]["ModDrv"] = "RawFiles";
        newConf[aNameCStr]["SourceType"] = "ThML";
        newConf[aNameCStr]["Editable"] = "YES";
        newConf[aNameCStr]["About"] = "This module allows you to store your own commentary.";
        newConf.Save();        
        
        /*
        FileMgr::createParent("/Users/mbergmann/Applications/MacSword/modules/comments/rawcom/mbergmannCommentary1/x");
        // let's create a brand new empty module
        sword::RawCom::createModule("/Users/mbergmann/Applications/MacSword/modules/comments/rawcom/mbergmannCommentary1");
                
        // let's add our .conf file
        SWConfig mbergmannConf("/Users/mbergmann/Applications/MacSword/mods.d/mbergmannCommentary1.conf");
        
        mbergmanConf["MBergmannCommentary1"]["DataPath"] = "./modules/comments/rawcom/mbergmannCommentary1";
        mbergmanConf["MBergmannCommentary1"]["ModDrv"] = "RawCom";
        mbergmanConf["MBergmannCommentary1"]["SourceType"] = "OSIS";
        mbergmanConf["MBergmannCommentary1"]["Decription"] = "Manfred Bergmann's Concise Commentary on the Bible";
        mbergmanConf["MBergmannCommentary1"]["About"] = "...";
        mbergmanConf.Save();        
         */
    }
    
    return ret;
}

- (id)init {
    return [super init];
}

- (void)finalize {
    [super finalize];
}


@end
