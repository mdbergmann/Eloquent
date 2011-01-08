//
//  PrintAccessoryViewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 17.03.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

@interface PrintAccessoryViewController : NSViewController <NSPrintPanelAccessorizing> {
    NSPrintInfo *printInfo;    
}

- (id)initWithPrintInfo:(NSPrintInfo *)aPrintInfo;

@property (retain, readwrite) NSPrintInfo *printInfo;

- (NSSet *)keyPathsForValuesAffectingPreview;
- (NSArray *)localizedSummaryItems;

@end
