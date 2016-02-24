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
#import "ObjCSword/SwordBible.h"
#import "ObjCSword/SwordBibleBook.h"
#import "ObjCSword/SwordBibleChapter.h"
#import "BibleCombiViewController.h"
#import "SearchBookSetEditorController.h"
#import "globals.h"


@interface ChapterDisplayItem : NSObject

@property (strong, nonatomic) SwordBibleBook *book;
@property (nonatomic) NSRange chapterRange;

+ (ChapterDisplayItem *)itemWithRange:(NSRange)chapterRange;

@end

@implementation ChapterDisplayItem

+ (ChapterDisplayItem *)itemWithRange:(NSRange)chapterRange {
    return [[ChapterDisplayItem alloc] initWithRange:chapterRange];
}

- (id)initWithRange:(NSRange)chapterRange {
    self = [super init];
    if(self) {
        self.chapterRange = chapterRange;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%lu-%lu", self.chapterRange.location, (self.chapterRange.location+self.chapterRange.length-1)];
}

@end


@implementation BibleViewController (RightSidebar)

#define ChapterRangeLength 5

- (NSDictionary *)buildOutlineItemsCache {
    NSMutableDictionary *buf = [NSMutableDictionary dictionary];
    
    NSArray *books = [(SwordBible *)module bookList];
    for(SwordBibleBook *book in books) {
        int chapters = [book numberOfChapters];
        int rowItems = [self numberOfRowItemsForChapters:chapters];

        NSMutableDictionary *rowData = [NSMutableDictionary dictionary];
        for(int rowIndex = 0; rowIndex < rowItems; rowIndex++) {
            int chapterStart = rowIndex == 0 ? 1 : (rowIndex * ChapterRangeLength)+1;
            
            NSRange range;
            range.location = chapterStart;
            if(rowIndex == (rowItems - 1)) {
                int last = (chapters % ChapterRangeLength);
                range.length = last == 0 ? ChapterRangeLength : last;
                
            } else {
                range.length = ChapterRangeLength;
            }
            
            ChapterDisplayItem *chapterItem = [ChapterDisplayItem itemWithRange:range];
            [chapterItem setBook:book];
            
            rowData[@(rowIndex)] = chapterItem;
        }
        
        buf[@([book number])] = rowData;
    }
    
    return [NSDictionary dictionaryWithDictionary:buf];
}

- (int)numberOfRowItemsForChapters:(int)nChapters {
    int rows= (nChapters / ChapterRangeLength);
    if((nChapters % ChapterRangeLength) > 0) {
        rows++;
    }
    return rows;
}

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
}

#pragma mark - SearchBookSetEditorController delegate methods

- (void)indexBookSetChanged:(id)sender {
    if([delegate isKindOfClass:[BibleCombiViewController class]]) {
        [delegate performSelector:@selector(indexBookSetChanged:) withObject:self];
    }
}

#pragma mark - NSOutlineView delegate methods

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
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
                    
                } else if([item isKindOfClass:[ChapterDisplayItem class]]) {
                    if(haveBook) {
                        [selRef appendFormat:@"%@; ", [item description]];
                    } else {
                        [selRef appendFormat:@"%@ %@; ", [[(ChapterDisplayItem *)item book] localizedName], [(ChapterDisplayItem *)item description]];
                    }
                }
            } 
            
            // send the reference to delegate
            if(hostingDelegate) {
                [hostingDelegate setSearchTypeUI:ReferenceSearchType];
                [hostingDelegate setSearchText:selRef];
            }
		}
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
    if(item == nil) {
        return [self.outlineViewItems count];
        
    } else {
        if([item isKindOfClass:[SwordBibleBook class]]) {
            SwordBibleBook *bb = item;

            return [(NSDictionary *)self.outlineViewItems[@([bb number])] count];
        }
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    id ret = nil;
    
    if(item == nil) {
        ret = [(SwordBible *)self.module bookList][index];
        
    } else if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = self.outlineViewItems[@([(SwordBibleBook *)item number])][@(index)];
    }
    
    return ret;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    NSString *ret = @"";
    
    if([item isKindOfClass:[SwordBibleBook class]]) {
        ret = [(SwordBibleBook *)item localizedName];
    } else if([item isKindOfClass:[ChapterDisplayItem class]]) {
        ret = [item description];
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
