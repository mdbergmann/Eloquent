//  SearchManager.m
//  Eloquent
//
//  Scaffolded by assistant on 5/21/26.
//

#import "SearchManager.h"
#import "ObjCSword/SwordManager.h"
#import "ObjCSword/SwordDictionary.h"
#import "ObjCSword/SwordKey.h"
#import "ObjCSword/SwordModuleTextEntry.h"
#import "ObjCSword/SwordVerseKey.h"
#import "ObjCSword/SwordBible.h"
#import "BibleViewController.h"

@interface SearchManager ()
@property (nonatomic, strong, nullable) SwordModule *module;
@end

@implementation SearchManager

+ (instancetype)shared {
    static SearchManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (nullable SwordModule *)moduleForVersion:(NSString *)version {
    SwordManager *sm = [SwordManager defaultManager];
    SwordModule *mod = [sm moduleWithName:version];
    return mod;
}

- (nullable NSString *)searchFor:(NSString *)reference inVersion:(NSString * _Nullable)translation error:(NSError * _Nullable * _Nullable)error {
    // TODO: Replace with your real search implementation.
    NSString *usedVersion = (translation.length > 0) ? translation : @"KJV";
    NSMutableString *result = [NSMutableString string];
    CocoLog(LEVEL_DEBUG, @"usedVersion %@", usedVersion);
    CocoLog(LEVEL_DEBUG, @"reference %@", reference);
    
    // Resolve module from version
    self.module = [self moduleForVersion:usedVersion];
    if (!self.module) {
        if (error) {
            *error = [NSError errorWithDomain:@"SearchManager" code:1 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Module '%@' not found.", usedVersion]}];
            CocoLog(LEVEL_DEBUG, @"ERROR: %@", *error);
        }
        return nil;
    }

    // Render text entries for the provided reference
    NSArray *textEntries = [(SwordBible *)self.module renderedTextEntriesForReference:reference context:0];
    CocoLog(LEVEL_DEBUG, @"%ld Verses found", textEntries.count);

    // Concatenate the text from each entry into a single result string
    for (id entry in textEntries) {
        // Entries are expected to be SwordModuleTextEntry or compatible with a 'text' selector
        if ([entry respondsToSelector:@selector(text)]) {
            NSString *piece = [entry performSelector:@selector(text)];
            if (piece.length > 0) {
                if (result.length > 0) { [result appendString:@"\n"]; }
                [result appendString:piece];
            }
        }
    }
    //CocoLog(LEVEL_INFO, @"Returning %@", result);
    return result.length > 0 ? result : [NSString stringWithFormat:@"\n", nil];
}

- (void)openPassage:(NSString *)reference version:(NSString * _Nullable)version {
    // TODO: Bridge to your macOS UI to open the passage. For now, this is a no-op.
    (void)reference; (void)version;
}

@end

