//
// Created by mbergmann on 18.12.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SwordUtil : NSObject

/**
 Rendered Module texts may have hyperlinks. Those links may have key/value pairs to target data.
 This method will return a dictionary with attribute/value pairs from parameters of the link.
 See ATTRTYPE_* for key types.
 */
+ (NSDictionary *)dictionaryFromUrl:(NSURL *)aURL;

@end
