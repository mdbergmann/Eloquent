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
- (sword::SWFilter *)swFilter;
#endif

@end

@interface SwordOsisHtmlRefFilter : SwordFilter
+ (SwordOsisHtmlRefFilter *)newFilter;
@end

@interface SwordOsisPlainFilter : SwordFilter
+ (SwordOsisPlainFilter *)newFilter;
@end

@interface SwordOsisXHtmlFilter : SwordFilter
+ (SwordOsisXHtmlFilter *)newFilter;
@end

@interface SwordThmlHtmlFilter : SwordFilter
+ (SwordThmlHtmlFilter *)newFilter;
@end

@interface SwordThmlPlainFilter : SwordFilter
+ (SwordThmlPlainFilter *)newFilter;
@end

@interface SwordGbfHtmlFilter : SwordFilter
+ (SwordGbfHtmlFilter *)newFilter;
@end

@interface SwordGbfPlainFilter : SwordFilter
+ (SwordGbfPlainFilter *)newFilter;
@end

@interface SwordTeiHtmlFilter : SwordFilter
+ (SwordTeiHtmlFilter *)newFilter;
@end

@interface SwordTeiXHtmlFilter : SwordFilter
+ (SwordTeiXHtmlFilter *)newFilter;
@end

@interface SwordTeiPlainFilter : SwordFilter
+ (SwordTeiPlainFilter *)newFilter;
@end
