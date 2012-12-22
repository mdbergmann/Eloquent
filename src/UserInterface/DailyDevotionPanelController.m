//
//  DailyDevotionPanelController.m
//  Eloquent
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
#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "DictionaryViewController.h"
#import "NSUserDefaults+Additions.h"


@interface DailyDevotionPanelController ()

@end

@implementation DailyDevotionPanelController

@synthesize delegate;
@synthesize dailyDevotionModule;
@dynamic day;
@dynamic month;

- (id)init {
    return [self initWithDelegate:nil andModule:nil];
}

- (id)initWithDelegate:(id)aDelegate andModule:(SwordDictionary *)ddModule {
	self = [super init];
    if(self) {
        [self setDelegate:aDelegate];
        [self setDailyDevotionModule:ddModule];
        
        NSDate *now = [NSDate date];
        day = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:now] day];
        month = [[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:now] month];
        
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
    
    NSMutableDictionary *selectionAttributes = [[[textView selectedTextAttributes] mutableCopy] autorelease];
    [selectionAttributes setObject:[userDefaults colorForKey:DefaultsTextHighlightColor] forKey:NSBackgroundColorAttributeName];
    [textView setSelectedTextAttributes:selectionAttributes];
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [dictionaryViewController release];
    [dailyDevotionModule release];

    [super dealloc];
}

#pragma mark - Bindings

- (NSInteger)minDays {
    return 1;
}

- (NSInteger)maxDays {
    return 31;
}

- (NSInteger)minMonths {
    return 1;
}

- (NSInteger)maxMonths {
    return 12;
}

- (NSInteger)day {
    return day;
}

- (void)setDay:(NSInteger)aDay {
    day = aDay;
    [[textView textStorage] setAttributedString:[self moduleText]];
}

- (NSInteger)month {
    return month;
}

- (void)setMonth:(NSInteger)aMonth {
    month = aMonth;
    [[textView textStorage] setAttributedString:[self moduleText]];
}

- (NSString *)moduleName {
    return [dailyDevotionModule name];
}

- (NSAttributedString *)moduleText {
    // create key String
    NSString *keyString = [NSString stringWithFormat:@"%02ld.%02ld", month, day];
    SwordModuleTextEntry *renderedText = [dailyDevotionModule textEntryForKey:[SwordKey swordKeyWithRef:keyString] textType:TextTypeRendered];
    
    if(renderedText) {
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
        
        WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferencesForModuleName:[dailyDevotionModule name]];
        [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
        
        NSData *data = [[renderedText text] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableAttributedString *displayString = [[[NSMutableAttributedString alloc] initWithHTML:data
                                                                                           options:options
                                                                                documentAttributes:nil] autorelease];
        
        // set custom fore ground color
        [displayString addAttribute:NSForegroundColorAttributeName value:[userDefaults colorForKey:DefaultsTextForegroundColor]
                              range:NSMakeRange(0, [displayString length])];
        
        // add pointing hand cursor to all links
        NSRange effectiveRange;
        NSUInteger	i = 0;
        while (i < [displayString length]) {
            NSDictionary *attrs = [displayString attributesAtIndex:i effectiveRange:&effectiveRange];
            if([attrs objectForKey:NSLinkAttributeName] != nil) {
                // add pointing hand cursor
                attrs = [[attrs mutableCopy] autorelease];
                [(NSMutableDictionary *)attrs setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
                [displayString setAttributes:attrs range:effectiveRange];
            }
            i += effectiveRange.length;
        }
        
        if(displayString) {
            return displayString;
        }
    }
    
    return [[[NSAttributedString alloc] initWithString:@""] autorelease];
}

- (BOOL)isTextViewEditable {
    return NO;
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
    [self setDay:[[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:now] day]];
    [self setMonth:[[[NSCalendar currentCalendar] components:NSMonthCalendarUnit fromDate:now] month]];
}

#pragma mark - NSTextView delegates

- (NSString *)textView:(NSTextView *)aTextView willDisplayToolTip:(NSString *)tooltip forCharacterAtIndex:(NSUInteger)characterIndex {
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

