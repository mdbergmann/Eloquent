//
//  DailyDevotionPanelController.h
//  Eloquent
//
//  Created by Manfred Bergmann on 01.08.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <WebKit/WebKit.h>

@class SwordDictionary, DictionaryViewController;

@interface DailyDevotionPanelController : NSWindowController <NSTextViewDelegate, NSWindowDelegate> {
    SwordDictionary *dailyDevotionModule;
    DictionaryViewController *dictionaryViewController;

    NSInteger day;
    NSInteger month;    
        
    IBOutlet NSTextView *textView;
    IBOutlet NSStepper *dayStepper;
    IBOutlet NSStepper *monthStepper;    
    IBOutlet NSTextField *dayTextField;
    IBOutlet NSTextField *monthTextField;    
    
    IBOutlet id delegate;
}

@property(assign, readwrite) id delegate;
@property(retain, readwrite) SwordDictionary *dailyDevotionModule;
@property(readwrite) NSInteger day;
@property(readwrite) NSInteger month;

- (id)initWithDelegate:(id)aDelegate andModule:(SwordDictionary *)ddModule;

// bindings for stepper and text fields
- (NSInteger)minDays;
- (NSInteger)maxDays;
- (NSInteger)minMonths;
- (NSInteger)maxMonths;

- (NSInteger)day;
- (void)setDay:(NSInteger)aDay;
- (NSInteger)month;
- (void)setMonth:(NSInteger)aMonth;

- (NSString *)moduleName;
- (NSAttributedString *)moduleText;

- (BOOL)isTextViewEditable;

- (IBAction)todayButton:(id)sender;

@end

