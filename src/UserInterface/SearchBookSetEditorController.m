//
//  SearchBookSetEditorController.m
//  Eloquent
//
//  Created by Manfred Bergmann on 18.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchBookSetEditorController.h"
#import "ObjCSword/SwordVerseManager.h"
#import "SearchBookSet.h"
#import "IndexingManager.h"
#import "ObjCSword/SwordBibleBook.h"
#import "globals.h"

// name of the nib
#define NIB_NAME     @"SearchBookSetEditor"

@interface SearchBookSetEditorController ()

- (NSArray *)books;
- (SearchBookSet *)temporaryBookSet;

@end

@implementation SearchBookSetEditorController

@synthesize selectedBookSet;
@synthesize delegate;

- (id)init {
	self = [super init];
	if(self) {
        
		BOOL success = [NSBundle loadNibNamed:NIB_NAME owner:self];
		if(success) {
            
            // by default we use temporary bookset
            self.selectedBookSet = [self temporaryBookSet];
            
		} else {
			CocoLog(LEVEL_ERR,@"[SearchBookSetEditorController -init]: cannot load Nib!");
		}
	}
	
	return self;    
}

- (void)awakeFromNib {
    // disable add and remove buttons
    [addButton setEnabled:NO];
    [removeButton setEnabled:NO];
        
    [searchBookSetsPopUpButton setMenu:[self bookSetsMenu]];
    // select none
    [searchBookSetsPopUpButton selectItemWithTag:0];
}

- (void)finalize {
	[super finalize];
}

#pragma mark - Methods

- (SearchBookSet *)temporaryBookSet {
    SearchBookSet *ret = [SearchBookSet searchBookSetWithName:@""];
    for(SwordBibleBook *bb in [self books]) {
        [ret addBook:[bb osisName]];
    }
    
    return ret;
}

- (NSArray *)books {
    // returning the default KJV based books
    NSArray *ret = [[SwordVerseManager defaultManager] books];
    
    return ret;
}

- (NSMenu *)bookSetsMenu {
    // build popup menu
    NSMenu *menu = [[[NSMenu alloc] init] autorelease];
    NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Temporary", @"") action:@selector(bookSetChanged:) keyEquivalent:@""] autorelease];
    [item setTarget:self];
    [item setTag:0];
    [menu addItem:item];
    int i = 1;
    for(SearchBookSet *set in [[IndexingManager sharedManager] searchBookSets]) {
        item = [[[NSMenuItem alloc] init] autorelease];
        [item setTitle:NSLocalizedString([set name], @"")];
        [item setTarget:self];
        [item setAction:@selector(bookSetChanged:)];
        [item setTag:i];
        [menu addItem:item];
        
        i++;
    }
    
    return menu;
}

#pragma mark - NSTableView delegates

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	// display call with std font
	NSFont *font = FontStd;
	[aCell setFont:font];
	CGFloat pointSize = [font pointSize];
	[aTableView setRowHeight:pointSize+4];    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    NSInteger ret = [[self books] count];
    
    return ret;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    id ret = nil;
    
    SwordBibleBook *bb = [[self books] objectAtIndex:(NSUInteger) rowIndex];
    if([[aTableColumn identifier] isEqualToString:@"enabled"]) {
        if([[selectedBookSet name] isEqualToString:@"All"]) {
            ret = [NSNumber numberWithBool:YES];
        } else {
            ret = [NSNumber numberWithBool:[selectedBookSet containsBook:[bb osisName]]];        
        }
    } else if([[aTableColumn identifier] isEqualToString:@"bookname"]) {
        ret = [bb localizedName];
    }
    
    return ret;
}

#pragma mark - NSControl delegate methods

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if([aNotification object] == nameTextField) {
        if([[nameTextField stringValue] length] == 0) {
            [addButton setEnabled:NO];
        } else {
            BOOL enable = YES;
            // this is not a temp one
            for(SearchBookSet *set in [[IndexingManager sharedManager] searchBookSets]) {
                if([[set name] isEqualToString:[nameTextField stringValue]]) {
                    // we may not add the same again, it is changed instead
                    enable = NO;
                }
            }
            
            [addButton setEnabled:enable];
        }        
    }
}

#pragma mark - Actions

- (IBAction)bookEnabled:(id)sender {
    
    if(![selectedBookSet isPredefined]) {
        // get clicked row
        NSUInteger clickedRow = (NSUInteger) [booksTableView clickedRow];
        NSString *bookName = [[[self books] objectAtIndex:clickedRow] osisName];
        
        if([selectedBookSet containsBook:bookName]) {
            // remove from current bookSet
            [selectedBookSet removeBook:bookName];            
        } else {
            // add to current bookSet
            [selectedBookSet addBook:bookName];    
        }
        
        // we store on application exit
        //[[IndexingManager sharedManager] storeSearchBookSets];        
    }
}

- (IBAction)bookSetChanged:(id)sender {
    int tag = [(NSMenuItem *)sender tag];
    NSMenu *menu = [(NSMenuItem *)sender menu];

    SearchBookSet *bookSet = nil;
    if(tag == 0) {
        bookSet = [self temporaryBookSet];
        [removeButton setEnabled:NO];
    } else {
        bookSet = [[[IndexingManager sharedManager] searchBookSets] objectAtIndex:tag-1];    
        if([bookSet isPredefined]) {
            [removeButton setEnabled:NO];
        } else {
            [removeButton setEnabled:YES];        
        }
    }
    [self setSelectedBookSet:bookSet];
    
    // select only the selected one
    for(NSMenuItem *item in [menu itemArray]) {
        [item setState:NSOffState];
    }
    [(NSMenuItem *)sender setState:NSOnState];
    
    // we may not add this same again
    [addButton setEnabled:NO];
    
    [nameTextField setStringValue:[selectedBookSet name]];
    [booksTableView reloadData];
    
    // notify delegate about this change
    if(delegate) {
        [delegate performSelector:@selector(indexBookSetChanged:) withObject:self]; 
    }
    
    if([bookSet isPredefined]) {
        [allButton setEnabled:NO];
        [noneButton setEnabled:NO];
        [invertButton setEnabled:NO];
    } else {
        [allButton setEnabled:YES];
        [noneButton setEnabled:YES];
        [invertButton setEnabled:YES];
    }
}

- (IBAction)addBookSet:(id)sender {
    SearchBookSet *set = [SearchBookSet searchBookSetWithName:[nameTextField stringValue]];
    [[[IndexingManager sharedManager] searchBookSets] addObject:set];
    // we store on application exit
    //[[IndexingManager sharedManager] storeSearchBookSets];        
    
    [searchBookSetsPopUpButton setMenu:[self bookSetsMenu]];
    [searchBookSetsPopUpButton selectItemWithTitle:[set name]];
    
    [booksTableView reloadData];
    [addButton setEnabled:NO];
}

- (IBAction)removeBookSet:(id)sender {
    [[[IndexingManager sharedManager] searchBookSets] removeObject:selectedBookSet];
    // we store on application exit
    //[[IndexingManager sharedManager] storeSearchBookSets];        
    
    [searchBookSetsPopUpButton setMenu:[self bookSetsMenu]];
    [searchBookSetsPopUpButton selectItemWithTag:0];

    [self setSelectedBookSet:[self temporaryBookSet]];
    [booksTableView reloadData];
    [removeButton setEnabled:NO];
}

- (IBAction)selectAll:(id)sender {
    for(SwordBibleBook *bb in [self books]) {
        [selectedBookSet addBook:[bb osisName]];
    }
    // we store on application exit
    //[[IndexingManager sharedManager] storeSearchBookSets];        
    
    [booksTableView reloadData];
}

- (IBAction)selectNone:(id)sender {
    [selectedBookSet removeAll];
    // we store on application exit
    //[[IndexingManager sharedManager] storeSearchBookSets];        
    
    [booksTableView reloadData];    
}

- (IBAction)selectInverse:(id)sender {
    for(SwordBibleBook *bb in [self books]) {
        if([selectedBookSet containsBook:[bb osisName]]) {
            [selectedBookSet removeBook:[bb osisName]];
        } else {
            [selectedBookSet addBook:[bb osisName]];        
        }
    }
    // we store on application exit
    //[[IndexingManager sharedManager] storeSearchBookSets];        
    
    [booksTableView reloadData];    
}

@end
