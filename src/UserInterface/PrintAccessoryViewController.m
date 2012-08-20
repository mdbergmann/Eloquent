//
//  PrintAccessoryViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 17.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "PrintAccessoryViewController.h"


@implementation PrintAccessoryViewController

@synthesize printInfo;

- (id)init {
    return [self initWithPrintInfo:nil];
}

- (id)initWithPrintInfo:(NSPrintInfo *)aPrintInfo {
    self = [super init];
    if(self) {
        
        [self setPrintInfo:aPrintInfo];
        
        BOOL success = [NSBundle loadNibNamed:@"PrintAccessory" owner:self];
        if(success == NO) {
            CocoLog(LEVEL_WARN, @"could not load nib");
        }
    }
    return self;
}

- (void)awakeFromNib {
}

- (void)finalize {
	[super finalize];
}

- (void)dealloc {
    [printInfo release];
    [super dealloc];
}

- (NSSet *)keyPathsForValuesAffectingPreview {
    return [NSSet set]; 
    /*
            setWithObjects:
            @"printInfo.leftMargin",
            @"printInfo.rightMargin",
            @"printInfo.topMargin",
            @"printInfo.bottomMargin",
            nil];
     */
}

- (NSArray *)localizedSummaryItems {
    return [NSArray array];
}

@end
