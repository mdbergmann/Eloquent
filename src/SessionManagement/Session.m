//
// Created by mbergmann on 28.07.12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Session.h"

@implementation Session

- (id)init {
    return [self initWithURL:nil andWindows:[NSArray array]];
}

- (id)initWithURL:(NSURL *)anUrl {
    return [self initWithURL:anUrl andWindows:[NSArray array]];
}

- (id)initWithURL:(NSURL *)anUrl andWindows:(NSArray *)aWindows {
    self = [super init];
    if (self) {
        self.url = anUrl;
        self.windows = aWindows;
    }
    return self;
}

- (void)dealloc {
    [_url release];
    [_windows release];

    [super dealloc];
}

@end
