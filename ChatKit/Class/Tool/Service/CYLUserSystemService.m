//
//  CYLUserSystemService.m
//  ChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLUserSystemService.h"
#import "CYLSessionService.h"

NSString *const CYLUserSystemServiceErrorDomain = @"CYLUserSystemServiceErrorDomain";

@interface CYLUserSystemService ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<CYLUserDelegate>> *cachedUsers;

@property (nonatomic, strong) dispatch_queue_t isolationQueue;

@end

@implementation CYLUserSystemService
@synthesize fetchProfilesBlock = _fetchProfilesBlock;

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *queueBaseLabel = [NSString stringWithFormat:@"com.ChatKit.%@", NSStringFromClass([self class])];
        const char *queueName = [[NSString stringWithFormat:@"%@.ForIsolation",queueBaseLabel] UTF8String];
        self->_isolationQueue = dispatch_queue_create(queueName, NULL);
    }
    return self;
}

- (void)setFetchProfilesBlock:(CYLFetchProfilesBlock)fetchProfilesBlock {
    _fetchProfilesBlock = fetchProfilesBlock;
}

- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)theError {
    // This network-only path bypasses cached profiles and refreshes the cache with the fetched user data.
    // Use it when the latest server-side avatar/profile is needed.
    // https://github.com/leancloud/ChatKit-OC/issues/299
    if (![CYLSessionService sharedInstance].connect) {
        NSInteger code = 0;
        NSInteger subCode = code;
        NSString *errorReasonText = @"session closed";
        NSDictionary *errorInfo = @{
                                    @"subCode" : @(subCode),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        if(error != NULL){
            *theError = error;
        }
        return nil;
    }
    __block NSArray<id<CYLUserDelegate>> *blockUsers = [NSArray array];
    if (!_fetchProfilesBlock) {
        CYLLog("You must implement `-setFetchProfilesBlock:` to allow ChatKit to get user information by user clientId.");
        return nil;
    }
    CYLFetchProfilesCompletionHandler completionHandler = ^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
        blockUsers = users;
        [self cacheUsers:users];
    };
    _fetchProfilesBlock(userIds, completionHandler);
    return blockUsers;
}

- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback {
    if (![CYLSessionService sharedInstance].connect) {
        NSInteger code = 0;
        NSInteger subCode = code;
        NSString *errorReasonText = @"session closed";
        NSDictionary *errorInfo = @{
                                    @"subCode" : @(subCode),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                             code:code
                                         userInfo:errorInfo];
        !callback ?: callback(nil, error);
        return;
    }
    if (!userIds || userIds.count == 0) {
        dispatch_async(dispatch_get_main_queue(),^{
            NSInteger code = 0;
            NSString *errorReasonText = @"members is 0";
            NSDictionary *errorInfo = @{
                                        @"code":@(code),
                                        NSLocalizedDescriptionKey : errorReasonText,
                                        };
            NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                                 code:code
                                             userInfo:errorInfo];
            !callback ?: callback(nil, error);
        });
        return;
    }
    NSError *error = nil;
    NSArray *cachedProfiles = [self getCachedProfilesIfExists:userIds error:&error];
    if (cachedProfiles.count == userIds.count) {
        dispatch_async(dispatch_get_main_queue(),^{
            !callback ?: callback(cachedProfiles, nil);
        });
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        if (!_fetchProfilesBlock) {
            CYLLog("You must implement `-setFetchProfilesBlock:` to allow ChatKit to get user information by user clientId.");
            return;
        }
        _fetchProfilesBlock(userIds, ^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
            if (!error && users && (users.count > 0)) {
                [self cacheUsers:users];
                dispatch_async(dispatch_get_main_queue(),^{
                    !callback ?: callback(users, nil);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(),^{
                !callback ?: callback(nil, error);
            });
        });
    });
}

- (id<CYLUserDelegate>)getProfileForUserId:(NSString *)userId error:(NSError * __autoreleasing *)theError {
    if (!userId) {
        NSInteger code = 0;
        NSString *errorReasonText = @"UserId is nil";
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                             code:code
                                         userInfo:errorInfo];
        
        if (theError == nil) {
            *theError = error;
        }
        return nil;
    }
    
    id<CYLUserDelegate> user = [self getCachedProfileIfExists:userId error:nil];
    if (user) {
        return user;
    }
    NSArray *users = [self getProfilesForUserIds:@[userId] error:theError];
    if (users.count > 0) {
        return users[0];
    }
    return nil;
}

- (void)getProfileInBackgroundForUserId:(NSString *)userId callback:(CYLUserResultCallBack)callback {
    if (!userId) {
        NSInteger code = 0;
        NSString *errorReasonText = @"UserId is nil";
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                             code:code
                                         userInfo:errorInfo];
        !callback ?: callback(nil, error);
        return;
    }
    [self getProfilesInBackgroundForUserIds:@[userId] callback:^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
        if (!error && users && (users.count > 0)) {
            !callback ?: callback(users[0], nil);
            return;
        }
        !callback ?: callback(nil, error);
    }];
}

- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds shouldSameCount:(BOOL)shouldSameCount error:(NSError * __autoreleasing *)theError {
    NSArray *cachedProfiles = [self getCachedProfilesIfExists:userIds error:theError];
    if (!shouldSameCount) {
        return cachedProfiles;
    }
    if (cachedProfiles.count == userIds.count) {
        return cachedProfiles;
    }
    return nil;
}

- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)theError {
    if (!userIds || userIds.count == 0) {
        NSInteger code = 0;
        NSString *errorReasonText = @"UserIds is nil";
        NSDictionary *errorInfo = @{
                                    @"code" : @(code),
                                    NSLocalizedDescriptionKey : errorReasonText,
                                    };
        NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                             code:code
                                         userInfo:errorInfo];
        if (theError) {
            *theError = error;
        }
        return nil;
    }
    NSMutableArray *cachedProfiles = [NSMutableArray arrayWithCapacity:self.cachedUsers.count * 0.5];
    NSArray *allCachedUserIds = [self.cachedUsers allKeys];
    [userIds enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([allCachedUserIds containsObject:obj]) {
            [cachedProfiles addObject:[self getUserForClientId:obj]];
        }
    }];
    return [cachedProfiles copy];
}

- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL error:(NSError * __autoreleasing *)theError {
    if (userId) {
        NSString *userName_ = nil;
        NSURL *avatarURL_ = nil;
        id<CYLUserDelegate> user = [self getUserForClientId:userId];
        userName_ = user.name;
        avatarURL_ = user.avatarURL;
        if (userName_ || avatarURL_) {
            if (name) {
                *name = userName_;
            }
            if (avatarURL) {
                *avatarURL = avatarURL_;
            }
            return;
        }
        
    }
    NSInteger code = 0;
    NSString *errorReasonText = @"No cached profile";
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : errorReasonText,
                                };
    NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                         code:code
                                     userInfo:errorInfo];
    if (theError) {
        *theError = error;
    }
}

- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL userTye:(NSInteger *)userType error:(NSError * __autoreleasing *)theError {
    if (userId) {
        NSString *userName_ = nil;
        NSURL *avatarURL_ = nil;
        NSInteger userType_ = 0;
        id<CYLUserDelegate> user = [self getUserForClientId:userId];
        userName_ = user.name;
        avatarURL_ = user.avatarURL;
        userType_ = user.userType;
        if (userName_ || avatarURL_) {
            if (name) {
                *name = userName_;
            }
            if (avatarURL) {
                *avatarURL = avatarURL_;
            }
            if (userType) {
                *userType = userType_;
            }
            return;
        }
        
    }
    NSInteger code = 0;
    NSString *errorReasonText = @"No cached profile";
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : errorReasonText,
                                };
    NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                         code:code
                                     userInfo:errorInfo];
    if (theError) {
        *theError = error;
    }
}

- (void)removeCachedProfileForPeerId:(NSString *)peerId {
    NSString *clientId_ = [peerId copy];
    if (!clientId_) {
        return;
    }
    dispatch_async(self.isolationQueue, ^(){
        [self.cachedUsers removeObjectForKey:peerId];
    });
}

- (void)removeAllCachedProfiles {
    dispatch_async(self.isolationQueue, ^(){
        self.cachedUsers = nil;
    });
}

- (id<CYLUserDelegate>)fetchCurrentUser {
    NSError *error = nil;
    id<CYLUserDelegate> user = [[CYLUserSystemService sharedInstance] getCachedProfileIfExists:[CYLSessionService sharedInstance].clientId error:&error];
    if (!error) {
        return user;
    }
    error = nil;
    id<CYLUserDelegate> currentUser = [[CYLUserSystemService sharedInstance] getProfileForUserId:[CYLSessionService sharedInstance].clientId error:&error];
    if (!error) {
        return currentUser;
    }
    //    NSLog(@"%@", error);
    return nil;
}

- (void)fetchCurrentUserInBackground:(CYLUserResultCallBack)callback {
    NSError *error = nil;
    id<CYLUserDelegate> user = [[CYLUserSystemService sharedInstance] getCachedProfileIfExists:[CYLSessionService sharedInstance].clientId error:&error];
    if (!error) {
        !callback ?: callback(user, nil);
        return;
    }
    
    [[CYLUserSystemService sharedInstance] getProfileInBackgroundForUserId:[CYLSessionService sharedInstance].clientId callback:^(id<CYLUserDelegate> user, NSError *error) {
        if (!error) {
            !callback ?: callback(user, nil);
            return;
        }
        !callback ?: callback(nil, error);
    }];
}

- (id<CYLUserDelegate>)getCachedProfileIfExists:(NSString *)userId error:(NSError * __autoreleasing *)theError {
    id<CYLUserDelegate> user;
    if (userId) {
        user = [self getUserForClientId:userId];
    }
    if (user) {
        return user;
    }
    NSInteger code = 0;
    NSString *errorReasonText = @"No cached profile";
    NSDictionary *errorInfo = @{
                                @"code" : @(code),
                                NSLocalizedDescriptionKey : errorReasonText,
                                };
    NSError *error = [NSError errorWithDomain:CYLUserSystemServiceErrorDomain
                                         code:code
                                     userInfo:errorInfo];
    if (theError) {
        *theError = error;
    }
    return nil;
}

- (void)cacheUsersWithIds:(NSSet<id<CYLUserDelegate>> *)userIds callback:(CYLBooleanResultBlock)callback {
    NSMutableSet *uncachedUserIds = [[NSMutableSet alloc] init];
    for (NSString *userId in userIds) {
        if ([self getCachedProfileIfExists:userId error:nil] == nil) {
            [uncachedUserIds addObject:userId];
        }
    }
    if ([uncachedUserIds count] > 0) {
        [self getProfilesInBackgroundForUserIds:[[NSMutableArray alloc] initWithArray:[uncachedUserIds allObjects]] callback:^(NSArray<id<CYLUserDelegate>> *users, NSError *error) {
            if (users) {
                [self cacheUsers:users];
            }
            !callback ?: callback(YES, error);
        }];
    } else {
        !callback ?: callback(YES, nil);
    }
}

//TODO:改为异步操作，启用本地缓存。只在关键操作时更新本地缓存，比如：签名机制对应的几个操作：加人、踢人等。
- (void)cacheUsers:(NSArray<id<CYLUserDelegate>> *)users {
    if (users.count > 0) {
        for (id<CYLUserDelegate> user in users) {
            @try {
                [self setUser:user forClientId:user.clientId];
            } @catch (NSException *exception) {
                NSString *formatString = @"\n\n\
                ------ BEGIN NSException Log ---------------\n \
                class name: %@                              \n \
                ------line: %@                              \n \
                ----reason: %@                              \n \
                ------ END -------------------------------- \n\n";
                NSString *errorReasonText = [NSString stringWithFormat:formatString,
                                             @(__PRETTY_FUNCTION__),
                                             @(__LINE__),
                                             @"User's clientId can not be nil, please make sure when you set `setFetchProfilesBlock:`"];
                CYLLog(@"%@", errorReasonText);
            }
        }
    }
}

#pragma mark -
#pragma mark - LazyLoad Method

/**
 *  lazy load cachedUsers
 *
 *  @return NSMutableDictionary
 */
- (NSMutableDictionary *)cachedUsers {
    if (_cachedUsers == nil) {
        _cachedUsers = [[NSMutableDictionary alloc] init];
    }
    return _cachedUsers;
}

#pragma mark -
#pragma mark - set or get cached user Method

- (void)setUser:(id<CYLUserDelegate>)user forClientId:(NSString *)clientId {
    NSString *clientId_ = [clientId copy];
    if (!clientId_) {
        return;
    }
    dispatch_async(self.isolationQueue, ^(){
        if (!user) {
            [self.cachedUsers removeObjectForKey:clientId_];
        } else {
            [self.cachedUsers setObject:user forKey:clientId_];
        }
    });
}

- (id<CYLUserDelegate>)getUserForClientId:(NSString *)clientId {
    if (!clientId) {
        return nil;
    }
    __block id<CYLUserDelegate> user = nil;
    dispatch_sync(self.isolationQueue, ^(){
        user = self.cachedUsers[clientId];
    });
    return user;
}

@end
