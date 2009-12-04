//
//  ContentDisplayingViewController.m
//  MacSword2
//
//  Created by Manfred Bergmann on 18.11.09.
//  Copyright 2009 Software by MABE. All rights reserved.
//

#import "ContentDisplayingViewController.h"
#import "NotesViewController.h"
#import "BibleViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "GenBookViewController.h"
#import "DictionaryViewController.h"


@implementation ContentDisplayingViewController

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

@end
