//
//  HUDPreviewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>


@interface HUDPreviewController : NSWindowController {
    IBOutlet NSBox *placeholderView;
    IBOutlet NSTextField *previewType;
    IBOutlet NSTextField *previewText;
}

@end
