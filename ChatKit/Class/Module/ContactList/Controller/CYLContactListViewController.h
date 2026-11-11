//
//  CYLContactListViewController.h
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<CYLChatKit/CYLChatKit.h>)
    #import <CYLChatKit/CYLChatKit.h>
#else
    #import "CYLChatKit.h"
#endif

@class CYLContact;

typedef enum : NSUInteger {
    CYLContactListModeNormal,
    CYLContactListModeSingleSelection,
    CYLContactListModeMultipleSelection
} CYLContactListMode;
NS_ASSUME_NONNULL_BEGIN

typedef void (^CYLSelectedContactCallback)(UIViewController *viewController, NSString *peerId);
typedef void (^CYLSelectedContactsCallback)(UIViewController *viewController, NSArray<NSString *> *peerIds);

/*!
 * @return 删除是否成功
 */
typedef BOOL (^CYLDeleteContactCallback)(UIViewController *viewController, NSString *peerId);

@interface CYLContactListViewController : CYLChatBaseTableViewController

/*!
 * 不参与展示的名单，可以是黑名单或者当前用户。该数组是client id的集合。
 */
@property (nonatomic) NSSet *excludedUserIds;

@property (nonatomic, assign, readonly) CYLContactListMode mode;
@property (nonatomic, copy) NSSet<CYLContact *> *contacts;
@property (nonatomic, copy) NSSet<NSString *> *userIds;

- (void)setDeleteContactCallback:(CYLDeleteContactCallback)deleteContactCallback;
- (CYLDeleteContactCallback)deleteContactCallback;

- (void)setSelectedContactCallback:(CYLSelectedContactCallback)selectedContactCallback;
- (CYLSelectedContactCallback)selectedContactCallback;
- (void)setSelectedContactsCallback:(CYLSelectedContactsCallback)selectedContactsCallback;
- (CYLSelectedContactsCallback)selectedContactsCallback;
- (instancetype)initWithContacts:(NSSet<CYLContact *> *)contacts
                            mode:(CYLContactListMode)mode;

- (instancetype)initWithContacts:(NSSet<CYLContact *> *)contacts
                 excludedUserIds:(NSSet * __nullable)excludedUserIds
                            mode:(CYLContactListMode)mode;

- (instancetype)initWithUserIds:(NSSet<NSString *> *)userIds
                           mode:(CYLContactListMode)contactListMode;

- (instancetype)initWithUserIds:(NSSet<NSString *> *)userIds
                 excludedUserIds:(NSSet * __nullable)excludedUserIds
                            mode:(CYLContactListMode)contactListMode;
/*!
 * @param 你可以使用 contacts 和 userIds 两个参数来进行联系人列表初始化，区别是前者可以为空，后者不可以为空。如果同时传了两个参数，那么前者优先级大于后者。如果只传了后者，ChatKit 会自行进行网络请求获取到对应的 contacts。
 * @param excludedUserIds 是黑名单，不希望出现在联系人列表里的用户id，最常见的是将自己的id放在这里。
 * @param contactListMode 主要分为：单选、多选、点击即跳转。
 */
- (instancetype)initWithContacts:(NSSet<CYLContact *> * __nullable)contacts
                         userIds:(NSSet<NSString *> *)userIds
                 excludedUserIds:(NSSet * __nullable)excludedUserIds
                            mode:(CYLContactListMode)contactListMode;
NS_ASSUME_NONNULL_END

@end
