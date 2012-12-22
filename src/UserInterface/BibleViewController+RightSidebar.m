//
//  BibleViewController+RightSidebar.m
//  Eloquent
//
//  Created by Manfred Bergmann on 19.02.10.
//  Copyright 2010 Software by MABE. All rights reserved.
//

#import "HostableViewController.h"
#import "ContentDisplayingViewController.h"
#import "ModuleCommonsViewController.h"
#import "BibleViewController+RightSidebar.h"
#import "WorkspaceViewHostController.h"
#import "globals.h"
#import "ObjCSword/SwordBible.h"
#import "ObjCSword/SwordBibleBook.h"
#import "ObjCSword/SwordBibleChapter.h"
#import "MBPreferenceController.h"
#import "BibleCombiViewController.h"
#import "SearchBookSetEditorController.h"


@implementation BibleViewController (RightSidebar)

#pragma mark - AccessoryViewProviding

- (NSView *)rightAccessoryView {
    if(searchType == ReferenceSearchType) {
        return sideBarView;
    } else {
        return [searchBookSetsController view];
    }
}

- (BOOL)showsRightSideBar {
    return [super showsRightSideBar];
    /*
    if([hostingDelegate isKindOfClass:[WorkspaceViewHostController class]]) {
        return [userDefaults boolForKey:DefaultsShowRSBWorkspace];
    } else {
        return [userDefaults boolForKey:DefaultsShowRSBSingle];        
    }
     */
}

#pragma mark - SearchBookSetEditorController delegate methods

- (void)indexBookSetChanged:(id)sender {
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [delegate performSelector:@selector(indexBookSetChanged:) withObject:self];
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	CocoLog(LEVEL_DEBUG,@"");
	
	if(notification != nil) {
		NSOutlineView *oview = [notification object];
		if(oview != nil) {
            
			NSIndexSet *selectedRows = [oview selectedRowIndexes];
			int len = [selectedRows count];
			NSMutableArray *sel = [NSMutableArray arrayWithCapacity:len];
            id item = nil;
			if(len > 0) {
				NSUInteger indexes[len];
				[selectedRows getIndexes:indexes maxCount:len inIndexRange:nil];
				
				for(int i = 0;i < len;i++) {
                    item = [oview itemAtRow:indexes[i]];
                    
                    // add to array
                    [sel addObject:item];
				}
            }
            
            self.bookSelection = sel;
            
            // loop over selection and build reference to display
            BOOL haveBook = NO;
            NSMutableString *selRef = [NSMutableString string];
            for(item in sel) {
                if([item isKindOfClass:[SwordBibleBook class]]) {
                    haveBook = YES;
                    [selRef appendFormat:@"%@ ;", [(SwordBibleBook *)item localizedName]];
                } else if([item isKindOfClass:[SwordBibleChapter class]]) {
                    if(haveBook) {
                        [selRef appendFormat:@"%i; ", [(SwordBibleChapter *)item number]];
                    } else {
                        [selRef appendFormat:@"%@ %i; ", [[(SwordBibleChapter *)item book] localizedName], [(SwordBibleChapter *)item number]];
                    }
                }
            } 
            
            // send the reference to delegate
            if(hostingDelegate) {
                [hostingDelegate setSearchTypeUI:ReferenceSearchType];
                [hostingDelegate setSearchText:selRef];
            }
		} else {
			CocoLog(LEVEL_WARN,@"have a nil notification object!");
		}
	} else {
		CocoLog(LEVEL_WARN,@"have a nil notification!");
	}
}

- (void)outlineView:(NSOutlineView *)aOutlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {    
	// display call with std font
	NSFont *font = FontStd;    
	[cell setFont:font];
	//float imageHeight = [[(CombinedImageTextCell *)cell image] size].height; 
	CGFloat pointSize = [font pointSize];
	[aOutlineView setRowHeight:pointSize+4];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    int ret = 0;
    
    if(item == nil) {
        ret = [[(SwordBible *)module books] count];
    } else {
        if([item isKindOfClass:[SwordBibleBook class]]) {
            SwordBibleBook *bb = item;
            ret = [bb numberOfChapters];
        }
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    id ret = nil;
    
    if(item == nil) {
        ret = [[(SwordBible *)module bookList] objectAtIndex:index];
    } else if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = [[(SwordBibleBook *)item chapters] objectAtIndex:index];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ret = @"";
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = [(SwordBibleBook *)item localizedName];
    } else if([item isKindOfClass:[SwordBibleChapter class]]) {
        ret = [[NSNumber numberWithInt:[(SwordBibleChapter*)item number]] stringValue];
    }
    
    return ret;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        SwordBibleBook *bb = item;
        if([bb numberOfChapters] > 0) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

@end
