//
//  Highlighter.h
//  Eloquent
//
//  Created by Manfred Bergmann on 20.06.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Highlighter : NSObject {

}

+ (NSString *)stripSearchQuery:(NSString *)searchQuery;
+ (NSAttributedString *)highlightText:(NSString *)text forTokens:(NSString *)tokenStr attributes:(NSDictionary *)attributes;
+ (NSAttributedString *)highlightText:(NSMutableAttributedString *)text forTokens:(NSString *)tokenStr attributes:(NSDictionary *)attributes font:(NSFont *)font boldFont:(NSFont *)boldFont;
+ (NSString *)htmlHighlightText:(NSString *)text forTokens:(NSString *)tokenStr;

@end
