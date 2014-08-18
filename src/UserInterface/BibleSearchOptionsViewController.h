//
//  BibleSearchOptionsViewController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 10.07.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define BIBLESEARCHOPTIONSVIEW_NIBNAME @"BibleSearchOptions"

@interface BibleSearchOptionsViewController : SearchOptionsViewController {
}

- (id)initWithDelegate:(id)aDelegate andTarget:(id)aTarget;

// viewSearchOptions actions
- (IBAction)viewSearchDirection:(id)sender;

@end
