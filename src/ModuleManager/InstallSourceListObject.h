//
//  InstallSourceListObject.h
//  Eloquent
//
//  Created by Manfred Bergmann on 10.03.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class SwordInstallSource;

typedef enum _InstallSourceListObjectType {
    TypeInstallSource = 0,
    TypeModuleType
}InstallSourceListObjectType;

@interface InstallSourceListObject : NSObject

@property (strong, readwrite) SwordInstallSource *installSource;
@property (readwrite) InstallSourceListObjectType objectType;
@property (strong, readwrite) NSString *moduleType;
@property (strong, readwrite) NSArray *subInstallSources;

/** convenient allocator */
+ (InstallSourceListObject *)installSourceListObjectForType:(InstallSourceListObjectType)type;

- (id)initWithListObjectType:(InstallSourceListObjectType)type;

@end
