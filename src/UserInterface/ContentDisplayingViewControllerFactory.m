//
//  HostableViewControllerFactory.m
//  MacSword2
//
//  Created by Manfred Bergmann on 22.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "ContentDisplayingViewControllerFactory.h"
#import "HostableViewController.h"
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
    if(aModuleType == bible) {
        vc = [[BibleCombiViewController alloc] init];
    } else if(aModuleType == commentary) {
        vc = [[CommentaryViewController alloc] init];
    } else if(aModuleType == dictionary) {
        vc = [[DictionaryViewController alloc] init];
    } else if(aModuleType == genbook) {
        vc = [[GenBookViewController alloc] init];
    }
    return vc;    
}

+ (ContentDisplayingViewController *)createNotesViewControllerForFileRep:(FileRepresentation *)aFileRep {
    return [[NotesViewController alloc] initWithFileRepresentation:aFileRep];
}

@end
