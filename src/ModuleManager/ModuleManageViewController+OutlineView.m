//
//  ModuleManageViewController+OutlineView.m
//  Eloquent
//
//  Created by Manfred Bergmann on 27.05.16.
//  Copyright © 2016 Crosswire. All rights reserved.
//

#import "ModuleManageViewController+OutlineView.h"
#import "InstallSourceListObject.h"
#import "ModuleListViewController.h"

@implementation ModuleManageViewController (OutlineView)

/**
 \brief Notification is called when the selection has changed
 */
- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if(notification != nil) {
        NSOutlineView *oview = [notification object];
        if(oview != nil) {
            
            NSIndexSet *selectedRows = [oview selectedRowIndexes];
            NSUInteger len = [selectedRows count];
            NSMutableArray *selection = [NSMutableArray arrayWithCapacity:len];
            InstallSourceListObject *item;
            if(len > 0) {
                NSUInteger indexes[len];
                [selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
                
                for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    [selection addObject:item];
                    CocoLog(LEVEL_DEBUG, @"Selected install source: %@", [[item installSource] caption]);
                }
                
                // set install source menu
                [oview setMenu:installSourceMenu];
            }
            
            // update modules
            NSArray *selected = [NSArray arrayWithArray:selection];
            [self setSelectedInstallSources:selected];
            [modListViewController setInstallSources:selected];
            [modListViewController refreshModulesList];
        } else {
            CocoLog(LEVEL_WARN, @"have a nil notification object!");
        }
    } else {
        CocoLog(LEVEL_WARN, @"have a nil notification!");
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    if(item == nil) {   // root
        return [self.installSourceListObjects count];
        
    } else if([listObject objectType] == TypeInstallSource) {
        return [[listObject subInstallSources] count];
        
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    if(item == nil) {   // root
        return self.installSourceListObjects[(NSUInteger)index];
        
    } else if([listObject objectType] == TypeInstallSource) {
        return [listObject subInstallSources][(NSUInteger)index];
        
    }
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    if(item != nil) {
        if([listObject objectType] == TypeInstallSource) {
            return [[listObject installSource] caption];
            
        } else {
            return [listObject moduleType];
            
        }
    }
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    InstallSourceListObject *listObject = (InstallSourceListObject *)item;
    return item != nil && ([listObject objectType] == TypeInstallSource);
    
}

/*
 - (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
 NSFont *font = FontLarge;
 [cell setFont:font];
 // set row height according to used font
 CGFloat pointSize = [font pointSize];
 [aOutlineView setRowHeight:pointSize+10];
 }
 */

@end
