//
//  ContentDisplayingViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "ContentDisplayingViewController.h"
#import "globals.h"
#import "NotesViewController.h"
#import "BibleViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "GenBookViewController.h"
#import "DictionaryViewController.h"
#import "NSTextView+LookupAdditions.h"
#import "MBPreferenceController.h"
#import "SwordManager.h"
#import "SingleViewHostController.h"
#import "WorkspaceViewHostController.h"
#import "AppController.h"
#import "SwordModuleTextEntry.h"
#import "ModuleListUIController.h"


@implementation ContentDisplayingViewController

@synthesize forceRedisplay;
@synthesize searchType;
@synthesize reference;
@synthesize contextMenuClickedLink;

- (id)init {
    self = [super init];
    if(self) {
        [self setReference:@""];
        forceRedisplay = NO;
    }
    return self;
}

- (void)finalize {
    [super finalize];
}

- (void)awakeFromNib {
    // populate menu items with modules
    NSMenu *bibleModules = [[NSMenu alloc] init];
    [ModuleListUIController generateModuleMenu:&bibleModules 
                                 forModuletype:bible 
                                withMenuTarget:self 
                                withMenuAction:@selector(lookUpInIndexOfBible:)];
    NSMenuItem *item = [textContextMenu itemWithTag:LookUpInIndexList];
    [item setSubmenu:bibleModules];
    NSMenu *dictModules = [[NSMenu alloc] init];
    [ModuleListUIController generateModuleMenu:&dictModules 
                                 forModuletype:dictionary 
                                withMenuTarget:self 
                                withMenuAction:@selector(lookUpInDictionaryOfModule:)];
    item = [textContextMenu itemWithTag:LookUpInDictionaryList];
    [item setSubmenu:dictModules];
}

- (void)hostingDelegateShowRightSideBar:(BOOL)aFlag {
    if(hostingDelegate && [hostingDelegate respondsToSelector:@selector(showRightSideBar:)]) {
        [hostingDelegate performSelector:@selector(showRightSideBar:)];
    }
}

- (ContentViewType)contentViewType {
    if([self isKindOfClass:[NotesViewController class]]) {
        return NoteContentType;
    } else if([self isKindOfClass:[GenBookViewController class]]) {
        return SwordGenBookContentType;
    } else if([self isKindOfClass:[DictionaryViewController class]]) {
        return SwordDictionaryContentType;
    } else if([self isKindOfClass:[CommentaryViewController class]]) {
        return SwordCommentaryContentType;
    } else if([self isKindOfClass:[BibleViewController class]] || [self isKindOfClass:[BibleCombiViewController class]]) {
        return SwordBibleContentType;
    }
    return SwordBibleContentType;
}

- (BOOL)isSwordModuleContentType {
    return [self contentViewType] < SwordModuleContentType;
}

- (BOOL)isNoteContentType {
    return ([self contentViewType] == NoteContentType);
}

#pragma mark - Printing

/** to be overriden by subclasses */
- (NSView *)printViewForInfo:(NSPrintInfo *)printInfo {
    return nil;
}

#pragma mark - ContentDisplayController delegates

- (NSMenu *)menuForEvent:(NSEvent *)event {
    NSMenu *ret = textContextMenu;
    
    if([event type] == NSRightMouseDown ||
       (([event type] == NSLeftMouseDown) && ([event modifierFlags] & NSControlKeyMask))) {
        NSTextView *textView = [(<TextContentProviding>)contentDisplayController textView];
        // get mouse cursor location
        NSPoint eventLocation = [event locationInWindow];
        NSPoint localPoint = [textView convertPoint:eventLocation fromView:nil];
        int glyphIndex = [[textView layoutManager] glyphIndexForPoint:localPoint inTextContainer:[textView textContainer]];
        int characterIndex = [[textView layoutManager] characterIndexForGlyphAtIndex:glyphIndex];
        NSDictionary *attrs = [[textView textStorage] attributesAtIndex:characterIndex effectiveRange:nil];
        // is link?
        NSURL *link = [attrs objectForKey:NSLinkAttributeName];
        if(link != nil) {
            ret = linkContextMenu;
            // save the URL
            contextMenuClickedLink = link;
        } else if([attrs objectForKey:NSAttachmentAttributeName] != nil) {
            ret = imageContextMenu;            
        }
    }
    
    return ret;
}

#pragma mark - Context Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL ret = YES;
    SEL selector = [menuItem action];

    if([menuItem menu] == textContextMenu) {
        // we need the length of the selected text
        NSString *textSelection = [[(<TextContentProviding>)contentDisplayController textView] selectedString];
        
        if(selector == @selector(lookUpInIndex:)) {
            if([textSelection length] == 0) {
                ret = NO;
            }            
        } else if(selector == @selector(lookUpInIndexOfBible:)) {
            if([[menuItem submenu] numberOfItems] == 0 || [textSelection length] == 0) {
                ret = NO;
            }            
        } else if(selector == @selector(lookUpInDictionary:)) {
            if([userDefaults objectForKey:DefaultsDictionaryModule] == nil || [textSelection length] == 0) {
                ret = NO;
            }
        } else if(selector == @selector(lookUpInDictionaryOfModule:)) {
            if([[menuItem submenu] numberOfItems] == 0 || [textSelection length] == 0) {
                ret = NO;
            }
        }        
        return ret;
    } else if([menuItem menu] == linkContextMenu) {
        if(selector == @selector(openLink:)) {
            NSDictionary *data = [SwordManager linkDataForLinkURL:contextMenuClickedLink];
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
        }        
        return ret;
    }
    
    return YES;
}

#pragma mark - Text Context Menu actions

- (IBAction)lookUpInIndex:(id)sender {
    NSString *sel = [[(<TextContentProviding>)contentDisplayController textView] selectedString];
    if(sel != nil) {
        if([self isSwordModuleContentType]) {
            // we have a module to lookup
            // if the host is a single view, switch to index and search for the given word
            if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                [(SingleViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
            } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];
            }
        } else {
            // otherwise use the default bible for lookup
            // get default bible module
            NSString *defBibleName = [userDefaults stringForKey:DefaultsBibleModule];
            if(defBibleName == nil) {
                NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"NoDefaultBibleSelected", @"") 
                                                 defaultButton:NSLocalizedString(@"OK" , @"")
                                               alternateButton:nil 
                                                   otherButton:nil
                                     informativeTextWithFormat:NSLocalizedString(@"NoDefaultBibleSelectedText", @"")];
                [alert runModal];
            } else {
                SwordModule *bib = [[SwordManager defaultManager] moduleWithName:defBibleName];
                if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                    SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:bib];
                    [host setSearchUIType:IndexSearchType searchString:sel];
                } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                    [(WorkspaceViewHostController *)hostingDelegate addTabContentForModule:bib];
                    [(WorkspaceViewHostController *)hostingDelegate setSearchUIType:IndexSearchType searchString:sel];        
                }            
            }            
        }
    }
}

- (IBAction)lookUpInIndexOfBible:(id)sender {
    // sender is the menuitem
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [[(<TextContentProviding>)contentDisplayController textView] selectedString];
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
    NSString *sel = [[(<TextContentProviding>)contentDisplayController textView] selectedString];
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
    NSString *sel = [[(<TextContentProviding>)contentDisplayController textView] selectedString];
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
    NSDictionary *data = [SwordManager linkDataForLinkURL:contextMenuClickedLink];
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
            int i = 0;
            for(SwordModuleTextEntry *entry in (NSArray *)result) {
                if(i > 0) {
                    [key appendString:@";"];
                }
                [key appendString:[entry key]];
                i++;
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

#pragma mark - AccessoryViewProviding

/** subclasses should provide real view */
- (NSView *)topAccessoryView {
    return topAccessoryView;
}

/** subclasses should provide real view */
- (NSView *)rightAccessoryView {
    return nil;
}

/** subclasses should override */
- (void)adaptTopAccessoryViewComponentsForSearchType:(SearchType)aType {
}

/** subclasses should override */
- (BOOL)showsRightSideBar {
    return NO;
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
}

- (void)endIndicateProgress {
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

@end
