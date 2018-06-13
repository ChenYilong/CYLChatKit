//
//  LCCKContactManager.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 16/3/10.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKContactManager.h"
#import "LCCKExampleConstants.h"

#if __has_include(<CYLChatKit/LCChatKit.h>)
    #import <CYLChatKit/LCChatKit.h>
#else
    #import "LCChatKit.h"
#endif

@interface LCCKContactManager ()

@property (strong, nonatomic) NSMutableArray *contactIDs;

@end

@implementation LCCKContactManager

/**
 * create a singleton instance of LCCKContactManager
 */
+ (instancetype)defaultManager {
    static LCCKContactManager *_sharedLCCKContactManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLCCKContactManager = [[self alloc] init];
    });
    return _sharedLCCKContactManager;
}

- (NSMutableArray *)contactIDs {
    if (!_contactIDs) {
        _contactIDs = [NSMutableArray arrayWithContentsOfFile:[self storeFilePath]];
        if (!_contactIDs) {
            _contactIDs = [NSMutableArray array];
            for (NSArray *contacts in __LCCKContactsOfSections) {
                [_contactIDs addObjectsFromArray:contacts];
            }
            [_contactIDs writeToFile:[self storeFilePath] atomically:YES];
        }
    }
    return _contactIDs;
}

- (NSArray *)fetchContactPeerIds {
    return self.contactIDs;
}

- (BOOL)existContactForPeerId:(NSString *)peerId {
    return [self.contactIDs containsObject:peerId];
}

- (BOOL)addContactForPeerId:(NSString *)peerId {
    if (!peerId) {
        return NO;
    }
    [self.contactIDs addObject:peerId];
    return [self saveContactIDs];
}

- (BOOL)removeContactForPeerId:(NSString *)peerId {
    if (!peerId) {
        return NO;
    }
    if (![self existContactForPeerId:peerId]) {
        return NO;
    }
    
    [self.contactIDs removeObject:peerId];
    
    return [self saveContactIDs];
}

- (BOOL)saveContactIDs {
    if (_contactIDs) {
        return [_contactIDs writeToFile:[self storeFilePath] atomically:YES];
    }
    return YES;
}

- (NSString *)storeFilePath {
    NSString *fileName = [NSString stringWithFormat:@"LCCKContacts%@.plist", [LCChatKit sharedInstance].clientId];
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return path;
}

@end
