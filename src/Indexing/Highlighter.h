//
//  Highlighter.h
//  MacSword2
//
//  Created by Manfred Bergmann on 20.06.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Highlighter : NSObject {

}

+ (NSString *)stripSearchQuery:(NSString *)searchQuery;
+ (NSAttributedString *)highlightText:(NSString *)text forTokens:(NSString *)tokenStr attributes:(NSDictionary *)attributes;
+ (NSString *)htmlHighlightText:(NSString *)text forTokens:(NSString *)tokenStr;

@end
