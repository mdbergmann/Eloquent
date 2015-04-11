//
//  SwordModuleIndex.h
//  ObjCSword
//
//  Created by Manfred Bergmann on 13.06.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwordModule.h"

@interface SwordModule(Index)

- (BOOL)hasSearchIndex;
- (void)createSearchIndex;
- (void)deleteSearchIndex;
- (NSArray *)performIndexSearch:(NSString *)searchString;

@end
