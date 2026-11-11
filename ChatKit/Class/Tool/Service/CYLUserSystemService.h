//
//  CYLUserSystemService.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//  Service for User-System.

#import <Foundation/Foundation.h>
#import "CYLServiceDefinition.h"
#import "CYLUserDelegate.h"

/*!
 *  You must implement `-setFetchProfilesBlock:` to allow LeanCloudChatKit to get user information by user clientId.
 *   The following example shows how to use AVUser as the user system:

 ```
    [[CYLChatKit sharedInstance] setFetchProfilesBlock:^(NSArray<NSString *> *userIds, CYLFetchProfilesCompletionHandler completionHandler) {
        NSMutableArray<id<CYLUserDelegate>> *userList = [NSMutableArray array];
        for (NSString *userId in userIds) {
            //MyUser is a subclass of AVUser, conforming to the CYLUserDelegate protocol.
            AVQuery *query = [CYLUser query];
            NSError *error = nil;
            AVUser *user = [query getObjectWithId:userId error:&error];
            CYLUser *object = [CYLUser userWithClientId:user.objectId];
            if (error == nil) {
                [userList addObject:object];
            } else {
                if (completionHandler) {
                    completionHandler(nil, error);
                    return;
                }
            }
        }
        if (completionHandler) {
            completionHandler(userList, nil);
        }
    }
     ];

  ```
 
*/

/*!
 * CYLUserSystemService error domain
 */
FOUNDATION_EXTERN NSString *const CYLUserSystemServiceErrorDomain;

@interface CYLUserSystemService : CYLSingleton <CYLUserSystemService>

/*!
 * syc fetch, only fetch from network.
 */
- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)theError;

- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback;

- (id<CYLUserDelegate>)getProfileForUserId:(NSString *)userId error:(NSError * __autoreleasing *)theError NS_SWIFT_NAME(getProfile(forUserId:));

/*!
 * Firstly try memory cache, then fetch.
 */
- (id<CYLUserDelegate>)fetchCurrentUser;

/*!
 * Firstly try memory cache, then fetch.
 */
- (void)fetchCurrentUserInBackground:(CYLUserResultCallBack)callback;

- (void)cacheUsersWithIds:(NSSet<id<CYLUserDelegate>> *)userIds callback:(CYLBooleanResultBlock)callback;

- (void)cacheUsers:(NSArray<id<CYLUserDelegate>> *)users;

@end
