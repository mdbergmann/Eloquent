//
//  HUDPreviewController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 10.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <ObjCSword/SwordModule.h>

#define PreviewDisplayTypeKey   @"PreviewDisplayTypeKey"
#define PreviewDisplayTextKey   @"PreviewDisplayTextKey"

@interface HUDPreviewController : NSWindowController <NSWindowDelegate> {
    
    IBOutlet NSBox *placeholderView;
    IBOutlet NSTextField *previewType;
    IBOutlet NSTextView *previewText;
    
    IBOutlet id __strong delegate;
}

@property (strong, readwrite) id delegate;

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData;
+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData forRenderType:(RenderType)textType;

- (id)initWithDelegate:(id)aDelegate;

@end
