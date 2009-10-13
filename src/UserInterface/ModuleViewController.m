//
//  ModuleViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 15.06.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ModuleViewController.h"
#import "globals.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "AppController.h"
#import "ExtTextViewController.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "BibleCombiViewController.h"
#import "IndexingManager.h"
#import "SwordModuleTextEntry.h"

@interface ModuleViewController () 

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification;

@end

@implementation ModuleViewController

#pragma mark - getter/setter

@synthesize module;
@synthesize contextMenuClickedLink;
@synthesize performProgressCalculation;

#pragma mark - Initializers

- (id)init {
    self = [super init];
    if(self) {
        performProgressCalculation = YES;
        
        // pre-set search type to Reference
        searchType = ReferenceSearchType;
        
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];

        // register for modules changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // add custom menu Additions
    [textContextMenu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *mi = [textContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];

    [linkContextMenu addItem:[NSMenuItem separatorItem]];
    mi = [linkContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];

    [imageContextMenu addItem:[NSMenuItem separatorItem]];
    mi = [imageContextMenu addItemWithTitle:NSLocalizedString(@"ShowModuleAbout", @"") action:@selector(displayModuleAbout:) keyEquivalent:@""];
    [mi setTarget:self];
    [mi setTag:ShowModuleAbout];
}

#pragma mark - Methods

/** notification, called when modules have changed */
- (void)modulesListChanged:(NSNotification *)aNotification {
    [self populateModulesMenu];
}

- (void)populateModulesMenu {
    // subclass will handle
}

- (void)setStatusText:(NSString *)aText {
    // subclass will handle    
}

/**
 Generates NSAttributedString from search results
 this is an abstract method, should be overriden by subclasses
 @param[in] results array of SearchResults instances
 @param[in] searchQuery
 @param[out] number of verses found
 @return attributed string
 */
- (NSAttributedString *)displayableHTMLFromSearchResults:(NSArray *)tempResults searchQuery:(NSString *)searchQuery numberOfResults:(int *)results {
    return nil;
}

#pragma mark - Indexer delegate method

- (void)searchOperationFinished:(NSArray *)results {
    // close indexer
    if(indexer) {
        [[IndexingManager sharedManager] closeIndexer:indexer];
    }
    
    NSAttributedString *text = nil;    
    if(results) {
        int verses = 0;
        text = [self displayableHTMLFromSearchResults:results searchQuery:reference numberOfResults:&verses];
        
        // set status
        NSString *statusText = [NSString stringWithFormat:@"Found %i verses", verses];                        
        [self setStatusText:statusText];
    }
    
    // display
    if(text) {
        [textViewController setAttributedString:text];     
    }
    
    // stop indicating progress
    [self endIndicateProgress];    
}

- (void)indexCreationFinished:(SwordModule *)mod {
    // stop progress indicator
    [self endIndicateProgress];
    
    // I guess the user actually wanted to search for something
    // let's do this now
    [self displayTextForReference:reference];
}

- (NSTextView *)textView {
    return [textViewController textView];
}

#pragma mark - Printing

- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    // paper size
    NSSize paperSize = [printInfo paperSize];
    
    // set print size
    NSSize printSize = NSMakeSize(paperSize.width - ([printInfo leftMargin] + [printInfo rightMargin]), 
                                  paperSize.height - ([printInfo topMargin] + [printInfo bottomMargin]));
    
    // create print view
    NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, printSize.width, printSize.height)];
    [printView insertText:[[self textView] attributedString]];
    
    return printView;
}

#pragma mark - Hostable delegate methods

- (void)contentViewInitFinished:(HostableViewController *)aView {
}

- (NSString *)label {
    if(module != nil) {
        return [module name];
    }
    
    return @"ModuleView";
}

#pragma mark - Text Context Menu actions

- (IBAction)lookUpInIndex:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[ModuleViewController -loopUpInIndex:]");
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        // if the host is a single view, switch to index and search for the given word
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            [(SingleViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        }
    }
}

- (IBAction)lookUpInIndexOfBible:(id)sender {
    // sender is the menuitem
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // create new single host
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchUIType:IndexSearchType searchString:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];
            [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
        }
    }
}

- (IBAction)lookUpInDictionary:(id)sender {
    MBLOG(MBLOG_DEBUG, @"[ModuleViewController -loopUpInDictionary:]");
    
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        // get default dictionary module
        NSString *defDictName = [userDefaults stringForKey:DefaultsDictionaryModule];
        if(defDictName == nil) {
            // requester to set default dictionary module
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Information", @"") 
                                             defaultButton:NSLocalizedString(@"OK" , @"")
                                           alternateButton:nil 
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedString(@"NoDefaultDictionarySelected", @"")];
            [alert runModal];
        } else {
            SwordModule *dict = [[SwordManager defaultManager] moduleWithName:defDictName];
            if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:dict];
                [host setSearchText:sel];
            } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:dict];
                [(WorkspaceViewHostController *)hostingDelegate setSearchText:sel];        
            }            
        }        
    }
}

- (IBAction)lookUpInDictionaryOfModule:(id)sender {
    // sender is the menuitem
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [textViewController selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchText:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];
            [(WorkspaceViewHostController *)hostingDelegate setSearchText:sel];        
        }            
    }    
}

#pragma mark - Link Context Menu actions

- (IBAction)openLink:(id)sender {
    // get data for the link
    NSDictionary *data = [textViewController dataForLink:contextMenuClickedLink];
    if(data) {
        NSString *modName = [data objectForKey:ATTRTYPE_MODULE];
        if(!modName || [modName length] == 0) {
            // get default bible module
            modName = [userDefaults stringForKey:DefaultsBibleModule];
            NSString *attrType = [data objectForKey:ATTRTYPE_TYPE];
            if([attrType isEqualToString:@"Hebrew"]) {
                modName = [userDefaults stringForKey:DefaultsStrongsHebrewModule];
            } else if([attrType isEqualToString:@"Greek"]) {
                modName = [userDefaults stringForKey:DefaultsStrongsGreekModule];
            }
        }
        
        if(modName) {
            SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
            
            id result = [mod attributeValueForParsedLinkData:data];
            NSMutableString *key = [NSMutableString string];
            if([result isKindOfClass:[SwordModuleTextEntry class]]) {
                key = [NSMutableString stringWithString:[(SwordModuleTextEntry *)result key]];
            } else if([result isKindOfClass:[NSArray class]]) {
                for(SwordModuleTextEntry *entry in (NSArray *)result) {
                    [key appendFormat:@"%@;", [entry key]];
                }
            }
            
            // open
            if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
                [host setSearchText:key];
            } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:mod];
                [(WorkspaceViewHostController *)hostingDelegate setSearchText:key];        
            }            
        }
    }    
}

#pragma mark - General menu

- (IBAction)displayModuleAbout:(id)sender {
    if(hostingDelegate) {
        if([hostingDelegate respondsToSelector:@selector(displayModuleAboutSheetForModule:)]) {
            [hostingDelegate performSelector:@selector(displayModuleAboutSheetForModule:) withObject:module];
        }
    }
}

#pragma mark - Context Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    MBLOGV(MBLOG_DEBUG, @"[ModuleViewController -validateMenuItem:] %@", [menuItem description]);
    
    if([menuItem menu] == textContextMenu) {
        // we need the length of the selected text
        NSString *textSelection = [textViewController selectedString];
        
        BOOL ret = YES;
        int tag = [menuItem tag];
        switch(tag) {
            case LookUpInIndexDefault:
                if([textSelection length] == 0) {
                    ret = NO;
                }
                break;
            case LookUpInIndexList:
                if([[menuItem submenu] numberOfItems] == 0 || [textSelection length] == 0) {
                    ret = NO;
                }
                break;
            case LookUpInDictionaryDefault:
                if([userDefaults objectForKey:DefaultsDictionaryModule] == nil || [textSelection length] == 0) {
                    ret = NO;
                }
                break;
            case LookUpInDictionaryList:
                if([[menuItem submenu] numberOfItems] == 0 || [textSelection length] == 0) {
                    ret = NO;
                }
                break;
        }
        
        return ret;
    } else if([menuItem menu] == linkContextMenu) {
        BOOL ret = YES;
        switch([menuItem tag]) {
            case OpenLink:
            {
                NSDictionary *data = [textViewController dataForLink:contextMenuClickedLink];
                if(data) {
                    // this is all we can open
                    NSString *attrType = [data objectForKey:ATTRTYPE_TYPE];
                    if(![attrType isEqualToString:@"x"] &&
                       ![attrType isEqualToString:@"scriptRef"] &&
                       ![attrType isEqualToString:@"scripRef"] &&
                       ![attrType isEqualToString:@"Greek"] &&
                       ![attrType isEqualToString:@"Hebrew"]) {
                        ret = NO;
                    }                    
                }
                break;
            }
        }
        
        return ret;
    } else if([menuItem menu] == modDisplayOptionsMenu) {
        BOOL ret = NO;

        switch([menuItem tag]) {
            case 1:
                if([module hasFeature:SWMOD_FEATURE_STRONGS]) {
                    ret = YES;
                }
                break;
            case 2:
                if([module hasFeature:SWMOD_FEATURE_MORPH]) {
                    ret = YES;
                }
                break;
            case 3:
                if([module hasFeature:SWMOD_FEATURE_FOOTNOTES]) {
                    ret = YES;
                }
                break;
            case 4:
                if([module hasFeature:SWMOD_FEATURE_SCRIPTREF]) {
                    ret = YES;
                }
                break;
            case 5:
                if([module hasFeature:SWMOD_FEATURE_REDLETTERWORDS]) {
                    ret = YES;
                }
                break;
            case 6:
                if([module hasFeature:SWMOD_FEATURE_HEADINGS]) {
                    ret = YES;
                }
                break;
            case 7:
                if([module hasFeature:SWMOD_FEATURE_HEBREWPOINTS]) {
                    ret = YES;
                }
                break;
            case 8:
                if([module hasFeature:SWMOD_FEATURE_CANTILLATION]) {
                    ret = YES;
                }
                break;
            case 9:
                if([module hasFeature:SWMOD_FEATURE_GREEKACCENTS]) {
                    ret = YES;
                }
                break;
        }
        
        return ret;
    }
    
    return YES;
}

#pragma mark - ExtTextViewController delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    MBLOGV(MBLOG_DEBUG, @"[ModuleViewController -menuForEvent:] %@\n", [event description]);
    
    NSMenu *ret = nil;
    
    // get the current position of the mouse
    if([event type] == NSRightMouseDown) {
        
        // get mouse cursor location
        NSPoint eventLocation = [event locationInWindow];
        NSPoint localPoint = [[textViewController textView] convertPoint:eventLocation fromView:nil];
        int glyphIndex = [[[textViewController textView] layoutManager] glyphIndexForPoint:localPoint inTextContainer:[[textViewController textView] textContainer]];
        int characterIndex = [[[textViewController textView] layoutManager] characterIndexForGlyphAtIndex:glyphIndex];
        NSDictionary *attrs = [[[textViewController textView] textStorage] attributesAtIndex:characterIndex effectiveRange:nil];
        // is link?
        NSURL *link = [attrs objectForKey:NSLinkAttributeName];
        if(link != nil) {
            ret = linkContextMenu;
            
            // save the URL
            contextMenuClickedLink = link;
            
        } else if([attrs objectForKey:NSAttachmentAttributeName] != nil) {
            ret = imageContextMenu;            
        } else {
            ret = textContextMenu;        
        }
    }
    
    return ret;
}

#pragma mark - ContextMenuProviding protocol

- (NSMenu *)textContextMenu {
    return textContextMenu;
}

- (NSMenu *)linkContextMenu {
    return linkContextMenu;
}

- (NSMenu *)imageContextMenu {
    return imageContextMenu;
}

#pragma mark - NSCoding protocol

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self) {
        performProgressCalculation = YES;
        // pre-set search type to Reference
        searchType = ReferenceSearchType;
        // decode module name
        NSString *moduleName = [decoder decodeObjectForKey:@"ModuleNameEncoded"];
        // set module
        self.module = [[SwordManager defaultManager] moduleWithName:moduleName];
        
        // create textview controller
        textViewController = [[ExtTextViewController alloc] initWithDelegate:self];

        // register for modules changed notification
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(modulesListChanged:)
                                                     name:NotificationModulesChanged object:nil];            

        forceRedisplay = NO;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    // encode common things first
    [super encodeWithCoder:encoder];
    // encode module name
    [encoder encodeObject:[module name] forKey:@"ModuleNameEncoded"];
}

@end
