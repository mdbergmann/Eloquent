//
//  DailyDevotionPanelController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 01.08.10.
//  Copyright 2010 CrossWire. All rights reserved.
//

#import "DailyDevotionPanelController.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordDictionary.h"
#import "ObjCSword/SwordKey.h"
#import "ObjCSword/SwordModuleTextEntry.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "DictionaryViewController.h"
#import "NSUserDefaults+Additions.h"


@interface DailyDevotionPanelController ()

@end

@implementation DailyDevotionPanelController

@synthesize delegate;
@synthesize dailyDevotionModule;
@dynamic currentDay;
@dynamic currentMonth;

- (id)init {
    return [self initWithDelegate:nil andModule:nil];
}

- (id)initWithDelegate:(id)aDelegate andModule:(SwordDictionary *)ddModule {
	self = [super init];
    if(self) {
        [self setDelegate:aDelegate];
        [self setDailyDevotionModule:ddModule];
        
        NSDate *now = [NSDate date];
        currentDay = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:now] day];
        currentMonth = [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:now] month];
        
        dictionaryViewController = [[DictionaryViewController alloc] initWithModule:ddModule];
        
        [NSBundle loadNibNamed:@"DailyDevotion" owner:self];
	}
	
	return self;
}

- (void)awakeFromNib {
    
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionaryWithCapacity:3];
    [linkAttributes setObject:[userDefaults objectForKey:DefaultsLinkUnderlineAttribute] forKey:NSUnderlineStyleAttributeName];
    [linkAttributes setObject:[userDefaults colorForKey:DefaultsLinkForegroundColor] forKey:NSForegroundColorAttributeName];
    [linkAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
    [textView setLinkTextAttributes:linkAttributes];
    
    [textView setBackgroundColor:[userDefaults colorForKey:DefaultsTextBackgroundColor]];
    
    NSMutableDictionary *selectionAttributes = [[textView selectedTextAttributes] mutableCopy];
    [selectionAttributes setObject:[userDefaults colorForKey:DefaultsTextHighlightColor] forKey:NSBackgroundColorAttributeName];
    [textView setSelectedTextAttributes:selectionAttributes];

    [self displayTextForDayAndMonth];
}

- (void)finalize {
    [super finalize];
}

#pragma mark - Bindings

- (NSInteger)minDays {
    return 1;
}

- (NSInteger)maxDays {
    return 31;
}

- (NSInteger)currentDay {
    return currentDay;
}

- (void)setCurrentDay:(NSInteger)day {
    currentDay = day;
    [self displayTextForDayAndMonth];    
}

- (NSInteger)minMonths {
    return 1;
}

- (NSInteger)maxMonths {
    return 12;
}

- (NSInteger)currentMonth {
    return currentMonth;
}

- (void)setCurrentMonth:(NSInteger)month {
    currentMonth = month;
    [self displayTextForDayAndMonth];    
}

- (NSString *)moduleName {
    return [dailyDevotionModule name];
}

- (void)displayTextForDayAndMonth {
    // create key String
    NSString *keyString = [NSString stringWithFormat:@"%02i.%02i", [self currentMonth], [self currentDay]];
    SwordModuleTextEntry *renderedText = [dailyDevotionModule textEntryForKey:[SwordKey swordKeyWithRef:keyString] textType:TextTypeRendered];

    if(renderedText) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];

        WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[dailyDevotionModule name]];
        //[webPrefs setStandardFontFamily:[FontLarge familyName]];
        //[webPrefs setDefaultFontSize:[FontLarge pointSize]];
        [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
        
        NSData *data = [[renderedText text] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableAttributedString *displayString = [[NSMutableAttributedString alloc] initWithHTML:data 
                                                                    options:options
                                                         documentAttributes:nil];

        // set custom fore ground color
        [displayString addAttribute:NSForegroundColorAttributeName value:[userDefaults colorForKey:DefaultsTextForegroundColor]
                                  range:NSMakeRange(0, [displayString length])];

        // add pointing hand cursor to all links
        NSRange effectiveRange;
        int	i = 0;
        while (i < [displayString length]) {
            NSDictionary *attrs = [displayString attributesAtIndex:i effectiveRange:&effectiveRange];
            if([attrs objectForKey:NSLinkAttributeName] != nil) {
                // add pointing hand cursor
                attrs = [attrs mutableCopy];
                [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
                [displayString setAttributes:attrs range:effectiveRange];
            }
            i += effectiveRange.length;
        }
        
        if(displayString) {
            [[textView textStorage] setAttributedString:displayString];
        }
    }
}

- (void)windowWillClose:(NSNotification *)notification {
    if(delegate && [delegate respondsToSelector:@selector(auxWindowClosing:)]) {
        [delegate performSelector:@selector(auxWindowClosing:) withObject:self];
    } else {
        CocoLog(LEVEL_WARN, @"delegate does not respond to selector!");
    }
}

- (IBAction)todayButton:(id)sender {
    NSDate *now = [NSDate date];
    currentDay = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:now] day];
    [dayStepper setIntValue:currentDay];
    [dayTextField setIntValue:currentDay];

    currentMonth = [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:now] month];
    [monthStepper setIntValue:currentMonth];
    [monthTextField setIntValue:currentMonth];

    [self displayTextForDayAndMonth];
}

#pragma mark - NSTextView delegates

- (NSString *)textView:(NSTextView *)textView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
    CocoLog(LEVEL_DEBUG, @"");
    NSURL *url = [NSURL URLWithString:[tooltip stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if(!url) {
        CocoLog(LEVEL_WARN, @"no URL: %@\n", tooltip);
    } else {
        return [dictionaryViewController performSelector:@selector(processPreviewDisplay:) withObject:url];
    }
    
    return @"";
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex {
    CocoLog(LEVEL_DEBUG, @"");
    [dictionaryViewController performSelector:@selector(linkClicked:) withObject:link];

    return YES;
}

@end
