//
//  SwordModuleTest.m
//  MacSword2
//
//  Created by Manfred Bergmann on 14.12.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SwordModuleTest.h"
#import "SwordManager.h"
#import "SwordModule.h"
#import "SwordBible.h"
#import "SwordListKey.h"
#import "SwordVerseKey.h"

#ifdef __cplusplus
#include <swtext.h>
#include <versekey.h>
#include <regex.h>
#include <swmodule.h>
class sword::SWModule;
#include <iostream>
#include <versekey.h>
#include <rawtext.h>
#include <rawcom.h>
#include <echomod.h>
#include <stdlib.h>
using namespace sword;
#endif

@implementation SwordModuleTest

- (void)setUp {
    mod = [[SwordManager defaultManager] moduleWithName:@"GerNeUe"];    
}

- (void)testRenderedTextEntriesForRef {
    NSArray *entries = [(SwordBible *)mod renderedTextEntriesForRef:@"gen"];
    int i = 0;
    for(SwordBibleTextEntry *entry in entries) {
        i++;
    }
}

- (void)testRenderedWithEnumerator {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen"];
    NSString *ref = nil;
    NSString *rendered = nil;
    VerseEnumerator *iter = [lk verseEnumerator];
    while((ref = [iter nextObject])) {
        [(SwordBible *)mod setPositionFromKeyString:ref];
        rendered = [mod renderedText];
    }
}

- (void)testLoopWithModulePos {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen" v11n:[mod versification]];
    [lk setPersist:YES];
    [mod setPositionFromKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithHeadings {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen" headings:YES v11n:[mod versification]];
    [lk setPersist:YES];
    [mod setPositionFromKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithDiverseReference {
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:1;4:5-8" v11n:[mod versification]];
    [lk setPersist:YES];
    [mod setPositionFromKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        ref = [lk keyText];
        rendered = [mod renderedText];
        NSLog(@"%@:%@", ref, rendered);
        [mod incKeyPosition];
    }
}

- (void)testLoopWithModulePosWithDiverseReferenceAndContext {
    int context = 1;
    SwordVerseKey *vk = [SwordVerseKey verseKeyWithVersification:[mod versification]];
    [vk setPersist:YES];
    SwordListKey *lk = [SwordListKey listKeyWithRef:@"gen 1:1;4:5;8:4;10:2-5" v11n:[mod versification]];
    [lk setPersist:YES];
    [mod setPositionFromKey:lk];
    NSString *ref = nil;
    NSString *rendered = nil;
    while(![mod error]) {
        if(context > 0) {
            [vk setKeyText:[lk keyText]];
            long lowVerse = [vk verse] - context;
            long highVerse = lowVerse + (context * 2);
            [vk setVerse:lowVerse];
            [mod setPositionFromKey:vk];
            for(;lowVerse <= highVerse;lowVerse++) {
                ref = [vk keyText];
                rendered = [mod renderedText];                
                NSLog(@"%@:%@", ref, rendered);
                [mod incKeyPosition];
            }
            // set back list key
            [mod setPositionFromKey:lk];
            [mod incKeyPosition];
        } else {
            ref = [lk keyText];
            rendered = [mod renderedText];
            NSLog(@"%@:%@", ref, rendered);
            [mod incKeyPosition];            
        }
    }
}
 
- (void)testStrippedTextForRef {
    sword::VerseKey vk = sword::VerseKey("1Mo 1:2");
    NSLog(@"start position: %s", vk.getText());
    vk.decrement();
    NSLog(@"decrement position: %s", vk.getText());    
    vk.setVerse(vk.getVerse() + 3);
    NSLog(@"verse + 3: %s", vk.getText());
}

- (void)testHeadings {
    mod = [[SwordManager defaultManager] moduleWithName:@"ESV"];
    STAssertNotNil(mod, @"No Mod");
    
    // enable headings
    [[SwordManager defaultManager] setGlobalOption:SW_OPTION_HEADINGS value:SW_ON];
    [[SwordManager defaultManager] setGlobalOption:SW_OPTION_STRONGS value:SW_ON];
    [[SwordManager defaultManager] setGlobalOption:SW_OPTION_FOOTNOTES value:SW_ON];

	SWModule *target;    
	target = [mod swModule];    
	target->setKey("gen 1:1");    
	target->RenderText();		// force an entry lookup to resolve key to something in the index
    
	std::cout << "==Raw=Entry===============\n";
	std::cout << target->getKeyText() << ":\n";
	std::cout << target->getRawEntry();
	std::cout << "\n";
	std::cout << "==Render=Entry============\n";
	std::cout << target->RenderText();
	std::cout << "\n";
	std::cout << "==========================\n";
	std::cout << "Entry Attributes:\n\n";
	AttributeTypeList::iterator i1;
	AttributeList::iterator i2;
	AttributeValue::iterator i3;
	for (i1 = target->getEntryAttributes().begin(); i1 != target->getEntryAttributes().end(); i1++) {
		std::cout << "[ " << i1->first << " ]\n";
		for (i2 = i1->second.begin(); i2 != i1->second.end(); i2++) {
			std::cout << "\t[ " << i2->first << " ]\n";
			for (i3 = i2->second.begin(); i3 != i2->second.end(); i3++) {
				std::cout << "\t\t" << i3->first << " = " << i3->second << "\n";
			}
		}
	}
	std::cout << std::endl;
}

@end
