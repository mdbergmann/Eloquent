//
//  HostableViewControllerFactory.m
//  Eloquent
//
//  Created by Manfred Bergmann on 22.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ContentDisplayingViewControllerFactory.h"
#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "BibleCombiViewController.h"
#import "CommentaryViewController.h"
#import "DictionaryViewController.h"
#import "GenBookViewController.h"
#import "NotesViewController.h"

@implementation ContentDisplayingViewControllerFactory

+ (ContentDisplayingViewController *)createSwordModuleViewControllerForModule:(SwordModule *)aModule {
    ContentDisplayingViewController *vc = [ContentDisplayingViewControllerFactory createSwordModuleViewControllerForModuleType:[aModule type]];
    if(vc) {
        if([vc isKindOfClass:[BibleCombiViewController class]]) {
            [(BibleCombiViewController *)vc addNewBibleViewWithModule:aModule];
        } else {
            [(ModuleViewController *)vc setModule:aModule];
        }        
    }
    return vc;    
}

+ (ContentDisplayingViewController *)createSwordModuleViewControllerForModuleType:(ModuleType)aModuleType {
    ContentDisplayingViewController *vc = nil;    
    if(aModuleType == Bible) {
        vc = [[[BibleCombiViewController alloc] init] autorelease];
    } else if(aModuleType == Commentary) {
        vc = [[[CommentaryViewController alloc] init] autorelease];
    } else if(aModuleType == Dictionary) {
        vc = [[[DictionaryViewController alloc] init] autorelease];
    } else if(aModuleType == Genbook) {
        vc = [[[GenBookViewController alloc] init] autorelease];
    }
    return vc;    
}

+ (ContentDisplayingViewController *)createNotesViewControllerForFileRep:(FileRepresentation *)aFileRep {
    return [[[NotesViewController alloc] initWithFileRepresentation:aFileRep] autorelease];
}

@end
