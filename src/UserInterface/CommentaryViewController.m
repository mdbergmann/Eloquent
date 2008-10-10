//
//  CommentaryViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "CommentaryViewController.h"
#import "SingleViewHostController.h"
#import "BibleCombiViewController.h"
#import "ExtTextViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordCommentary.h"

@interface CommentaryViewController (/* class continuation */)
- (void)populateModulesMenu;

/** generates HTML for display */
- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData;
@end

@implementation CommentaryViewController

- (id)initWithModule:(SwordCommentary *)aModule {
    return [self initWithModule:aModule delegate:nil];
}

- (id)initWithModule:(SwordCommentary *)aModule delegate:(id)aDelegate {
    self = [self init];
    if(self) {
        MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -init]");
        self.module = (SwordCommentary *)aModule;
        self.delegate = aDelegate;
        
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];
        
        self.nibName = COMMENTARYVIEW_NIBNAME;
        
        // load nib
        BOOL stat = [NSBundle loadNibNamed:nibName owner:self];
        if(!stat) {
            MBLOG(MBLOG_ERR, @"[CommentaryViewController -init] unable to load nib!");
        }        
    } else {
        MBLOG(MBLOG_ERR, @"[CommentaryViewController -init] unable init!");
    }
    
    return self;    
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[CommentaryViewController -awakeFromNib]");
    
    [super awakeFromNib];
    
    // check which delegate we have and en/disable the close button
    [self adaptUIToHost];
}

#pragma mark - methods

- (void)adaptUIToHost {
    if(delegate) {
        if([delegate isKindOfClass:[SingleViewHostController class]]) {
            [closeBtn setEnabled:NO];
            [closeBtn setHidden:YES];
        } else if([delegate isKindOfClass:[BibleCombiViewController class]]) {
            [closeBtn setHidden:NO];
            [closeBtn setEnabled:YES];
        }
    }
}

- (void)populateModulesMenu {
    
    NSMenu *menu = [[NSMenu alloc] init];
    // generate menu
    [[SwordManager defaultManager] generateModuleMenu:&menu 
                                        forModuletype:commentary 
                                       withMenuTarget:self 
                                       withMenuAction:@selector(moduleSelectionChanged:)];
    // add menu
    [modulePopBtn setMenu:menu];
}

- (NSAttributedString *)displayableHTMLFromVerseData:(NSArray *)verseData {
    NSAttributedString *ret = nil;
    
    // generate html string for verses
    NSMutableString *htmlString = [NSMutableString string];
    for(NSDictionary *dict in verseData) {
        NSString *verseText = [dict objectForKey:SW_OUTPUT_TEXT_KEY];
        NSString *key = [dict objectForKey:SW_OUTPUT_REF_KEY];
        
        // some defaults
        // get user defaults
        BOOL showBookNames = [userDefaults boolForKey:DefaultsBibleTextShowBookNameKey];
        BOOL showBookAbbr = [userDefaults boolForKey:DefaultsBibleTextShowBookAbbrKey];
        
        NSString *bookName = @"";
        int book = -1;
        int chapter = -1;
        int verse = -1;
        // decode ref
        [SwordBible decodeRef:key intoBook:&bookName book:&book chapter:&chapter verse:&verse];
        
        // generate text according to userdefaults
        if(showBookNames) {
            [htmlString appendFormat:@"<b>%@ %i:%i: </b><br />", bookName, chapter, verse];
            [htmlString appendFormat:@"%@<br />\n", verseText];
        } else if(showBookAbbr) {
            // TODO: show abbrevation
            [htmlString appendFormat:@"<b>%@ %i:%i: </b><br />", bookName, chapter, verse];
            [htmlString appendFormat:@"%@<br />\n", verseText];
        }
    }
    
    // create attributed string
    // setup options
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    // set string encoding
    [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] 
                forKey:NSCharacterEncodingDocumentOption];
    // set web preferences
    [options setObject:[[MBPreferenceController defaultPrefsController] webPreferences] forKey:NSWebPreferencesDocumentOption];
    // set scroll to line height
    NSFont *font = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayFontFamilyKey] 
                                   size:[userDefaults integerForKey:DefaultsBibleTextDisplayFontSizeKey]];
    [[textViewController scrollView] setLineScroll:[[[textViewController textView] layoutManager] defaultLineHeightForFont:font]];
    // set text
    NSData *data = [htmlString dataUsingEncoding:NSUTF8StringEncoding];
    ret = [[NSAttributedString alloc] initWithHTML:data 
                                           options:options
                                documentAttributes:nil];
    
    return ret;
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
}

@end
