//
//  Highlighter.m
//  Eloquent
//
//  Created by Manfred Bergmann on 20.06.07.
//  Copyright 2007 mabe. All rights reserved.
//

#import "Highlighter.h"
#import "globals.h"
#import "MBPreferenceController.h"


@implementation Highlighter

+ (NSString *)stripSearchQuery:(NSString *)searchQuery {
    // remove any characters from the tokens like: "+, -, *, !, &, |, AND, OR, (, ), ""
    NSMutableString *query = [[searchQuery mutableCopy] autorelease];
    for(int i = 0;i < 11;i++) {
        NSString *token = @"+";
        switch(i) {
            case 0:
                token = @"+";
                break;
            case 1:
                token = @"-";
                break;
            case 2:
                token = @"*";
                break;
            case 3:
                token = @"!";
                break;
            case 4:
                token = @"&";
                break;
            case 5:
                token = @"|";
                break;
            case 6:
                token = @"AND";
                break;
            case 7:
                token = @"OR";
                break;
            case 8:
                token = @"(";
                break;
            case 9:
                token = @")";
                break;
            case 10:
                token = @"\"";
                break;
        }
        
        NSRange tFound;
        do {
            tFound = [query rangeOfString:token];
            if(tFound.location != NSNotFound) {
                [query replaceCharactersInRange:tFound withString:@""];
            }
        }
        while(tFound.location != NSNotFound);
    }
    
    return query;
}

+ (NSAttributedString *)highlightText:(NSString *)text forTokens:(NSString *)tokenStr attributes:(NSDictionary *)attributes {
    NSMutableAttributedString *ret = nil;
    
    //NSColor *blue = [NSColor redColor];
    NSColor *blue = [NSColor colorWithDeviceRed:0.7 green:0.0 blue:0.0 alpha:1.0];
    NSRange found, area;
    unsigned int length = [text length];
    
    if(length > 0) {
        
        int size = (int)[(NSFont *)[attributes objectForKey:NSFontAttributeName] pointSize];

        // create attributes Dictionary for highlight
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:blue forKey:NSForegroundColorAttributeName];
        NSFont *fontBold = [NSFont fontWithName:[userDefaults stringForKey:DefaultsBibleTextDisplayBoldFontFamilyKey] size:size];
        [attr setObject:fontBold forKey:NSFontAttributeName];
        
        // create NSMutableAttributedString
        ret = [[[NSMutableAttributedString alloc] initWithString:text attributes:attributes] autorelease];

        // loop over all tokens
        NSArray *tokens = [tokenStr componentsSeparatedByString:@" "];
        int tLen = [tokens count];
        for(NSUInteger i = 0;i < tLen;i++) {
            NSString *token = [tokens objectAtIndex:i];
            
            if(([token length] > 0) && ([token isEqualToString:@" "] == NO)) {
                // now attribute the string
                area.location = 0;
                area.length = length;
                
                // add new colors
                while(area.length > 0) {
                    found = [text rangeOfString:token 
                                        options:NSCaseInsensitiveSearch 
                                          range:area];
                    if (found.location == NSNotFound) break;
                    
                    // set attribute
                    [ret setAttributes:attr range:found];
                    
                    area.location = NSMaxRange(found);
                    area.length = length - area.location;
                }
            }
        }
    }
    
    return ret;
}

+ (NSAttributedString *)highlightText:(NSMutableAttributedString *)text forTokens:(NSString *)tokenStr attributes:(NSDictionary *)attributes font:(NSFont *)font boldFont:(NSFont *)boldFont {
    NSMutableAttributedString *ret = text;
    
    NSColor *blue = [NSColor redColor];
    NSRange found, area;
    unsigned int length = [text length];
    if(length > 0) {
        // create attributes Dictionary
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithObject:blue forKey:NSForegroundColorAttributeName];
        [attr setObject:boldFont forKey:NSFontAttributeName];
        
        // get stripped text
        NSString *strText = [text string];
        
        // loop over all tokens
        NSArray *tokens = [tokenStr componentsSeparatedByString:@" "];
        int tLen = [tokens count];
        for(NSUInteger i = 0;i < tLen;i++) {
            NSString *token = [tokens objectAtIndex:i];
            
            if(([token length] > 0) && ([token isEqualToString:@" "] == NO)) {
                // now attribute the string
                area.location = 0;
                area.length = length;
                
                // add new colors
                while(area.length > 0) {
                    found = [strText rangeOfString:token 
                                           options:NSCaseInsensitiveSearch 
                                             range:area];
                    if (found.location == NSNotFound) break;
                    
                    // set attribute
                    [ret setAttributes:attr range:found];
                    
                    area.location = NSMaxRange(found);
                    area.length = length - area.location;
                }
            }
        }
    }
    
    return ret;    
}

+ (NSString *)htmlHighlightText:(NSString *)text forTokens:(NSString *)tokenStr {
    NSMutableString *ret = nil;
    
    NSString *blueHighlightTempl = @"<span style=\"color:#ff0000;font-weight: bold;\">%@</span>";
    NSRange found, area;
    unsigned int length = [text length];
    
    if(length > 0) {
        ret = [[text mutableCopy] autorelease];
        
        // loop over all tokens
        NSArray *tokens = [tokenStr componentsSeparatedByString:@" "];
        int tLen = [tokens count];
        for(NSUInteger i = 0;i < tLen;i++) {
            NSString *token = [tokens objectAtIndex:i];
            
            if(([token length] > 0) && ([token isEqualToString:@" "] == NO)) {
                // now attribute the string
                area.location = 0;
                area.length = length;
                
                // add new colors
                while(area.length > 0) {
                    found = [text rangeOfString:token 
                                        options:NSCaseInsensitiveSearch 
                                          range:area];
                    if (found.location == NSNotFound) break;
                    
                    // set color
                    [ret replaceCharactersInRange:found withString:[NSString stringWithFormat:blueHighlightTempl, [text substringWithRange:found]]];
                    
                    area.location = NSMaxRange(found);
                    area.length = length - area.location;
                }
            }
        }
    }
    
    return ret;    
}

@end
