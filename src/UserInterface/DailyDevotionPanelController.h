//
//  DailyDevotionPanelController.h
//  MacSword2
//
//  Created by Manfred Bergmann on 01.08.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CocoLogger/CocoLogger.h>
#import <WebKit/WebKit.h>

@class SwordDictionary, DictionaryViewController;

@interface DailyDevotionPanelController : NSWindowController {
    SwordDictionary *dailyDevotionModule;
    NSInteger currentDay;
    NSInteger currentMonth;
    
    DictionaryViewController *dictionaryViewController;
    
    IBOutlet NSTextView *textView;
    IBOutlet NSStepper *dayStepper;
    IBOutlet NSStepper *monthStepper;    
    IBOutlet NSTextField *dayTextField;
    IBOutlet NSTextField *monthTextField;    
    
    IBOutlet id delegate;
}

@property(assign, readwrite) id delegate;
@property(retain, readwrite) SwordDictionary *dailyDevotionModule;
@property(readwrite) NSInteger currentDay;
@property(readwrite) NSInteger currentMonth;

- (id)initWithDelegate:(id)aDelegate andModule:(SwordDictionary *)ddModule;

// bindings for stepper and textfields
- (NSInteger)minDays;
- (NSInteger)maxDays;
- (NSInteger)currentDay;
- (void)setCurrentDay:(NSInteger)day;

- (NSInteger)minMonths;
- (NSInteger)maxMonths;
- (NSInteger)currentMonth;
- (void)setCurrentMonth:(NSInteger)month;

- (NSString *)moduleName;

- (void)displayTextForDayAndMonth;

- (IBAction)todayButton:(id)sender;

@end
