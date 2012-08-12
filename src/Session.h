//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Session : NSObject

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSArray *windows;

+ (Session *)sessionFromURL:(NSURL *)anUrl;

- (id)initWithURL:(NSURL *)anUrl;
- (id)initWithURL:(NSURL *)anUrl andWindows:(NSArray *)aWindows;
- (void)load;
- (void)store;

@end
