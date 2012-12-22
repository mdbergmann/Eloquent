//
//  ContentDisplayingViewController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "HUDPreviewController.h"
#import "MBPreferenceController.h"
#import "globals.h"
#import "NotesViewController.h"
#import "ModuleCommonsViewController.h"
#import "ModuleViewController.h"
#import "GenBookViewController.h"
#import "DictionaryViewController.h"
#import "NSTextView+LookupAdditions.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordKey.h"
#import "WorkspaceViewHostController.h"
#import "AppController.h"
#import "CacheObject.h"
#import "ObjectAssociations.h"
#import "ContentDisplayingViewControllerFactory.h"
#import "SwordUtil.h"
#import "SwordModule+SearchKitIndex.h"
#import "ProgressOverlayViewController.h"
#import "CommentaryViewController.h"
#import "BibleCombiViewController.h"
#import "ModulesUIController.h"
#import "SingleViewHostController.h"

extern char ModuleListUI;

@interface ContentDisplayingViewController ()

@property (retain, readwrite) NSURL *contextMenuClickedLink;
@property (readwrite) NSRange clickedLinkTextRange;

- (NSDictionary *)textAttributesOfLastEventLocation;
- (NSString *)processPreviewDisplay:(NSURL *)aUrl;

@end

@implementation ContentDisplayingViewController

@synthesize forceRedisplay;
@synthesize contextMenuClickedLink;
@synthesize clickedLinkTextRange;
@synthesize lastEvent;
@synthesize contentCache;
@synthesize progressController;
@dynamic progressActionType;


- (id)init {
    self = [super init];
    if(self) {
        [self setContextMenuClickedLink:nil];
        [self setClickedLinkTextRange:NSMakeRange(NSNotFound, 0)];
        [self setForceRedisplay:NO];
        [self setLastEvent:nil];
        [self setContentCache:[[[CacheObject alloc] init] autorelease]];
        progressActionType = ReferenceLookupAction;
        
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    progressController = [[ProgressOverlayViewController alloc] init];
}

- (void)finalize {
    [super finalize];
}

- (void)dealloc {
    [progressController release];
    [contentCache release];
    [contextMenuClickedLink release];
    [lastEvent release];

    [super dealloc];
}

- (void)awakeFromNib {
}

- (ModulesUIController *)modulesUIController {
    return [Associater objectForAssociatedObject:hostingDelegate withKey:&ModuleListUI];
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

- (IBAction)saveDocument:(id)sender {
}

- (BOOL)isSwordModuleContentType {
    return [self contentViewType] < SwordModuleContentType;
}

- (BOOL)isNoteContentType {
    return ([self contentViewType] == NoteContentType);
}

#pragma mark - TextDisplayable protocol

- (void)displayText {    
}

- (void)displayTextForReference:(NSString *)aReference {
    // do nothing here, subclass will handle    
}

- (void)displayTextForReference:(NSString *)aReference searchType:(SearchType)aType {
    // do nothing here, subclass will handle
}

#pragma mark - HostViewDelegate

- (void)searchStringChanged:(NSString *)aSearchString {    
    [super searchStringChanged:aSearchString];
    [self displayTextForReference:searchString];
}

- (void)searchTypeChanged:(SearchType)aSearchType withSearchString:(NSString *)aSearchString {
    [super searchTypeChanged:aSearchType withSearchString:aSearchString];
}

- (void)forceReload {
    forceRedisplay = YES;
    [self displayTextForReference:searchString];
    forceRedisplay = NO;
}

- (NSView *)topAccessoryView {
    return topAccessoryView;
}

- (void)prepareContentForHost:(WindowHostController *)aHostController {
    [super prepareContentForHost:aHostController];
    // populate menu items with modules
    // bibles
    NSMenu *bibleModules = [[[NSMenu alloc] init] autorelease];
    [[self modulesUIController] generateModuleMenu:&bibleModules
                                     forModuletype:Bible 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(lookUpInIndexOfBible:)];
    NSMenuItem *item = [textContextMenu itemWithTag:LookUpInIndexList];
    [item setSubmenu:bibleModules];
    // dictionaries
    NSMenu *dictModules = [[[NSMenu alloc] init] autorelease];
    [[self modulesUIController] generateModuleMenu:&dictModules 
                                     forModuletype:Dictionary 
                                    withMenuTarget:self 
                                    withMenuAction:@selector(lookUpInDictionaryOfModule:)];
    item = [textContextMenu itemWithTag:LookUpInDictionaryList];
    [item setSubmenu:dictModules];
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
        [self setLastEvent:event];
        NSDictionary *attrs = [self textAttributesOfLastEventLocation];
        NSURL *link = [attrs objectForKey:NSLinkAttributeName];
        if(link) {
            ret = linkContextMenu;
            self.contextMenuClickedLink = link;
        } else if([attrs objectForKey:NSAttachmentAttributeName] != nil) {
            ret = imageContextMenu;            
        }
    }
    
    return ret;
}

- (BOOL)linkClicked:(id)link {
    NSDictionary *data = [SwordUtil dictionaryFromUrl:link];
    NSString *attrType = [data objectForKey:ATTRTYPE_TYPE];
    if([attrType isEqualToString:@"n"]) {
        [self processPreviewDisplay:link];
    } else {
        [self openClickedLink:link];
    }
    
    return YES;
}

- (void)openClickedLink:(NSURL *)link {
    // get data for the link
    NSDictionary *data = [SwordUtil dictionaryFromUrl:link];
    NSString *modName = [data objectForKey:ATTRTYPE_MODULE];
    if(!modName || [modName length] == 0) {
        // get default bible module
        modName = [userDefaults stringForKey:DefaultsBibleModule];
        NSString *attrType = [data objectForKey:ATTRTYPE_TYPE];
        if([attrType isEqualToString:@"Hebrew"]) {
            modName = [userDefaults stringForKey:DefaultsStrongsHebrewModule];
        } else if([attrType isEqualToString:@"Greek"]) {
            modName = [userDefaults stringForKey:DefaultsStrongsGreekModule];
        } else if([attrType hasPrefix:@"strongMorph"] || [attrType hasPrefix:@"robinson"]) {
            modName = [userDefaults stringForKey:DefaultsMorphGreekModule];
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
            ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
            [hc setDelegate:hostingDelegate];
            [hostingDelegate addContentViewController:hc];
            [hostingDelegate setSearchText:key];
        } else {
            // in case there is no hosting delegate, create a new single one
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchText:key];
        }
    }
}

- (NSString *)processPreviewDisplay:(NSURL *)aUrl {
    NSDictionary *linkResult = [SwordUtil dictionaryFromUrl:aUrl];
    SendNotifyShowPreviewData(linkResult);
    
    CocoLog(LEVEL_DEBUG, @"classname: %@", [aUrl className]);    
    CocoLog(LEVEL_DEBUG, @"link: %@", [aUrl description]);
    if([userDefaults boolForKey:DefaultsShowPreviewToolTip]) {
        return [[HUDPreviewController previewDataFromDict:linkResult] objectForKey:PreviewDisplayTextKey];
    }
    
    return @"";
}

- (NSDictionary *)textAttributesOfLastEventLocation {
    NSTextView *textView = [(id<TextContentProviding>)contentDisplayController textView];
    
    // get mouse cursor location
    NSPoint eventLocation = [lastEvent locationInWindow];
    NSPoint localPoint = [textView convertPoint:eventLocation fromView:nil];
    NSUInteger glyphIndex = [[textView layoutManager] glyphIndexForPoint:localPoint inTextContainer:[textView textContainer]];
    NSUInteger characterIndex = [[textView layoutManager] characterIndexForGlyphAtIndex:glyphIndex];
    
    return [[textView textStorage] attributesAtIndex:characterIndex effectiveRange:&clickedLinkTextRange];
}

#pragma mark - Context Menu validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    BOOL ret = YES;
    SEL selector = [menuItem action];

    if([menuItem menu] == textContextMenu) {
        NSAttributedString *textSelection = [[(id<TextContentProviding>)contentDisplayController textView] selectedAttributedString];

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
            NSDictionary *data = [SwordUtil dictionaryFromUrl:contextMenuClickedLink];
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
        } else if(selector == @selector(removeLink:)) {
            NSDictionary *attrs = [self textAttributesOfLastEventLocation];
            NSURL *link = [attrs objectForKey:NSLinkAttributeName];
            if(link == nil) {
                ret = NO;
            }
        }
        return ret;
    }
    
    return YES;
}


#pragma mark - Text Context Menu actions

- (IBAction)lookUpInIndex:(id)sender {
    NSString *sel = [[(id<TextContentProviding>)contentDisplayController textView] selectedString];
    if(sel != nil) {
        if([self isSwordModuleContentType]) {
            // we have a module to lookup
            // if the host is a single view, switch to index and search for the given word
            if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
                [hostingDelegate setSearchTypeUI:IndexSearchType];
                [hostingDelegate setSearchText:sel];
            } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                [hostingDelegate setSearchTypeUI:IndexSearchType];
                [hostingDelegate setSearchText:sel];
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
                    [host setSearchTypeUI:IndexSearchType];
                    [hostingDelegate setSearchText:sel];
                } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
                    ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:bib];
                    [hc setDelegate:hostingDelegate];
                    [hostingDelegate addContentViewController:hc];
                    [hostingDelegate setSearchTypeUI:IndexSearchType];
                    [hostingDelegate setSearchText:sel];
                }            
            }            
        }
    }
}

- (IBAction)lookUpInIndexOfBible:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [[(id<TextContentProviding>)contentDisplayController textView] selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            // create new single host
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchTypeUI:IndexSearchType];
            [hostingDelegate setSearchText:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
            [hc setDelegate:hostingDelegate];
            [hostingDelegate addContentViewController:hc];
            [hostingDelegate setSearchTypeUI:IndexSearchType];
            [hostingDelegate setSearchText:sel];
        }
    }
}

- (IBAction)lookUpInDictionary:(id)sender {
    NSString *sel = [[(id<TextContentProviding>)contentDisplayController textView] selectedString];
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
                ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:dict];
                [hc setDelegate:hostingDelegate];
                [hostingDelegate addContentViewController:hc];
                [hostingDelegate setSearchText:sel];        
            }            
        }        
    }
}

- (IBAction)lookUpInDictionaryOfModule:(id)sender {
    NSMenuItem *item = (NSMenuItem *)sender;
    NSString *modName = [item title];
    SwordModule *mod = [[SwordManager defaultManager] moduleWithName:modName];
    
    // get selection
    NSString *sel = [[(id<TextContentProviding>)contentDisplayController textView] selectedString];
    if(sel != nil) {
        if([hostingDelegate isKindOfClass:[SingleViewHostController class]]) {
            SingleViewHostController *host = [[AppController defaultAppController] openSingleHostWindowForModule:mod];
            [host setSearchText:sel];
        } else if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
            ContentDisplayingViewController *hc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModule:mod];
            [hc setDelegate:hostingDelegate];
            [hostingDelegate addContentViewController:hc];
            [hostingDelegate setSearchText:sel];        
        }            
    }    
}

#pragma mark - Link Context Menu actions

- (IBAction)openLink:(id)sender {
    [self openClickedLink:self.contextMenuClickedLink];
}

- (IBAction)removeLink:(id)sender {
    if(clickedLinkTextRange.location != NSNotFound) {
        NSTextView *textView = [(id<TextContentProviding>)contentDisplayController textView];
        NSMutableAttributedString *textStorage = [textView textStorage];
        [textStorage removeAttribute:NSLinkAttributeName range:clickedLinkTextRange];
        [textStorage removeAttribute:TEXT_VERSE_MARKER range:clickedLinkTextRange];
        [(id<TextContentProviding>)contentDisplayController textChanged:[NSNotification notificationWithName:@"TextChangedNotification" object:textView]];
    }
}

#pragma mark - ProgressIndicating

- (void)beginIndicateProgress {
}

- (void)endIndicateProgress {
}

- (id)progressIndicator {
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        return [(BibleCombiViewController *)delegate progressController];
    } else {
        return [self progressController];
    }
}

- (void)setProgressActionType:(ProgressActionType)aType {
    progressActionType = aType;
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [(BibleCombiViewController *)delegate setProgressActionType:aType];
    }
}

- (ProgressActionType)progressActionType {
    return progressActionType;
}

- (void)putProgressOverlayView {
    NSView *progressView = [progressController view];
    NSView *barProgressView = [progressController barProgressView];
    
    if(![[[self view] subviews] containsObject:progressView] &&
       ![[[self view] subviews] containsObject:barProgressView]) {
        
        NSView *pView = progressView;
        if(progressActionType == IndexCreateAction) {
            pView = barProgressView;
        }
        // we need the same size
        [pView setFrame:[[self view] frame]];
        [progressController startProgressAnimation];
        [[self view] addSubview:pView];
        [[[self view] superview] setNeedsDisplay:YES];
    }    
}

- (void)removeProgressOverlayView {
    NSView *progressView = [progressController view];
    NSView *barProgressView = [progressController barProgressView];
    
    [progressController stopProgressAnimation];
    NSView *pcView = [self view];
    if(pcView) {
        if([[pcView subviews] containsObject:progressView]) {
            [progressView removeFromSuperview];
        }
        if([[pcView subviews] containsObject:barProgressView]) {
            [barProgressView removeFromSuperview];
        }
    }    
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
