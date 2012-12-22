//
//  HUDPreviewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 10.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HUDPreviewController.h"
#import "MBPreferenceController.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordModuleTextEntry.h"
#import "globals.h"


@interface HUDPreviewController ()

+ (NSString *)createHtmlVerseForKey:(NSString *)aKey andText:(NSString *)verseText withStyleColor:(NSString *)styleColorSting andModuleName:(NSString *)aModName;

@end


@implementation HUDPreviewController

@synthesize delegate;

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData {
    return [HUDPreviewController previewDataFromDict:previewData forTextType:TextTypeStripped];
}

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData forTextType:(TextPullType)textType {
    NSMutableDictionary *ret = nil;
    
    if(previewData) {
        
        // headings fg color
        CGFloat hr, hg, hb = 0.0;
        NSColor *hfCol = [NSColor colorWithCalibratedRed:0.86 green:0.86 blue:0.86 alpha:0.0];
        [hfCol getRed:&hr green:&hg blue:&hb alpha:NULL];    
        NSString *previewPaneTextColor = [NSString stringWithFormat:@"color:rgb(%i%%, %i%%, %i%%);",
                                          (int)(hr * 100.0), (int)(hg * 100.0), (int)(hb * 100.0)];
        
        NSString *module = [previewData objectForKey:ATTRTYPE_MODULE];
        if(!module || [module length] == 0) {
            // get module for previewtype
            module = [userDefaults stringForKey:DefaultsBibleModule];
            NSString *attrType = [previewData objectForKey:ATTRTYPE_TYPE];
            if([attrType isEqualToString:@"Hebrew"]) {
                module = [userDefaults stringForKey:DefaultsStrongsHebrewModule];
            } else if([attrType isEqualToString:@"Greek"]) {
                module = [userDefaults stringForKey:DefaultsStrongsGreekModule];
            } else if([attrType hasPrefix:@"strongMorph"] || [attrType hasPrefix:@"robinson"]) {
                module = [userDefaults stringForKey:DefaultsMorphGreekModule];
            }
        }
        
        if(module) {
            ret = [NSMutableDictionary dictionary];
            
            SwordModule *mod = [[SwordManager defaultManager] moduleWithName:module];
            NSMutableString *displayText = [NSMutableString string];
            NSString *displayType = @"";
            if([[previewData objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showNote"]) {
                if([[previewData objectForKey:ATTRTYPE_TYPE] isEqualToString:@"n"]) {
                    displayType = SW_OPTION_FOOTNOTES;
                } else if([[previewData objectForKey:ATTRTYPE_TYPE] isEqualToString:@"x"]) {
                    displayType = SW_OPTION_SCRIPTREFS;                    
                }
            } else if([[previewData objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showStrongs"]) {
                displayType = SW_OPTION_STRONGS;            
            } else if([[previewData objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showMorph"]) {
                displayType = SW_OPTION_MORPHS;
            } else if([[previewData objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showRef"]) {
                displayType = SW_OPTION_REF;
            }
            [ret setObject:displayType forKey:@"PreviewDisplayTypeKey"];
            
            id result = [mod attributeValueForParsedLinkData:previewData withTextRenderType:textType];
            if(result != nil) {
                if([result isKindOfClass:[NSArray class]]) {
                    // prepare for view
                    for(SwordModuleTextEntry *entry in (NSArray *)result) {
                        NSString *verseText = [entry text];
                        NSString *key = [entry key];
                        
                        if(textType == TextTypeStripped) {
                            [displayText appendFormat:@"%@:\n%@\n", key, verseText];                            
                        } else {
                            [displayText appendString:[HUDPreviewController createHtmlVerseForKey:key andText:verseText withStyleColor:previewPaneTextColor andModuleName:module]];                            
                        }
                    }
                } else if([result isKindOfClass:[NSString class]]) {
                    if(textType == TextTypeRendered) {
                        displayText = [NSMutableString stringWithFormat:@"<span style=\"%@\">%@</span>", previewPaneTextColor, result];
                    } else {
                        displayText = result;
                    }
                } else if([result isKindOfClass:[SwordModuleTextEntry class]]) {
                    NSString *verseText = [(SwordModuleTextEntry *)result text];
                    NSString *key = [(SwordModuleTextEntry *)result key];
                    
                    if(textType == TextTypeStripped) {
                        [displayText appendFormat:@"%@:\n%@\n", key, verseText];                            
                    } else {
                        [displayText appendString:[HUDPreviewController createHtmlVerseForKey:key andText:verseText withStyleColor:previewPaneTextColor andModuleName:module]];                            
                    }
                }
            }
            [ret setObject:displayText forKey:@"PreviewDisplayTextKey"];            
        }      
    }
    
    return ret;    
}

+ (NSString *)createHtmlVerseForKey:(NSString *)aKey andText:(NSString *)verseText withStyleColor:(NSString *)styleColorSting andModuleName:(NSString *)aModName {
    return [NSString stringWithFormat:@"<span style=\"%@\"><a href=\"sword://%@/%@\">%@</a>:<br />%@<br /></span>", styleColorSting, aModName, aKey, aKey, verseText];
}

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)aDelegate {
	self = [super init];
    if(self) {
        delegate = aDelegate;
	}
	
	return self;
}

- (void)awakeFromNib {
    NSMutableDictionary *linkAttributes = [NSMutableDictionary dictionaryWithCapacity:2];
    [linkAttributes setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    [linkAttributes setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
    [previewText setLinkTextAttributes:linkAttributes];
    
    
    [previewText setTextColor:[NSColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showPreviewData:)
                                                 name:NotificationShowPreviewData object:nil];    
}

- (void)finalize {
    [super finalize];
}

- (void)windowWillClose:(NSNotification *)notification {
    [userDefaults setBool:NO forKey:DefaultsShowHUDPreview];
    
    if(delegate && [delegate respondsToSelector:@selector(auxWindowClosing:)]) {
        [delegate performSelector:@selector(auxWindowClosing:) withObject:self];
    } else {
        CocoLog(LEVEL_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - Notifications

- (void)showPreviewData:(NSNotification *)aNotification {
    NSDictionary *data = [aNotification object];
    NSDictionary *previewDict = [HUDPreviewController previewDataFromDict:data forTextType:TextTypeRendered];
    if(previewDict) {
        [previewType setStringValue:[previewDict objectForKey:PreviewDisplayTypeKey]];

        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:[NSNumber numberWithInt:NSUTF8StringEncoding] forKey:NSCharacterEncodingDocumentOption];
        WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferences];
        [options setObject:webPrefs forKey:NSWebPreferencesDocumentOption];
        [options setObject:[NSColor lightGrayColor] forKey:NSForegroundColorAttributeName];
                
        NSData *tempData = [[previewDict objectForKey:PreviewDisplayTextKey] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableAttributedString *tempDisplayString = [[[NSMutableAttributedString alloc] initWithHTML:tempData
                                                                                               options:options
                                                                                    documentAttributes:nil] autorelease];
        
        
        [[previewText textStorage] setAttributedString:tempDisplayString];
    }
}

#pragma mark - Actions


@end
