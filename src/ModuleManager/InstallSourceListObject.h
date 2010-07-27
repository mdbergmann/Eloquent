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

@interface InstallSourceListObject : NSObject {

    SwordInstallSource *installSource;
    NSString *moduleType;
    InstallSourceListObjectType objectType;
    
    NSArray *subInstallSources;
}

// -------------- getter / setter -----------------
- (SwordInstallSource *)installSource;
- (void)setInstallSource:(SwordInstallSource *)value;

- (NSString *)moduleType;
- (void)setModuleType:(NSString *)value;

- (InstallSourceListObjectType)objectType;
- (void)setObjectType:(InstallSourceListObjectType)value;

- (NSArray *)subInstallSources;
- (void)setSubInstallSources:(NSArray *)value;

// ------------------ methods -----------------
/** convenient allocator */
+ (InstallSourceListObject *)installSourceListObjectForType:(InstallSourceListObjectType)type;

- (id)initWithListObjectType:(InstallSourceListObjectType)type;

@end
