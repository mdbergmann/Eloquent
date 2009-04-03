//
//  HUDPreviewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>

#define PreviewDisplayTypeKey   @"PreviewDisplayTypeKey"
#define PreviewDisplayTextKey   @"PreviewDisplayTextKey"

@interface HUDPreviewController : NSWindowController {
    
    IBOutlet NSBox *placeholderView;
    IBOutlet NSTextField *previewType;
    //IBOutlet NSTextField *previewText;
    IBOutlet NSTextView *previewText;
    
    IBOutlet id delegate;
}

@property (readwrite) id delegate;

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData;

- (id)initWithDelegate:(id)aDelegate;

@end
