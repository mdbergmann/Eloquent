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

+ (NSString *)createHtmlVerseForKey:(NSString *)aKey
                            andText:(NSString *)verseText
                     withStyleColor:(NSString *)styleColorSting
                      andModuleName:(NSString *)aModName;

@end


@implementation HUDPreviewController

@synthesize delegate;

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData {
    return [HUDPreviewController previewDataFromDict:previewData forRenderType:RenderTypeStripped];
}

+ (NSDictionary *)previewDataFromDict:(NSDictionary *)previewData forRenderType:(RenderType)textType {
    NSMutableDictionary *ret = nil;
    
    if(previewData) {
        
        // headings fg color
        CGFloat hr, hg, hb = 0.0;
        NSColor *hfCol = [NSColor colorWithCalibratedRed:0.10 green:0.10 blue:0.10 alpha:0.0];
        [hfCol getRed:&hr green:&hg blue:&hb alpha:NULL];    
        NSString *previewPaneTextColor = [NSString stringWithFormat:@"color:rgb(%i%%, %i%%, %i%%);",
                                          (int)(hr * 100.0), (int)(hg * 100.0), (int)(hb * 100.0)];
        
        NSString *module = previewData[ATTRTYPE_MODULE];
        if(!module || [module length] == 0) {
            // get module for previewtype
            module = [UserDefaults stringForKey:DefaultsBibleModule];
            NSString *attrType = previewData[ATTRTYPE_TYPE];
            if([attrType isEqualToString:@"Hebrew"]) {
                module = [UserDefaults stringForKey:DefaultsStrongsHebrewModule];
            } else if([attrType isEqualToString:@"Greek"]) {
                module = [UserDefaults stringForKey:DefaultsStrongsGreekModule];
            } else if([attrType hasPrefix:@"strongMorph"] || [attrType hasPrefix:@"robinson"]) {
                module = [UserDefaults stringForKey:DefaultsMorphGreekModule];
            }
        }
        
        if(module) {
            ret = [NSMutableDictionary dictionary];
            
            SwordModule *mod = [[SwordManager defaultManager] moduleWithName:module];
            NSMutableString *displayText = [NSMutableString string];
            NSString *displayType = @"";
            if([previewData[ATTRTYPE_ACTION] isEqualToString:@"showNote"]) {
                if([previewData[ATTRTYPE_TYPE] isEqualToString:@"n"]) {
                    displayType = SW_OPTION_FOOTNOTES;
                } else if([previewData[ATTRTYPE_TYPE] isEqualToString:@"x"]) {
                    displayType = SW_OPTION_SCRIPTREFS;                    
                }
            } else if([previewData[ATTRTYPE_ACTION] isEqualToString:@"showStrongs"]) {
                displayType = SW_OPTION_STRONGS;            
            } else if([previewData[ATTRTYPE_ACTION] isEqualToString:@"showMorph"]) {
                displayType = SW_OPTION_MORPHS;
            } else if([previewData[ATTRTYPE_ACTION] isEqualToString:@"showRef"]) {
                displayType = SW_OPTION_REF;
            }
            ret[@"PreviewDisplayTypeKey"] = displayType;
            
            id result = [mod attributeValueForParsedLinkData:previewData withTextRenderType:textType];
            if(result != nil) {
                if([result isKindOfClass:[NSArray class]]) {
                    // prepare for view
                    for(SwordModuleTextEntry *entry in (NSArray *)result) {
                        NSString *verseText = [entry text];
                        NSString *key = [entry key];
                        
                        if(textType == RenderTypeStripped) {
                            [displayText appendFormat:@"%@:\n%@\n", key, verseText];                            
                        } else {
                            [displayText appendString:[HUDPreviewController createHtmlVerseForKey:key
                                                                                          andText:verseText
                                                                                   withStyleColor:previewPaneTextColor
                                                                                    andModuleName:module]];
                        }
                    }
                } else if([result isKindOfClass:[NSString class]]) {
                    if(textType == RenderTypeRendered) {
                        displayText = [NSMutableString stringWithFormat:@"<span style=\"%@\">%@</span>", previewPaneTextColor, result];
                    } else {
                        displayText = result;
                    }
                } else if([result isKindOfClass:[SwordModuleTextEntry class]]) {
                    NSString *verseText = [(SwordModuleTextEntry *)result text];
                    NSString *key = [(SwordModuleTextEntry *)result key];
                    
                    if(textType == RenderTypeStripped) {
                        [displayText appendFormat:@"%@:\n%@\n", key, verseText];                            
                    } else {
                        [displayText appendString:[HUDPreviewController createHtmlVerseForKey:key
                                                                                      andText:verseText
                                                                               withStyleColor:previewPaneTextColor
                                                                                andModuleName:module]];
                    }
                }
            }
            ret[@"PreviewDisplayTextKey"] = displayText;
        }      
    }
    
    return ret;    
}

+ (NSString *)createHtmlVerseForKey:(NSString *)aKey
                            andText:(NSString *)verseText
                     withStyleColor:(NSString *)styleColorSting
                      andModuleName:(NSString *)aModName {
    return [NSString stringWithFormat:@"<span style=\"%@\"><a href=\"sword://%@/%@\">%@</a>:<br />%@<br /></span>",
            styleColorSting, aModName, aKey, aKey, verseText];
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
    linkAttributes[NSForegroundColorAttributeName] = [NSColor lightGrayColor];
    linkAttributes[NSCursorAttributeName] = [NSCursor pointingHandCursor];
    [previewText setLinkTextAttributes:linkAttributes];
    
    
    [previewText setTextColor:[NSColor lightGrayColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showPreviewData:)
                                                 name:NotificationShowPreviewData object:nil];    
}


- (void)windowWillClose:(NSNotification *)notification {
    if(delegate && [delegate respondsToSelector:@selector(auxWindowClosing:)]) {
        [delegate performSelector:@selector(auxWindowClosing:) withObject:self];
    } else {
        CocoLog(LEVEL_WARN, @"[WindowHostController -windowWillClose:] delegate does not respond to selector!");
    }
}

#pragma mark - Notifications

- (void)showPreviewData:(NSNotification *)aNotification {
    NSDictionary *data = [aNotification object];
    NSDictionary *previewDict = [HUDPreviewController previewDataFromDict:data forRenderType:RenderTypeRendered];
    if(previewDict) {
        [previewType setStringValue:previewDict[PreviewDisplayTypeKey]];

        
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        options[NSCharacterEncodingDocumentOption] = @(NSUTF8StringEncoding);
        WebPreferences *webPrefs = [[MBPreferenceController defaultPrefsController] defaultWebPreferences];
        options[NSWebPreferencesDocumentOption] = webPrefs;
        options[NSForegroundColorAttributeName] = [NSColor lightGrayColor];
                
        NSData *tempData = [previewDict[PreviewDisplayTextKey] dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableAttributedString *tempDisplayString = [[NSMutableAttributedString alloc] initWithHTML:tempData
                                                                                               options:options
                                                                                    documentAttributes:nil];
        
        
        [[previewText textStorage] setAttributedString:tempDisplayString];
    }
}

#pragma mark - Actions


@end
