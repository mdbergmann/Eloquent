//
//  HUDPreviewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 10.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HUDPreviewController.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "globals.h"


@implementation HUDPreviewController

- (id)init {
    return [super init];
}

- (void)awakeFromNib {
    MBLOG(MBLOG_DEBUG, @"[HUDPreviewController -awakeFromNib]");
    
    // register notification 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(showPreviewData:)
                                                 name:NotificationShowPreviewData object:nil];
    
}

- (void)finalize {
    [super finalize];
}

#pragma mark - Notifications

- (void)showPreviewData:(NSNotification *)aNotification {
    // get object
    NSDictionary *data = [aNotification object];
    if(data) {
        NSString *module = [data objectForKey:ATTRTYPE_MODULE];
        if(!module || [module length] == 0) {
            // get default bible module
            module = [userDefaults stringForKey:DefaultsBibleModule];
            if([[data objectForKey:ATTRTYPE_TYPE] isEqualToString:@"Hebrew"]) {
                module = [userDefaults stringForKey:DefaultsStrongsHebrewModule];
            } else if([[data objectForKey:ATTRTYPE_TYPE] isEqualToString:@"Hebrew"]) {
                module = [userDefaults stringForKey:DefaultsStrongsGreekModule];
            }
        }
        
        if(module) {
            SwordModule *mod = [[SwordManager defaultManager] moduleWithName:module];
            NSMutableString *displayText = [NSMutableString string];
            NSString *displayType = @"";
            if([[data objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showNote"]) {
                if([[data objectForKey:ATTRTYPE_TYPE] isEqualToString:@"n"]) {
                    displayType = SW_OPTION_FOOTNOTES;
                } else if([[data objectForKey:ATTRTYPE_TYPE] isEqualToString:@"x"]) {
                    displayType = SW_OPTION_SCRIPTREFS;                    
                }
            } else if([[data objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showStrongs"]) {
                displayType = SW_OPTION_STRONGS;            
            } else if([[data objectForKey:ATTRTYPE_ACTION] isEqualToString:@"showRef"]) {
                displayType = SW_OPTION_REF;                
            }
            [previewType setStringValue:displayType];
            
            id result = [mod attributeValueForEntryData:data];
            if(result != nil) {
                if([result isKindOfClass:[NSArray class]]) {
                    // prepare for view
                    for(NSDictionary *dict in (NSArray *)result) {
                        NSString *verseText = [dict objectForKey:SW_OUTPUT_TEXT_KEY];
                        NSString *key = [dict objectForKey:SW_OUTPUT_REF_KEY];
                        
                        [displayText appendFormat:@"%@:\n%@\n", key, verseText];
                    }                    
                } else if([result isKindOfClass:[NSString class]]) {
                    displayText = result;
                }
            }
            // show
            [previewText setStringValue:displayText];            
        }
    }
}

#pragma mark - Actions


@end
