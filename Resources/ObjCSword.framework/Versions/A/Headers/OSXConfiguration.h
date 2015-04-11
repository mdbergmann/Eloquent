//
//  OSXConfiguration.h
//  ObjCSword
//
//  Created by Manfred Bergmann on 12.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Configuration.h"

@interface OSXConfiguration : Configuration <Configuration> {
}

- (NSString *)osVersion;
- (NSString *)bundleVersion;
- (NSString *)defaultModulePath;
- (NSString *)defaultAppSupportPath;
- (NSString *)tempFolder;
- (NSString *)logFile;

@end
