//
//  ImageModuleTest.m
//  ObjCSword
//
//  Created by Manfred Bergmann on 03.08.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ImageModuleTest.h"
#import "ObjCSword/ObjCSword.h"


@implementation ImageModuleTest

- (void)setUp {
    [[Configuration config] setClass:[OSXConfiguration class]];
}

- (void)testImageModuleFeatures {
    SwordBook *book = (SwordBook *)[[SwordManager defaultManager] moduleWithName:@"SmithBibleAtlas"];
    STAssertNotNil(book, @"Module is nil");
    
    NSLog(@"Type string: %@", [book typeString]);
    NSString *categoryString = [book categoryString];
    STAssertNotNil(categoryString, @"");
    NSLog(@"categoryString: %@", categoryString);
    STAssertTrue([book category] == Maps, @"");    
    STAssertTrue([book hasFeature:SWMOD_CONF_FEATURE_IMAGES], @"");
}

- (void)testGetImages {
    SwordBook *book = (SwordBook *)[[SwordManager defaultManager] moduleWithName:@"SmithBibleAtlas"];
    STAssertNotNil(book, @"Module is nil");
    
    SwordModuleTreeEntry *entry = [book treeEntryForKey:@"/Smith Bible Atlas"];    
    STAssertNotNil(entry, @"");
    SwordModuleTextEntry *text = [book textEntryForKeyString:[entry key] textType:TextTypeRendered];
    STAssertNotNil(text, @"");
    NSLog(@"text: %@", [text text]);
}

@end
