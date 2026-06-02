//  SearchManager.h
//  Eloquent
//
//  Scaffolded by assistant on 5/21/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchManager : NSObject

+ (instancetype)shared;

// Returns a textual result for a given query and optional version. Error may be set if needed.
- (nullable NSString *)searchFor:(NSString *)query inVersion:(NSString * _Nullable)version error:(NSError * _Nullable * _Nullable)error;

// Navigates UI to a passage/version (no return value required).
- (void)openPassage:(NSString *)reference version:(NSString * _Nullable)version;

@end

NS_ASSUME_NONNULL_END
