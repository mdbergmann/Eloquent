//
//  Configuration.h
//  ObjCSword
//
//  Created by Manfred Bergmann on 12.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 To define your own configuration:
 Create a subclass of Configuration and override the methods there (as done in OSXConfiguration).
 To globally apply your configuration do:
 [[Configuration config] setImpl:[<YourConfigSubclass> class]];
 */

@protocol Configuration

- (NSString *)osVersion;
- (NSString *)bundleVersion;
- (NSString *)defaultModulePath;
- (NSString *)defaultAppSupportPath;
- (NSString *)tempFolder;
- (NSString *)logFile;

@end

@interface Configuration : NSObject <Configuration>

+ (Configuration *)config;
+ (Configuration *)configWithImpl:(id<Configuration>)configImpl;

- (NSString *)osVersion;
- (NSString *)bundleVersion;
- (NSString *)defaultModulePath;
- (NSString *)defaultAppSupportPath;
- (NSString *)tempFolder;
- (NSString *)logFile;

@end
