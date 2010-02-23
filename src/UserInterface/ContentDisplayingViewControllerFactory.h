//
//  ContentDisplayingViewControllerFactory.h
//  MacSword2
//
//  Created by Manfred Bergmann on 22.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SwordModule.h>

@class FileRepresentation;
@class ContentDisplayingViewController;

@interface ContentDisplayingViewControllerFactory : NSObject {

}

+ (ContentDisplayingViewController *)createSwordModuleViewControllerForModule:(SwordModule *)aModule;
+ (ContentDisplayingViewController *)createSwordModuleViewControllerForModuleType:(ModuleType)aModuleType;
+ (ContentDisplayingViewController *)createNotesViewControllerForFileRep:(FileRepresentation *)aFileRep;

@end
