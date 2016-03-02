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

/**
 Pads an array of unpadded Strong's numbers to 5 digits.
 I.e. H0430 => H00430, G11 => G00011
 */
+ (NSArray *)padStrongsNumbers:(NSArray *)unpaddedNumbers;

/**
 Pads a single unpadded Strong's numbers to 5 digits.
 I.e. H0430 => H00430, G11 => G00011
 Since an unpadded number can be combined with multiple numbers concatenated by space we'll return an array here.
 */
+ (NSArray *)padStrongsNumber:(NSString *)unpaddedNumber;

/**
 * Pads a string on the left until 5 digits is reached
 */
+ (NSString *)leftPadStrongsFormat:(NSString *)unpadded;


@end
