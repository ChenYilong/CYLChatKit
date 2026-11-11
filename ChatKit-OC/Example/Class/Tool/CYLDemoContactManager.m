//
//  CYLDemoContactManager.m
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/3/10.
//  Copyright © 2016年 LeanCloud. All rights reserved.
//

#import "CYLDemoContactManager.h"
#import "CYLDemoExampleConstants.h"

#if __has_include(<ChatKit/CYLChatKit.h>)
    #import <ChatKit/CYLChatKit.h>
#else
    #import "CYLChatKit.h"
#endif

@interface CYLDemoContactManager ()

@property (strong, nonatomic) NSMutableArray *contactIDs;

@end

@implementation CYLDemoContactManager

/**
 * create a singleton instance of CYLDemoContactManager
 */
+ (instancetype)defaultManager {
    static CYLDemoContactManager *_sharedCYLDemoContactManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCYLDemoContactManager = [[self alloc] init];
    });
    return _sharedCYLDemoContactManager;
}

- (NSMutableArray *)contactIDs {
    if (!_contactIDs) {
        _contactIDs = [NSMutableArray arrayWithContentsOfFile:[self storeFilePath]];
        if (!_contactIDs) {
            _contactIDs = [NSMutableArray array];
            for (NSArray *contacts in __CYLDemoContactsOfSections) {
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
    NSString *fileName = [NSString stringWithFormat:@"CYLDemoContacts%@.plist", [CYLChatKit sharedInstance].clientId];
    NSString* path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    return path;
}

@end
