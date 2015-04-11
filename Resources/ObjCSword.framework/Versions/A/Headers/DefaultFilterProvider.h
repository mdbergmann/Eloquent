//
// Created by mbergmann on 18.12.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "SwordFilter.h"

@protocol FilterProvider

- (SwordFilter *)newOsisRenderFilter;
- (SwordFilter *)newOsisPlainFilter;
- (SwordFilter *)newGbfRenderFilter;
- (SwordFilter *)newGbfPlainFilter;
- (SwordFilter *)newThmlRenderFilter;
- (SwordFilter *)newThmlPlainFilter;
- (SwordFilter *)newTeiRenderFilter;
- (SwordFilter *)newTeiPlainFilter;

@end

@interface DefaultFilterProvider : NSObject <FilterProvider>

- (SwordFilter *)newOsisRenderFilter;
- (SwordFilter *)newOsisPlainFilter;
- (SwordFilter *)newGbfRenderFilter;
- (SwordFilter *)newGbfPlainFilter;
- (SwordFilter *)newThmlRenderFilter;
- (SwordFilter *)newThmlPlainFilter;
- (SwordFilter *)newTeiRenderFilter;
- (SwordFilter *)newTeiPlainFilter;

@end
