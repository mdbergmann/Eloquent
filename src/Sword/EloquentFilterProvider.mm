//
// Created by mbergmann on 18.12.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "EloquentFilterProvider.h"

@implementation EloquentFilterProvider

- (SwordFilter *)newOsisRenderFilter {
    return [SwordOsisXHtmlFilter filter];
}

@end
