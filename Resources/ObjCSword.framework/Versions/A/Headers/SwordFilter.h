//
// Created by mbergmann on 18.12.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <swfilter.h>
#endif

@interface SwordFilter : NSObject

#ifdef __cplusplus
- (id)initWithSWFilter:(sword::SWFilter *)swFilter;
- (sword::SWFilter *)swFilter;
#endif

@end

@interface SwordOsisHtmlRefFilter : SwordFilter
+ (SwordOsisHtmlRefFilter *)filter;
@end

@interface SwordOsisPlainFilter : SwordFilter
+ (SwordOsisPlainFilter *)filter;
@end

@interface SwordOsisXHtmlFilter : SwordFilter
+ (SwordOsisXHtmlFilter *)filter;
@end

@interface SwordThmlHtmlFilter : SwordFilter
+ (SwordThmlHtmlFilter *)filter;
@end

@interface SwordThmlPlainFilter : SwordFilter
+ (SwordThmlPlainFilter *)filter;
@end

@interface SwordGbfHtmlFilter : SwordFilter
+ (SwordGbfHtmlFilter *)filter;
@end

@interface SwordGbfPlainFilter : SwordFilter
+ (SwordGbfPlainFilter *)filter;
@end

@interface SwordTeiHtmlFilter : SwordFilter
+ (SwordTeiHtmlFilter *)filter;
@end

@interface SwordTeiXHtmlFilter : SwordFilter
+ (SwordTeiXHtmlFilter *)filter;
@end

@interface SwordTeiPlainFilter : SwordFilter
+ (SwordTeiPlainFilter *)filter;
@end
