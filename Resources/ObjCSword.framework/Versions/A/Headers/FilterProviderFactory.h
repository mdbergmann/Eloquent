//
// Created by mbergmann on 18.12.12.
//
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
#include <swmgr.h>		// C++ Sword API
#endif

@protocol FilterProvider;

/**
* This factory has to be initialized before any Modules are loaded through SwordManager.
*/
@interface FilterProviderFactory : NSObject

+ (instancetype)factory NS_SWIFT_NAME(factory());

- (void)initWithImpl:(id<FilterProvider>)aFilterProvider;
- (id<FilterProvider>)get;

@end
