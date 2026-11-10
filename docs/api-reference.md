# CYLChatKit public API reference

This reference lists every public declaration of the ChatKit library (`CYLChatKit.podspec` publishes all
`ChatKit/**/*.h`). It was generated from the headers at commit `9b14442` and replaces the API lists that were
scattered across the README. When a header changes, update this file in the same commit.

Related documents: [LeanCloud decoupling and prefix rename](leancloud-decoupling.md) (design, behavior
changes, and open TODOs), [README](../README.md), [business customization](../ChatKit%20自定义业务.md),
[style customization](../ChatKit%20自定义样式.md).

## Naming conventions

- Every core type, protocol, enum, constant, and macro starts with `CYL`; category methods and properties start with `cyl_`, and their setters with `setCyl_`.
- Names that would collide with `CYLTabBarController` or `CYLDeallocBlockExecutor` use `CYLChat` (`CYLChatBaseViewController`, `CYLChatBaseNavigationController`, `CYLChatBaseTableViewController`, `CYLChatConstants.h`).
- The facade class `LCChatKit` and `ChatKitHeaders.h` keep their names.
- Core contains no IM SDK code. The IM backend is an `id<CYLIMProvider>` registered on `LCChatKit`; the demo ships a LeanCloud implementation, `LCCKLeanCloudIMProvider`, whose own symbols keep the demo prefix `LCCK`.

## Rename assessment

Acceptance criterion: in core (`ChatKit/`), `LCCK` → `CYL`, `AVOS` → `CYL`, `AVIM` → `CYLIM`, `lcck_` → `cyl_`, without introducing compile errors.
Every API that needed renaming counts toward the score; the score is 100 when all of them are fixed.

**Score: 100 / 100** (1362 of 1362 affected public API names fixed).

| Check | Result | Status |
|:---|:---|:---|
| Legacy tokens in core file contents (`grep -i` for LCCK, lcck, AVOS, AVIM) | 0 files | ✅ |
| Legacy tokens in core file and folder names | 0 paths | ✅ |
| Public declarations that still reference a legacy name | 0 of 1196 | ✅ |
| Original public names not accounted for | 0 of 1528 | ✅ |
| Symbol collisions with CYLTabBarController 1.99.72 and CYLDeallocBlockExecutor 1.2.0 | 0 (the identical `CYL_DEPRECATED` macro is a legal redefinition) | ✅ |
| Demo references to core names that do not exist | 0 | ✅ |
| Required `CYLIMProvider` methods implemented by the demo provider | all 36 | ✅ |
| Stale API names in README and the customization guides | 0 | ✅ |
| Xcode build of the library and the demo | not run (no Xcode in this environment) | ⏳ TODO |

How the score is computed: every public name in the original headers (`b730b8d`) whose name or owner contained
`LCCK`, `lcck_`, `Lcck_`, `AVOS`, `AVIM`, or `avim` is an affected API. It counts as fixed when its renamed form
exists in the current headers, or when it was moved to the demo or removed for a documented reason (see
[Moved and removed](#moved-and-removed)). Names without those prefixes are listed as unchanged.

Compile status: the checks above are static (selector coverage, clang syntax checks with stub SDK headers,
conformance against the LeanCloud SDK 11.5.2 declarations, and a symbol collision scan against
`CYLTabBarController` 1.99.72 and `CYLDeallocBlockExecutor` 1.2.0). An Xcode build of the library and the demo
has not been run; it is tracked as a TODO in [leancloud-decoupling.md](leancloud-decoupling.md#todo).

## Entry points

```objc
// 1. Register an IM backend (the demo uses LeanCloud).
[LCChatKit sharedInstance].IMProvider = [[LCCKLeanCloudIMProvider alloc] init];
// 2. Start ChatKit after each login, then open the IM session.
[LCChatKit setAppId:appId appKey:appKey];
[[LCChatKit sharedInstance] openWithClientId:clientId callback:^(BOOL succeeded, NSError *error) { /* ... */ }];
// 3. Show the UI.
CYLConversationListViewController *list = [[CYLConversationListViewController alloc] init];
CYLConversationViewController *chat = [[CYLConversationViewController alloc] initWithConversationId:conversationId];
```

Key types: `LCChatKit` (facade), `CYLIMProvider` (IM backend protocol), `CYLConversationProtocol` and
`CYLIMMessageProtocol` (models provided by the backend), `CYLMessage` (display model),
`CYLConversationViewController`, `CYLConversationListViewController`, `CYLChatMessageCell` (custom cells).

## Declarations by module

- [Entry point](#entry-point) (1 headers)
- [Model](#model) (9 headers)
- [Module: Base](#module-base) (4 headers)
- [Module: ContactList](#module-contactlist) (3 headers)
- [Module: Conversation](#module-conversation) (48 headers)
- [Module: ConversationList](#module-conversationlist) (3 headers)
- [Tool](#tool) (22 headers)
- [View](#view) (4 headers)
- [Vendor (CYLAlertController)](#vendor-cylalertcontroller) (1 headers)
- [Vendor (CYLPhotoBrowser)](#vendor-cylphotobrowser) (8 headers)
- [Vendor (CYLTableViewRowAction)](#vendor-cyltableviewrowaction) (1 headers)
- [Vendor (CYLWebViewController)](#vendor-cylwebviewcontroller) (4 headers)
- [Vendor (DateTools)](#vendor-datetools) (3 headers)
- [Vendor (VoiceLib)](#vendor-voicelib) (2 headers)

### Entry point

#### `LCChatKit.h`

Path: `ChatKit/Class/LCChatKit.h`

**Class `LCChatKit`** : `NSObject` &lt;CYLSessionService, CYLUserSystemService, CYLSignatureService, CYLSettingService, CYLUIService, CYLConversationService, CYLConversationsListService&gt;

```objc
@property (nonatomic, strong) id<CYLIMProvider> IMProvider;
@property (nonatomic, copy, readonly) NSString *appId;
@property (nonatomic, copy, readonly) NSString *appKey;
+ (void)setAppId:(NSString *)appId appKey:(NSString *)appKey;
+ (instancetype)sharedInstance;
```

### Model

#### `CYLCommonUtils.h`

Path: `ChatKit/Class/Model/CYLCommonUtils.h`

**Class `CYLCommonUtils`** : `NSObject`

```objc
+ (void)recognitionWithImage:(UIImage *)image callback:(void(^)(NSDictionary *dict))callback;
+ (void)getLocationFromDataString:(NSString *)dataString latitudeFloatValue:(CGFloat *)theLatitudeFloatValue longitudeFloatValue:(CGFloat *)theLongitudeFloatValue name:(NSString **)theName;
- (void)jumpMapWithName:(NSString *)mapname coordinate:(CLLocationCoordinate2D)coordinate destinationName:(NSString *)name;
+ (void)getInfoFromAmap:(NSString *)url latitude:(NSString **)outLatitude longitude:(NSString **)outLongitude address:(NSString **)outAddress;
- (void)jusmAMapWithURLString:(NSString *)urlString;
+ (NSString *)decodeWithParemsForURLString:(NSString *)URLString;
+ (NSString *)encodeWithParemsForURLString:(NSString *)URLString;
```

#### `CYLConversationProtocol.h`

Path: `ChatKit/Class/Model/CYLConversationProtocol.h`

**Protocol `CYLConversationProtocol`** adopts &lt;NSObject&gt;

```objc
- (nullable NSString *)conversationId;
- (nullable NSString *)name;
- (nullable NSString *)creator;
- (nullable NSArray<NSString *> *)members;
- (nullable NSDictionary *)attributes;
- (BOOL)muted;
- (nullable NSDate *)createAt;
- (BOOL)transient;
- (CYLConversationType)cyl_type;
- (nullable NSString *)cyl_peerId;
- (nullable NSString *)cyl_displayName;
- (nullable NSString *)cyl_title;
- (nullable NSString *)cyl_badgeText;
- (nullable NSString *)cyl_draft;
- (void)setCyl_draft:(nullable NSString *)cyl_draft;
- (NSInteger)cyl_unreadCount;
- (BOOL)cyl_mentioned;
- (nullable id<CYLIMMessageProtocol>)cyl_lastMessage;
- (nullable NSDate *)cyl_lastMessageAt;
- (BOOL)cyl_isCreaterForCurrentUser;
- (void)cyl_setConversationWithMute:(BOOL)mute callback:(nullable CYLBooleanResultBlock)callback;
```

#### `CYLIMMessageProtocol.h`

Path: `ChatKit/Class/Model/CYLIMMessageProtocol.h`

**Protocol `CYLIMMessageProtocol`** adopts &lt;NSObject&gt;

```objc
- (CYLMessageMediaType)mediaType;
- (nullable NSString *)messageId;
- (nullable NSString *)conversationId;
- (nullable NSString *)text;
- (BOOL)mentioned;
- (nullable NSDictionary *)attributes;
- (void)setAttributes:(nullable NSDictionary *)attributes;
- (nullable NSString *)cyl_senderId;
- (void)setCyl_senderId:(nullable NSString *)senderId;
- (CYLMessageOwnerType)cyl_ownerType;
- (CYLMessageSendState)cyl_sendStatus;
- (int64_t)cyl_sendTimestamp;
```

#### `CYLMessage.h`

Path: `ChatKit/Class/Model/CYLMessage.h`

**Class `CYLMessage`** : `NSObject` &lt;NSCoding, NSCopying, CYLMessageDelegate&gt;

```objc
@property (nonatomic, strong) id message;
@property (nonatomic, copy, readonly) NSString *text;
@property (nonatomic, copy, readonly) NSString *systemText;
@property (nonatomic, strong, readonly) UIImage *videoConverPhoto;
@property (nonatomic, copy, readonly) NSString *videoPath;
@property (nonatomic, strong, readonly) NSURL *videoURL;
@property (nonatomic, copy, readonly) NSString *voicePath;
@property (nonatomic, strong, readonly) NSURL *voiceURL;
@property (nonatomic, copy, readonly) NSString *voiceDuration;
@property (nonatomic, strong, readonly) UIImage *localPositionPhoto;
@property (nonatomic, copy, readonly) NSString *geolocations;
@property (nonatomic, strong, readonly) CLLocation *location;
@property (nonatomic, assign, readonly) CYLMessageReadState messageReadState;
@property (nonatomic, copy, readwrite) NSString *serverMessageId;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign, getter=isLocalMessage) BOOL localMessage;
@property (nonatomic, copy, readwrite) NSString *localMessageId;
@property (nonatomic, copy, readonly) NSString *localDisplayName;
@property (nonatomic, assign, readonly) NSInteger userType;
- (instancetype)initWithText:(NSString *)text senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp serverMessageId:(NSString *)serverMessageId;
- (instancetype)initWithSystemText:(NSString *)text;
+ (instancetype)systemMessageWithTimestamp:(NSTimeInterval)timestamp;
- (instancetype)initWithLocalFeedbackText:(NSString *)localFeedbackText;
+ (instancetype)localFeedbackText:(NSString *)localFeedbackText;
- (instancetype)initWithPhoto:(UIImage *)photo photoWidth:(uint)photoWidth photoHeight:(uint)photoHeight thumbnailPhoto:(UIImage *)thumbnailPhoto photoPath:(NSString *)photoPath thumbnailURL:(NSURL *)thumbnailURL originPhotoURL:(NSURL *)originPhotoURL senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp serverMessageId:(NSString *)serverMessageId;
- (instancetype)initWithVideoConverPhoto:(UIImage *)videoConverPhoto videoPath:(NSString *)videoPath videoURL:(NSURL *)videoURL senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp serverMessageId:(NSString *)serverMessageId;
- (instancetype)initWithVoicePath:(NSString *)voicePath voiceURL:(NSURL *)voiceURL voiceDuration:(NSString *)voiceDuration senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp serverMessageId:(NSString *)serverMessageId;
- (instancetype)initWithVoicePath:(NSString *)voicePath voiceURL:(NSURL *)voiceURL voiceDuration:(NSString *)voiceDuration senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp hasRead:(BOOL)hasRead serverMessageId:(NSString *)serverMessageId;
- (instancetype)initWithLocalPositionPhoto:(UIImage *)localPositionPhoto geolocations:(NSString *)geolocations location:(CLLocation *)location senderId:(NSString *)senderId sender:(id<CYLUserDelegate>)sender timestamp:(NSTimeInterval)timestamp serverMessageId:(NSString *)serverMessageId;
```

#### `CYLMessageDelegate.h`

Path: `ChatKit/Class/Model/CYLMessageDelegate.h`

**Protocol `CYLMessageDelegate`** adopts &lt;NSObject, NSCopying, NSCoding&gt;

```objc
@required
@property (nonatomic, strong, readwrite) UIImage *photo;
@property (nonatomic, strong, readwrite) UIImage *thumbnailPhoto;
@property(nonatomic, assign, readonly) int photoWidth;
@property(nonatomic, assign, readonly) int photoHeight;
@property (nonatomic, copy, readonly) NSString *photoPath;
@property (nonatomic, strong, readonly) NSURL *originPhotoURL;
@property (nonatomic, assign, readonly) CYLMessageMediaType mediaType;
@optional
@property (nonatomic, strong, readonly) NSURL *thumbnailURL;
@property (nonatomic, copy, readonly) NSString *messageId;
@property (nonatomic, strong) id<CYLUserDelegate> sender;
@property (nonatomic, copy) NSString *senderId;
@property (nonatomic, assign) CYLMessageSendState sendStatus;
@property (nonatomic, copy) NSString *conversationId;
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;
@property (nonatomic, assign) CYLMessageOwnerType ownerType;
@property (nonatomic, assign, readonly, getter=hasRead) BOOL read;
@property (nonatomic, assign, readonly) BOOL receiverHasReaded;
@property (nonatomic, strong, readonly) NSString *ownerName;
```

#### `CYLUserDelegate.h`

Path: `ChatKit/Class/Model/CYLUserDelegate.h`

**Protocol `CYLUserDelegate`** adopts &lt;NSObject, NSCopying, NSCoding&gt;

```objc
@required
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSURL *avatarURL;
@property (nonatomic, copy, readwrite) NSString *clientId;
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId;
+ (instancetype)userWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL clientId:(NSString *)clientId;
@optional
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL;
+ (instancetype)userWithUserId:(NSString *)userId name:(NSString *)name avatarURL:(NSURL *)avatarURL;
- (instancetype)initWithClientId:(NSString *)clientId;
+ (instancetype)userWithClientId:(NSString *)clientId;
@property (nonatomic, assign) NSInteger userType;
```

#### `CYLUserModelDelegate.h`

Path: `ChatKit/Class/Model/CYLUserModelDelegate.h`

**Protocol `CYLUserModelDelegate`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSURL *avatorURL;
- (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatorURL:(NSURL *)avatorURL;
+ (instancetype)initWithUserId:(NSString *)userId name:(NSString *)name avatorURL:(NSURL *)avatorURL;
```

#### `NSMutableArray+CYLMessageExtention.h`

Path: `ChatKit/Class/Model/NSMutableArray+CYLMessageExtention.h`

**Category `NSMutableArray (CYLMessageExtention)`**

```objc
+ (NSMutableArray *)cyl_messagesWithCYLIMMessages:(NSArray *)cylimTypedMessage;
- (void)cyl_removeMessageAtIndex:(NSUInteger)index;
- (id)cyl_messageAtIndex:(NSUInteger)index;
```

#### `NSObject+CYLExtension.h`

Path: `ChatKit/Class/Model/NSObject+CYLExtension.h`

**Category `NSObject (CYLExtension)`**

```objc
- (BOOL)cyl_isCustomMessage;
- (BOOL)cyl_isCustomCYLMessage;
- (NSTimeInterval)cyl_messageTimestamp;
- (void)cyl_shouldDisplayTimestampForMessages:(NSArray *)messages callback:(CYLShouldDisplayTimestampCallBack)callback;
- (NSDictionary *)cyl_JSONValue;
- (BOOL)cyl_isCreatorForCurrentGroupConversaton;
```

**Typedefs**

```objc
typedef void (^CYLShouldDisplayTimestampCallBack)(BOOL shouldDisplayTimestamp, NSTimeInterval messageTimestamp);
```

### Module: Base

#### `CYLBaseConversationViewController.h`

Path: `ChatKit/Class/Module/Base/CYLBaseConversationViewController.h`

**Class `CYLBaseConversationViewController`** : `CYLChatBaseTableViewController`

```objc
@property (nonatomic, assign) BOOL loadingMoreMessage;
@property (nonatomic, weak) CYLChatBar *chatBar;
@property (nonatomic, assign) BOOL shouldLoadMoreMessagesScrollToTop;
@property (nonatomic, assign) BOOL allowScrollToBottom;
@property (nonatomic, assign) CGFloat tableViewLastContentOffset;
- (void)scrollToBottomAnimated:(BOOL)animated;
- (void)loadMoreMessagesScrollTotop;
@property (nonatomic, assign) BOOL isUserScrolling;
```

#### `CYLChatBaseNavigationController.h`

Path: `ChatKit/Class/Module/Base/CYLChatBaseNavigationController.h`

**Class `CYLChatBaseNavigationController`** : `UINavigationController`

#### `CYLChatBaseTableViewController.h`

Path: `ChatKit/Class/Module/Base/CYLChatBaseTableViewController.h`

**Class `CYLChatBaseTableViewController`** : `CYLChatBaseViewController` &lt;UITableViewDelegate, UITableViewDataSource&gt;

```objc
@property (nonatomic, strong, readonly) CYLStatusView *clientStatusView;
@property (nonatomic, assign) CYLViewControllerStyle viewControllerStyle;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign, getter=shouldCheckSessionStatus) BOOL checkSessionStatus;
- (void)loadDataSource;
- (void)updateStatusView;
```

**Enums**

- `CYLViewControllerStyle` (`enum`): `CYLViewControllerStylePlain`, `CYLViewControllerStylePresenting`

#### `CYLChatBaseViewController.h`

Path: `ChatKit/Class/Module/Base/CYLChatBaseViewController.h`

**Class `CYLChatBaseViewController`** : `UIViewController` &lt;CYLViewControllerEventProtocol&gt;

```objc
- (void)configureBarButtonItemStyle:(CYLBarButtonItemStyle)style action:(CYLBarButtonItemActionBlock)action;
- (void)alert:(NSString *)message;
- (BOOL)alertCYLIMError:(NSError *)error;
- (BOOL)filterCYLIMError:(NSError *)error;
```

**Protocol `CYLViewControllerEventProtocol`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy) CYLViewDidLoadBlock viewDidLoadBlock;
@property (nonatomic, copy) CYLViewWillAppearBlock viewWillAppearBlock;
@property (nonatomic, copy) CYLViewDidAppearBlock viewDidAppearBlock;
@property (nonatomic, copy) CYLViewWillDisappearBlock viewWillDisappearBlock;
@property (nonatomic, copy) CYLViewDidDisappearBlock viewDidDisappearBlock;
@property (nonatomic, copy) CYLViewDidDismissBlock viewDidDismissBlock;
@property (nonatomic, copy) CYLViewControllerWillDeallocBlock viewControllerWillDeallocBlock;
@property (nonatomic, copy) CYLViewDidReceiveMemoryWarningBlock didReceiveMemoryWarningBlock;
- (void)setViewDidLoadBlock:(CYLViewDidLoadBlock)viewDidLoadBlock;
- (void)setViewWillAppearBlock:(CYLViewWillAppearBlock)viewWillAppearBlock;
- (void)setViewDidAppearBlock:(CYLViewDidAppearBlock)viewDidAppearBlock;
- (void)setViewWillDisappearBlock:(CYLViewWillDisappearBlock)viewWillDisappearBlock;
- (void)setViewDidDisappearBlock:(CYLViewDidDisappearBlock)viewDidDisappearBlock;
- (void)setViewDidDismissBlock:(CYLViewDidDismissBlock)viewDidDismissBlock;
- (void)setViewControllerWillDeallocBlock:(CYLViewControllerWillDeallocBlock)viewControllerWillDeallocBlock;
- (void)setViewDidReceiveMemoryWarningBlock:(CYLViewDidReceiveMemoryWarningBlock)didReceiveMemoryWarningBlock;
```

**Enums**

- `CYLBarButtonItemStyle` (`NSInteger`): `CYLBarButtonItemStyleSetting`, `CYLBarButtonItemStyleMore`, `CYLBarButtonItemStyleAdd`, `CYLBarButtonItemStyleAddFriends`, `CYLBarButtonItemStyleShare`, `CYLBarButtonItemStyleSingleProfile`, `CYLBarButtonItemStyleGroupProfile`

**Typedefs**

```objc
typedef void(^CYLViewDidLoadBlock)(__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewWillAppearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidAppearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewWillDisappearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidDisappearBlock)(__kindof CYLChatBaseViewController *viewController, BOOL aAnimated);
typedef void(^CYLViewDidDismissBlock)(__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewControllerWillDeallocBlock) (__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLViewDidReceiveMemoryWarningBlock)(__kindof CYLChatBaseViewController *viewController);
typedef void(^CYLBarButtonItemActionBlock)(__kindof CYLChatBaseViewController *viewController, UIBarButtonItem *sender, UIEvent *event);
```

### Module: ContactList

#### `CYLContactListViewController.h`

Path: `ChatKit/Class/Module/ContactList/Controller/CYLContactListViewController.h`

**Class `CYLContactListViewController`** : `CYLChatBaseTableViewController`

```objc
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
- (instancetype)initWithContacts:(NSSet<CYLContact *> *)contacts mode:(CYLContactListMode)mode;
- (instancetype)initWithContacts:(NSSet<CYLContact *> *)contacts excludedUserIds:(NSSet * __nullable)excludedUserIds mode:(CYLContactListMode)mode;
- (instancetype)initWithUserIds:(NSSet<NSString *> *)userIds mode:(CYLContactListMode)contactListMode;
- (instancetype)initWithUserIds:(NSSet<NSString *> *)userIds excludedUserIds:(NSSet * __nullable)excludedUserIds mode:(CYLContactListMode)contactListMode;
- (instancetype)initWithContacts:(NSSet<CYLContact *> * __nullable)contacts userIds:(NSSet<NSString *> *)userIds excludedUserIds:(NSSet * __nullable)excludedUserIds mode:(CYLContactListMode)contactListMode;
```

**Enums**

- `CYLContactListMode` (`enum`): `CYLContactListModeNormal`, `CYLContactListModeSingleSelection`, `CYLContactListModeMultipleSelection`

**Typedefs**

```objc
typedef void (^CYLSelectedContactCallback)(UIViewController *viewController, NSString *peerId);
typedef void (^CYLSelectedContactsCallback)(UIViewController *viewController, NSArray<NSString *> *peerIds);
typedef BOOL (^CYLDeleteContactCallback)(UIViewController *viewController, NSString *peerId);
```

#### `CYLContact.h`

Path: `ChatKit/Class/Module/ContactList/Model/CYLContact.h`

**Class `CYLContact`** : `NSObject` &lt;CYLUserDelegate&gt;

```objc
@property (nonatomic, assign, getter = isChecked) BOOL checked;
```

#### `CYLContactCell.h`

Path: `ChatKit/Class/Module/ContactList/View/CYLContactCell.h`

**Class `CYLContactCell`** : `UITableViewCell`

```objc
- (void)configureWithAvatarURL:(NSURL *)avatarURL title:(NSString *)title subtitle:(NSString *)subtitle model:(CYLContactListMode)model;
@property (nonatomic, assign, getter=isChecked) BOOL checked;
@property (nonatomic, copy) NSString *identifier;
```

### Module: Conversation

#### `CYLConversationViewController.h`

Path: `ChatKit/Class/Module/Conversation/Controller/CYLConversationViewController.h`

**Class `CYLConversationViewController`** : `CYLBaseConversationViewController` &lt;CYLChatMessageCellDelegate&gt;

```objc
@property (nonatomic, copy, readonly) NSString *conversationId;
@property (nonatomic, copy, readonly) NSString *peerId;
- (instancetype)initWithPeerId:(NSString *)peerId;
- (instancetype)initWithConversationId:(NSString *)conversationId;
@property (nonatomic, assign, getter=isEnableAutoJoin) BOOL enableAutoJoin;
@property (nonatomic, assign, getter=isAvailable, readonly) BOOL available;
@property (nonatomic, copy) NSString *title;
- (id<CYLConversationProtocol>)getConversationIfExists;
- (void)sendMessage:(id)message mentionList:(NSArray<NSString *> *)mentionList;
- (void)sendImageMessage:(UIImage *)image;
- (void)sendImageMessageData:(NSData *)imageData;
- (void)sendVoiceMessageWithPath:(NSString *)voicePath time:(NSTimeInterval)recordingSeconds;
- (void)sendLocationMessageWithLocationCoordinate:(CLLocationCoordinate2D)locationCoordinate locatioTitle:(NSString *)locationTitle;
- (void)sendLocalFeedbackTextMessge:(NSString *)localFeedbackTextMessge;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage progressBlock:(CYLProgressBlock)progressBlock success:(CYLBooleanResultBlock)success failed:(CYLBooleanResultBlock)failed;
@property (nonatomic, assign) BOOL disableTextShowInFullScreen;
@property (nonatomic, assign, getter=isDisableTitleAutoConfig) BOOL disableTitleAutoConfig;
- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler;
- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLConversationViewControllerErrorDomain;
```

#### `CYLLocationController.h`

Path: `ChatKit/Class/Module/Conversation/Controller/CYLLocationController.h`

**Class `CYLLocationController`** : `UIViewController`

```objc
@property (weak, nonatomic) id<CYLLocationControllerDelegate> delegate;
```

**Protocol `CYLLocationControllerDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)cancelLocation;
- (void)sendLocation:(CLPlacemark *)placemark;
```

#### `CYLTextFullScreenViewController.h`

Path: `ChatKit/Class/Module/Conversation/Controller/CYLTextFullScreenViewController.h`

**Class `CYLTextFullScreenViewController`** : `CYLChatBaseViewController`

```objc
@property (nonatomic, copy, readonly) NSString *text;
- (instancetype)initWithText:(NSString *)text;
- (void)setRemoveFromWindowHandler:(CYLRemoveFromWindowHandler)removeFromWindowHandler;
```

**Typedefs**

```objc
typedef void (^CYLRemoveFromWindowHandler)(void);
```

#### `CYLConversationViewModel.h`

Path: `ChatKit/Class/Module/Conversation/Model/CYLConversationViewModel.h`

**Class `CYLConversationViewModel`** : `NSObject` &lt;UITableViewDelegate, UITableViewDataSource&gt;

```objc
@property (nonatomic, assign, readonly) NSUInteger messageCount;
@property (nonatomic, weak) id<CYLConversationViewModelDelegate> delegate;
- (instancetype)initWithParentViewController:(CYLConversationViewController *)parentViewController;
@property (nonatomic, strong, readonly) NSMutableArray<CYLMessage *> *dataArray;
@property (nonatomic, strong, readonly) NSMutableArray<id<CYLIMMessageProtocol>> *cylimTypedMessage;
- (void)sendMessage:(id)message;
- (void)sendMessage:(id)message mentionList:(NSArray<NSString *> *)mentionList;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)customMessage;
- (void)sendCustomMessage:(id<CYLIMMessageProtocol>)aMessage progressBlock:(CYLProgressBlock)progressBlock success:(CYLBooleanResultBlock)success failed:(CYLBooleanResultBlock)failed;
- (void)sendLocalFeedbackTextMessge:(NSString *)localFeedbackTextMessge;
- (void)loadMessagesFirstTimeWithCallback:(CYLIdBoolResultBlock)callback;
- (void)loadOldMessages;
- (void)getAllVisibleImagesForSelectedMessage:(CYLMessage *)message allVisibleImages:(NSArray **)allVisibleImages allVisibleThumbs:(NSArray **)allVisibleThumbs selectedMessageIndex:(NSNumber **)selectedMessageIndex;
- (void)resendMessageForMessageCell:(CYLChatMessageCell *)messageCell;
- (void)modifyMessageForMessageCell:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback;
- (void)recallMessageForMessageCell:(CYLChatMessageCell *)messageCell callback:(void (^)(BOOL, NSError *))callback;
- (void)resetBackgroundImage;
- (void)setDefaultBackgroundImage;
```

**Protocol `CYLConversationViewModelDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)reloadAfterReceiveMessage;
- (void)messageSendStateChanged:(CYLMessageSendState)sendState withProgress:(CGFloat)progress forIndex:(NSUInteger)index;
- (void)messageReadStateChanged:(CYLMessageReadState)readState withProgress:(CGFloat)progress forIndex:(NSUInteger)index;
```

**Typedefs**

```objc
typedef void (^CYLSendMessageSuccessBlock)(NSString *messageUUID);
typedef void (^CYLSendMessageSuccessFailedBlock)(NSString *messageUUID, NSError *error);
```

#### `CYLAVAudioPlayer.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLAVAudioPlayer.h`

**Class `CYLAVAudioPlayer`** : `NSObject`

```objc
@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) CYLVoiceMessageState audioPlayerState;
+ (instancetype)sharePlayer;
- (void)playAudioWithURLString:(NSString *)URLString identifier:(NSString *)identifier;
- (void)stopAudioPlayer;
- (void)cleanAudioCache;
```

#### `CYLBubbleImageFactory.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLBubbleImageFactory.h`

**Class `CYLBubbleImageFactory`** : `NSObject`

```objc
+ (UIImage *)bubbleImageViewForType:(CYLMessageOwnerType)owner messageType:(CYLMessageMediaType)messageMediaType isHighlighted:(BOOL)isHighlighted;
```

#### `CYLCellIdentifierFactory.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLCellIdentifierFactory.h`

**Class `CYLCellIdentifierFactory`** : `NSObject`

```objc
+ (NSString *)cellIdentifierForMessageConfiguration:(id)message conversationType:(CYLConversationType)conversationType;
+ (NSString *)cacheKeyForMessage:(id)message;
```

#### `CYLCellRegisterController.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLCellRegisterController.h`

**Class `CYLCellRegisterController`** : `NSObject`

```objc
+ (void)registerChatMessageCellClassForTableView:(UITableView *)tableView;
```

#### `CYLChat.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLChat.h`

**Macros**: `CYLChat_h`

#### `CYLChatUntiles.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLChatUntiles.h`

**Constants and functions**

```objc
static NSString *const kCYLMessageConfigurationTypeKey = @"com.LeanCloud.kCYLMessageConfigurationTypeKey";
static NSString *const kCYLMessageConfigurationOwnerKey = @"com.LeanCloud.kCYLMessageConfigurationOwnerKey";
static NSString *const kCYLMessageConfigurationGroupKey = @"com.LeanCloud.kCYLMessageConfigurationGroupKey";
static NSString *const kCYLMessageConfigurationNicknameKey = @"com.LeanCloud.kCYLMessageConfigurationNicknameKey";
static NSString *const kCYLMessageConfigurationAvatorKey = @"com.LeanCloud.kCYLMessageConfigurationAvatorKey";
static NSString *const kCYLMessageConfigurationReadStateKey = @"com.LeanCloud.kCYLMessageConfigurationReadStateKey";
static NSString *const kCYLMessageConfigurationSendStateKey = @"com.LeanCloud.kCYLMessageConfigurationSendStateKey";
static NSString *const kCYLMessageConfigurationTextKey = @"com.LeanCloud.kCYLMessageConfigurationTextKey";
static NSString *const kCYLMessageConfigurationImageKey = @"com.LeanCloud.kCYLMessageConfigurationImageKey";
static NSString *const kCYLMessageConfigurationVoiceKey = @"com.LeanCloud.kCYLMessageConfigurationVoiceKey";
static NSString *const kCYLMessageConfigurationVoiceSecondsKey = @"com.LeanCloud.kCYLMessageConfigurationVoiceSecondsKey";
static NSString *const kCYLMessageConfigurationLocationKey = @"com.LeanCloud.kCYLMessageConfigurationLocationKey";
```

**Macros**: `CYLChatUntiles_h`

#### `CYLFaceManager.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLFaceManager.h`

**Class `CYLFaceManager`** : `NSObject`

```objc
+ (instancetype)shareInstance;
+ (NSArray *)emojiFaces;
@property (strong, nonatomic, readonly) NSMutableArray *emojiFaceArrays;
+ (UIImage *)faceImageWithFaceID:(NSUInteger)faceID;
+ (NSString *)faceNameWithFaceID:(NSUInteger)faceID;
+ (NSMutableAttributedString *)emotionStrWithString:(NSString *)text;
+ (void)configEmotionWithMutableAttributedString:(NSMutableAttributedString *)attributeString;
+ (NSArray *)recentFaces;
+ (BOOL)saveRecentFace:(NSDictionary *)dict;
```

**Macros**: `kFaceIDKey`, `kFaceNameKey`, `kFaceImageNameKey`, `kFaceRankKey`, `kFaceClickKey`

#### `CYLLastMessageTypeManager.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLLastMessageTypeManager.h`

**Class `CYLLastMessageTypeManager`** : `NSObject`

```objc
+ (NSAttributedString *)attributedStringWithMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation userName:(NSString *)userName;
```

#### `CYLLocationManager.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLLocationManager.h`

**Class `CYLLocationManager`** : `NSObject`

```objc
@property (nonatomic,strong) void(^locationCompleteBlock)(CLLocationCoordinate2D coordinate2D);
@property (assign, nonatomic, readonly) CLLocationDegrees longitude;
@property (assign, nonatomic, readonly) CLLocationDegrees latitude;
+ (instancetype)shareManager;
- (void)requestAuthorization;
- (void)startLocation;
- (void)stopLocation;
- (void)geocode:(NSString *)address success:(void(^)(CLPlacemark *pm))success failure:(void(^)())failure;
- (void)reverseGeocodeWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D success:(void(^)(NSArray *placemarks))success failure:(void(^)())failure;
- (double)systemDistanceWithEndCoordinate2D:(CLLocationCoordinate2D)endCoordinate2D fromStartCoordinate2D:(CLLocationCoordinate2D)startCoordinate2D;
- (double)customDistanceWithEndCoordinate2D:(CLLocationCoordinate2D)endCoordinate2D fromStartCoordinate2D:(CLLocationCoordinate2D)startCoordinate2D;
```

#### `CYLMessageVoiceFactory.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLMessageVoiceFactory.h`

**Class `CYLMessageVoiceFactory`** : `NSObject`

```objc
+ (UIImageView *)messageVoiceAnimationImageViewWithBubbleMessageType:(CYLMessageOwnerType)owner;
```

#### `CYLSoundManager.h`

Path: `ChatKit/Class/Module/Conversation/Tool/CYLSoundManager.h`

**Class `CYLSoundManager`** : `NSObject`

```objc
+ (instancetype)defaultManager;
@property (nonatomic, assign) BOOL needVibrateWhenNotChatting;
@property (nonatomic, assign) BOOL needPlaySoundWhenNotChatting;
@property (nonatomic, assign) BOOL needPlaySoundWhenChatting;
- (void)playSendSoundIfNeed;
- (void)playReceiveSoundIfNeed;
- (void)playLoudReceiveSoundIfNeed;
- (void)vibrateIfNeed;
```

#### `NSBundle+CYLExtension.h`

Path: `ChatKit/Class/Module/Conversation/Tool/Categories/NSBundle+CYLExtension.h`

**Category `NSBundle (CYLExtension)`**

```objc
+ (NSString *)cyl_bundlePathForbundleName:(NSString *)bundleName class:(Class)aClass;
+ (NSBundle *)cyl_bundleForbundleName:(NSString *)bundleName class:(Class)aClass;
```

#### `NSString+CYLMD5.h`

Path: `ChatKit/Class/Module/Conversation/Tool/Categories/NSString+CYLMD5.h`

**Category `NSString (CYLMD5)`**

```objc
- (NSString *)cyl_MD5String;
```

#### `UIImage+CYLExtension.h`

Path: `ChatKit/Class/Module/Conversation/Tool/Categories/UIImage+CYLExtension.h`

**Category `UIImage (CYLExtension)`**

```objc
- (UIImage *)cyl_imageByScalingAspectFill;
- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize;
- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize limitSize:(CGSize)limitSize;
+ (UIImage *)cyl_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass;
```

#### `UIImageView+CYLExtension.h`

Path: `ChatKit/Class/Module/Conversation/Tool/Categories/UIImageView+CYLExtension.h`

**Category `UIImageView (CYLExtension)`**

```objc
- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;
- (void)cyl_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;
- (instancetype)initWithRoundingRectImageView;
- (void)cyl_cornerRadiusRoundingRect;
- (void)cyl_attachBorderWidth:(CGFloat)width color:(UIColor *)color;
```

#### `CYLImageManager.h`

Path: `ChatKit/Class/Module/Conversation/Tool/DisableImageMemoryCache/CYLImageManager.h`

**Class `CYLImageManager`** : `NSObject`

```objc
+ (instancetype)defaultManager;
- (UIImage *)getImageWithName:(NSString *)name;
- (UIImage *)getImageWithName:(NSString *)name inBundle:(NSBundle *)bundle;
```

#### `CYLWeakReference.h`

Path: `ChatKit/Class/Module/Conversation/Tool/DisableImageMemoryCache/CYLWeakReference.h`

**Typedefs**

```objc
typedef id (^CYLWeakReference)(void);
```

#### `NSBundle+CYLSCaleArray.h`

Path: `ChatKit/Class/Module/Conversation/Tool/DisableImageMemoryCache/NSBundle+CYLSCaleArray.h`

**Category `NSBundle (CYLSCaleArray)`**

```objc
+ (NSArray *)cyl_scaleArray;
```

#### `NSMutableDictionary+CYLWeakReference.h`

Path: `ChatKit/Class/Module/Conversation/Tool/DisableImageMemoryCache/NSMutableDictionary+CYLWeakReference.h`

**Category `NSMutableDictionary (CYLWeakReference)`**

```objc
- (void)cyl_weak_setObject:(id)anObject forKey:(NSString *)aKey;
- (void)cyl_weak_setObjectWithDictionary:(NSDictionary *)dic;
- (id)cyl_weak_getObjectForKey:(NSString *)key;
```

#### `NSString+CYLAddScale.h`

Path: `ChatKit/Class/Module/Conversation/Tool/DisableImageMemoryCache/NSString+CYLAddScale.h`

**Category `NSString (CYLAddScale)`**

```objc
- (NSString *)cyl_stringByAppendingScale:(CGFloat)scale;
```

#### `CYLConversationNavigationTitleView.h`

Path: `ChatKit/Class/Module/Conversation/View/CYLConversationNavigationTitleView.h`

**Class `CYLConversationNavigationTitleView`** : `UIView`

```objc
- (instancetype)initWithConversation:(id<CYLConversationProtocol>)conversation navigationController:(UINavigationController *)navigationController;
```

#### `CYLMenuItem.h`

Path: `ChatKit/Class/Module/Conversation/View/CYLMenuItem.h`

**Class `CYLMenuItem`** : `UIMenuItem`

```objc
- (id)initWithTitle:(NSString *)title block:(void(^)())block;
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;
@property(nonatomic, copy) void(^block)();
+ (void)installMenuHandlerForObject:(id)object;
```

#### `AGEmojiKeyBoardView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/AGEmojiKeyboard/AGEmojiKeyBoardView.h`

**Class `AGEmojiKeyboardView`** : `UIView`

```objc
@property (nonatomic, readonly) UISegmentedControl *segmentsBar;
@property (nonatomic, readonly) UIPageControl *pageControl;
@property (nonatomic, readonly) UIScrollView *emojiPagesScrollView;
@property (nonatomic, weak) id<AGEmojiKeyboardViewDelegate> delegate;
@property (nonatomic, weak) id<AGEmojiKeyboardViewDataSource> dataSource;
- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource;
```

**Protocol `AGEmojiKeyboardViewDataSource`** adopts &lt;NSObject&gt;

```objc
@required
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;
- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category;
- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;
@optional
- (AGEmojiKeyboardViewCategoryImage)defaultCategoryForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;
- (NSUInteger)recentEmojisMaintainedCountForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView;
```

**Protocol `AGEmojiKeyboardViewDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji;
- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView;
```

**Enums**

- `AGEmojiKeyboardViewCategoryImage` (`NSInteger`): `AGEmojiKeyboardViewCategoryImageRecent`, `AGEmojiKeyboardViewCategoryImageFace`, `AGEmojiKeyboardViewCategoryImageBell`, `AGEmojiKeyboardViewCategoryImageFlower`, `AGEmojiKeyboardViewCategoryImageCar`, `AGEmojiKeyboardViewCategoryImageCharacters`

#### `AGEmojiPageView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/AGEmojiKeyboard/AGEmojiPageView.h`

**Class `AGEmojiPageView`** : `UIView`

```objc
@property (nonatomic, assign) id<AGEmojiPageViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame backSpaceButtonImage:(UIImage *)backSpaceButtonImage buttonSize:(CGSize)buttonSize rows:(NSUInteger)rows columns:(NSUInteger)columns;
- (void)setButtonTexts:(NSMutableArray *)buttonTexts;
```

**Protocol `AGEmojiPageViewDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)emojiPageView:(AGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji;
- (void)emojiPageViewDidPressBackSpace:(AGEmojiPageView *)emojiPageView;
```

#### `CYLChatBar.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLChatBar.h`

**Class `CYLChatBar`** : `UIView`

```objc
@property (weak, nonatomic) id<CYLChatBarDelegate> delegate;
@property (nonatomic, readonly) UIViewController *controllerRef;
@property (copy, nonatomic) NSString *cachedText;
@property (nonatomic, assign) CYLFunctionViewShowType showType;
@property (strong, nonatomic) UITextView *textView;
- (void)close;
- (void)open;
- (void)appendString:(NSString *)string;
- (void)appendString:(NSString *)string beginInputing:(BOOL)beginInputing;
- (void)appendString:(NSString *)string mentionList:(NSArray<NSString *> *)mentionList;
- (void)endInputing;
- (void)beginInputing;
```

**Protocol `CYLChatBarDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)chatBarFrameDidChange:(CYLChatBar *)chatBar shouldScrollToBottom:(BOOL)shouldScrollToBottom;
- (void)chatBar:(CYLChatBar *)chatBar sendPictures:(NSArray *)pictures;
- (void)chatBar:(CYLChatBar *)chatBar sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *)locationText;
- (void)chatBar:(CYLChatBar *)chatBar sendMessage:(NSString *)message mentionList:(NSArray<NSString *> *)mentionList;
- (void)chatBar:(CYLChatBar *)chatBar sendVoice:(NSString *)voiceFileName seconds:(NSTimeInterval)seconds;
- (void)didInputAtSign:(CYLChatBar *)chatBar;
- (NSArray *)regulationForBatchDeleteText;
```

**Enums**

- `CYLFunctionViewShowType` (`NSUInteger`): `CYLFunctionViewShowNothing`, `CYLFunctionViewShowFace`, `CYLFunctionViewShowVoice`, `CYLFunctionViewShowMore`, `CYLFunctionViewShowKeyboard`

**Constants and functions**

```objc
static CGFloat const CYLChatBarBottomOffset = 8.f;
static CGFloat const CYLChatBarTextViewBottomOffset = 6 * 2;
static CGFloat const kCYLChatBarTextViewFrameMinHeight = 37.f;
static CGFloat const kCYLChatBarTextViewFrameMaxHeight = 102.f;
static CGFloat const kCYLChatBarMaxHeight = kCYLChatBarTextViewFrameMaxHeight + 2*CYLChatBarTextViewBottomOffset;
static CGFloat const kCYLChatBarMinHeight = kCYLChatBarTextViewFrameMinHeight + 2*CYLChatBarTextViewBottomOffset;
FOUNDATION_EXTERN NSString *const kCYLBatchDeleteTextPrefix;
FOUNDATION_EXTERN NSString *const kCYLBatchDeleteTextSuffix;
```

#### `CYLChatFaceView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLChatFaceView.h`

**Class `CYLChatFaceView`** : `UIView`

```objc
@property (weak, nonatomic) id<CYLChatFaceViewDelegate> delegate;
@property (assign, nonatomic) CYLShowFaceViewType faceViewType;
```

**Protocol `CYLChatFaceViewDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)faceViewSendFace:(NSString *)faceName;
```

**Enums**

- `CYLShowFaceViewType` (`NSUInteger`): `CYLShowEmojiFace`, `CYLShowRecentFace`, `CYLShowGifFace`

**Macros**: `kCYLTopLineBackgroundColor`

#### `CYLChatMoreItem.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLChatMoreItem.h`

**Class `CYLChatMoreItem`** : `UIControl`

```objc
- (void)fillViewWithTitle:(NSString *)title imageName:(NSString *)imageName;
```

#### `CYLChatMoreView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLChatMoreView.h`

**Class `CYLChatMoreView`** : `UIView`

```objc
@property (assign, nonatomic) NSUInteger numberPerLine;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@property (weak, nonatomic) CYLChatBar *inputViewRef;
```

**Constants and functions**

```objc
static CGFloat const kFunctionViewHeight = 210.0f;
```

#### `CYLFacePageView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLFacePageView.h`

**Class `CYLFacePageView`** : `UIView`

```objc
@property (nonatomic, assign) NSUInteger columnsPerRow;
@property (nonatomic, copy) NSArray *datas;
@property (nonatomic, weak) id<CYLFacePageViewDelegate> delegate;
```

**Protocol `CYLFacePageViewDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)selectedFaceImageWithFaceID:(NSUInteger)faceID;
```

#### `CYLInputViewPlugin.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLInputViewPlugin.h`

**Class `CYLInputViewPlugin`** : `UIControl` &lt;CYLInputViewPluginDelegate&gt;

```objc
@property (nonatomic, readonly) CYLInputViewPluginType pluginType;
@property (nonatomic, readonly) CYLConversationViewController *conversationViewController;
- (void)fillWithPluginTitle:(NSString *)pluginTitle pluginIconImage:(UIImage *)pluginIconImage;
+ (void)registerSubclass;
+ (void)registerCustomInputViewPlugin;
```

**Protocol `CYLInputViewPluginSubclassing`** adopts &lt;NSObject&gt;

```objc
+ (CYLInputViewPluginType)classPluginType;
```

**Protocol `CYLInputViewPluginDelegate`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, weak) CYLChatBar *inputViewRef;
@property (nonatomic, readonly, strong) UIImage *pluginIconImage;
@property (nonatomic, readonly, copy) NSString *pluginTitle;
@property (nonatomic, readonly, strong) UIView *pluginContentView;
@property (nonatomic, weak) id<CYLInputViewPluginDelegate> delegate;
@property (nonatomic, copy) CYLIdResultBlock sendCustomMessageHandler;
- (void)pluginDidClicked;
```

#### `CYLInputViewPluginLocation.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLInputViewPluginLocation.h`

**Class `CYLInputViewPluginLocation`** : `CYLInputViewPlugin` &lt;CYLInputViewPluginSubclassing&gt;

```objc
@property (nonatomic, weak) CYLChatBar *inputViewRef;
```

#### `CYLInputViewPluginPickImage.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLInputViewPluginPickImage.h`

**Class `CYLInputViewPluginPickImage`** : `CYLInputViewPlugin` &lt;CYLInputViewPluginSubclassing&gt;

```objc
@property (nonatomic, weak) CYLChatBar *inputViewRef;
```

#### `CYLInputViewPluginTakePhoto.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLInputViewPluginTakePhoto.h`

**Class `CYLInputViewPluginTakePhoto`** : `CYLInputViewPlugin` &lt;CYLInputViewPluginSubclassing&gt;

```objc
@property (nonatomic, weak) CYLChatBar *inputViewRef;
```

#### `CYLProgressHUD.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLProgressHUD.h`

**Class `CYLProgressHUD`** : `UIView`

```objc
+ (NSTimeInterval)seconds;
+ (void)show;
+ (void)dismissWithMessage:(NSString *)message;
+ (void)dismissWithProgressState:(CYLProgressState)progressState;
+ (void)changeSubTitle:(NSString *)str;
+ (void)realtimeChangeVolumeImageView:(float)volume timeLength:(NSTimeInterval)timeLength;
```

**Enums**

- `CYLProgressState` (`NSUInteger`): `CYLProgressSuccess`, `CYLProgressError`, `CYLProgressShort`, `CYLProgressOverTime`, `CYLProgressMessage`

#### `CYLRecordAudioHUD.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatBar/CYLRecordAudioHUD.h`

**Class `CYLRecordAudioHUD`** : `UIView`

```objc
@property (nonatomic, assign, readonly, getter=isShowing) BOOL showing;
+ (CYLRecordAudioHUD *)instance;
+ (void)show;
+ (void)dismissWithState:(CYLRecordResultState)resultState;
+ (void)changeProgressState:(CYLRecordProgressState)progressState;
+ (void)changeVolume:(NSInteger)level;
+ (NSInteger)seconds;
```

**Enums**

- `CYLRecordResultState` (`NSUInteger`): `CYLRecoderResultStateSuccess`, `CYLRecoderResultStateFail`, `CYLRecoderResultStateShort`, `CYLRecoderResultStateLong`, `CYLRecoderResultStateCancel`
- `CYLRecordProgressState` (`NSUInteger`): `CYLRecordProgressStateOutSide`, `CYLRecordProgressStateInSide`

**Macros**: `kCYLRecordAudioTooLong`

#### `CYLChatImageMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatImageMessageCell.h`

**Class `CYLChatImageMessageCell`** : `CYLChatMessageCell` &lt;CYLChatMessageCellSubclassing&gt;

```objc
@property (nonatomic, strong, readonly) UIImageView *messageImageView;
- (void)setUploadProgress:(CGFloat)uploadProgress;
```

#### `CYLChatLocationMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatLocationMessageCell.h`

**Class `CYLChatLocationMessageCell`** : `CYLChatMessageCell` &lt;CYLChatMessageCellSubclassing&gt;

#### `CYLChatMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatMessageCell.h`

**Class `CYLChatMessageCell`** : `UITableViewCell`

```objc
+ (void)registerCustomMessageCell;
+ (void)registerSubclass;
- (void)addGeneralView;
@property (nonatomic, strong) CYLMessage *message;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) UIImageView *officialSignImageView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) CYLContentView *messageContentView;
@property (nonatomic, strong) UIImageView *messageReadStateImageView;
@property (nonatomic, strong) CYLMessageSendStateView *messageSendStateView;
@property (nonatomic, strong) UIImageView *messageContentBackgroundImageView;
@property (nonatomic, weak) id<CYLChatMessageCellDelegate> delegate;
@property (nonatomic, assign, readonly) CYLMessageMediaType mediaType;
@property (nonatomic, assign, readonly) CYLMessageOwnerType messageOwner;
@property (nonatomic, assign) CYLConversationType messageChatType;
@property (nonatomic, assign) CYLMessageSendState messageSendState;
@property (nonatomic, assign) CYLMessageReadState messageReadState;
@property (nonatomic, strong) UIColor *conversationViewMessageLeftTextColor;
@property (nonatomic, strong) UIColor *conversationViewMessageRightTextColor;
- (void)setup;
- (void)configureCellWithData:(id)message;
```

**Protocol `CYLChatMessageCellSubclassing`** adopts &lt;NSObject&gt;

```objc
+ (CYLMessageMediaType)classMediaType;
```

**Protocol `CYLChatMessageCellDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)messageCellTappedBlank:(CYLChatMessageCell *)messageCell;
- (void)messageCellTappedHead:(CYLChatMessageCell *)messageCell;
- (void)messageCellTappedMessage:(CYLChatMessageCell *)messageCell;
- (void)textMessageCellDoubleTapped:(CYLChatMessageCell *)messageCell;
- (void)resendMessage:(CYLChatMessageCell *)messageCell;
- (void)avatarImageViewLongPressed:(CYLChatMessageCell *)messageCell;
- (void)messageCell:(CYLChatMessageCell *)messageCell didTapLinkText:(NSString *)linkText linkType:(MLLinkType)linkType;
- (void)fileMessageDidDownload:(CYLChatMessageCell *)messageCell;
- (void)modifyMessage:(CYLChatMessageCell *)messageCell newMessage:(CYLMessage *)newMessage callback:(void (^)(BOOL, NSError *))callback;
- (void)recallMessage:(CYLChatMessageCell *)messageCell callback:(void (^)(BOOL, NSError *))callback;
```

#### `CYLChatSystemMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatSystemMessageCell.h`

**Class `CYLChatSystemMessageCell`** : `CYLChatMessageCell` &lt;CYLChatMessageCellSubclassing&gt;

#### `CYLChatTextMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatTextMessageCell.h`

**Class `CYLChatTextMessageCell`** : `CYLChatMessageCell` &lt;CYLChatMessageCellSubclassing&gt;

**Macros**: `kCYLMessageTextColor`, `kT1TextHighlightedBackgroundColor`, `kT1TextHighlightedColor`

#### `CYLChatVoiceMessageCell.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLChatVoiceMessageCell.h`

**Class `CYLChatVoiceMessageCell`** : `CYLChatMessageCell` &lt;CYLChatMessageCellSubclassing&gt;

```objc
@property (nonatomic, assign) CYLVoiceMessageState voiceMessageState;
```

#### `CYLContentView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLContentView.h`

**Class `CYLContentView`** : `UIView`

#### `CYLMessageSendStateView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLMessageSendStateView.h`

**Class `CYLMessageSendStateView`** : `UIButton`

```objc
@property (nonatomic, assign) CYLMessageSendState messageSendState;
@property (nonatomic, weak) id<CYLSendImageViewDelegate> delegate;
```

**Protocol `CYLSendImageViewDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)resendMessage:(id)sender;
```

#### `CYLSendImageView.h`

Path: `ChatKit/Class/Module/Conversation/View/ChatMessageCell/CYLSendImageView.h`

**Class `CYLSendImageView`** : `UIImageView`

```objc
@property (nonatomic, assign) CYLMessageSendState messageSendState;
```

### Module: ConversationList

#### `CYLConversationListViewController.h`

Path: `ChatKit/Class/Module/ConversationList/Controller/CYLConversationListViewController.h`

**Class `CYLConversationListViewController`** : `CYLChatBaseTableViewController`

```objc
@property (nonatomic, weak) id<CYLConversationListViewControllerDelegate> delegate;
@property (nonatomic, strong) UIView *placeHolderView;
- (void)refresh;
```

**Protocol `CYLConversationListViewControllerDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)conversation:(id<CYLConversationProtocol>)conversation tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)conversation:(id<CYLConversationProtocol>)conversation cell:(UITableViewCell *)cell tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN const CGFloat CYLConversationListCellDefaultHeight;
```

#### `CYLConversationListViewModel.h`

Path: `ChatKit/Class/Module/ConversationList/Model/CYLConversationListViewModel.h`

**Class `CYLConversationListViewModel`** : `NSObject` &lt;UITableViewDelegate, UITableViewDataSource&gt;

```objc
- (instancetype)initWithConversationListViewController:(CYLConversationListViewController *)conversationListViewController;
@property (nonatomic, strong) NSMutableArray<id<CYLConversationProtocol>> *dataArray;
- (void)refresh;
```

#### `CYLConversationListCell.h`

Path: `ChatKit/Class/Module/ConversationList/View/CYLConversationListCell.h`

**Class `CYLConversationListCell`** : `UITableViewCell`

```objc
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *officialSignImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *messageTextLabel;
@property (nonatomic, strong) CYLBadgeView *badgeView;
@property (nonatomic, strong) UIView *litteBadgeView;
@property (nonatomic, strong) UILabel *timestampLabel;
@property (nonatomic, strong) UIButton *remindMuteImageView;
@property (nonatomic, copy) NSString *clientId;
@property (nonatomic, copy) NSString *identifier;
+ (instancetype)dequeueOrCreateCellByTableView:(UITableView *)tableView;
+ (void)registerCellToTableView:(UITableView *)tableView;
```

### Tool

#### `CYLChatConstants.h`

Path: `ChatKit/Class/Tool/CYLChatConstants.h`

**Enums**

- `CYLMessageMediaType` (`int8_t`): `CYLMessageMediaTypeNone`, `CYLMessageMediaTypeText`, `CYLMessageMediaTypeImage`, `CYLMessageMediaTypeAudio`, `CYLMessageMediaTypeVideo`, `CYLMessageMediaTypeLocation`, `CYLMessageMediaTypeFile`, `CYLMessageMediaTypeSystem`, `CYLMessageMediaTypeRecalled`
- `CYLIMErrorCode` (`NSInteger`): `CYLIMErrorCodeConnectionLost`
- `CYLConversationType` (`NSUInteger`): `CYLConversationTypeSingle`, `CYLConversationTypeGroup`
- `CYLMessageOwnerType` (`NSUInteger`): `CYLMessageOwnerTypeUnknown`, `CYLMessageOwnerTypeSystem`, `CYLMessageOwnerTypeSelf`, `CYLMessageOwnerTypeOther`
- `CYLMessageSendState` (`NSUInteger`): `CYLMessageSendStateNone`, `CYLMessageSendStateSending`, `CYLMessageSendStateSent`, `CYLMessageSendStateDelivered`, `CYLMessageSendStateFailed`, `CYLMessageSendStateRead`
- `CYLMessageReadState` (`NSUInteger`): `CYLMessageUnRead`, `CYLMessageReading`, `CYLMessageReaded`
- `CYLVoiceMessageState` (`NSUInteger`): `CYLVoiceMessageStateNormal`, `CYLVoiceMessageStateDownloading`, `CYLVoiceMessageStatePlaying`, `CYLVoiceMessageStateCancel`
- `CYLChatMessageCellMenuActionType` (`NSUInteger`): `CYLChatMessageCellMenuActionTypeCopy`, `CYLChatMessageCellMenuActionTypeRelay`
- `CYLInputViewPluginType` (`NSUInteger`): `CYLInputViewPluginTypeDefault`, `CYLInputViewPluginTypeTakePhoto`, `CYLInputViewPluginTypePickImage`, `CYLInputViewPluginTypeLocation`, `CYLInputViewPluginTypeShortVideo`
- `CYLBubbleMessageMenuSelectedType` (`NSInteger`): `CYLBubbleMessageMenuSelectedTypeTextCopy`, `CYLBubbleMessageMenuSelectedTypeTextTranspond`, `CYLBubbleMessageMenuSelectedTypeTextFavorites`, `CYLBubbleMessageMenuSelectedTypeTextMore`, `CYLBubbleMessageMenuSelectedTypePhotoCopy`, `CYLBubbleMessageMenuSelectedTypePhotoTranspond`, `CYLBubbleMessageMenuSelectedTypePhotoFavorites`, `CYLBubbleMessageMenuSelectedTypePhotoMore`, `CYLBubbleMessageMenuSelectedTypeVideoTranspond`, `CYLBubbleMessageMenuSelectedTypeVideoFavorites`, `CYLBubbleMessageMenuSelectedTypeVideoMore`, `CYLBubbleMessageMenuSelectedTypeVoicePlay`, `CYLBubbleMessageMenuSelectedTypeVoiceFavorites`, `CYLBubbleMessageMenuSelectedTypeVoiceTurnToText`, `CYLBubbleMessageMenuSelectedTypeVoiceMore`
- `CYLMessageNotificationType` (`enum`): `CYLMessageNotificationTypeMessage`, `CYLMessageNotificationTypeWarning`, `CYLMessageNotificationTypeError`, `CYLMessageNotificationTypeSuccess`
- `CYLMessageHUDActionType` (`enum`): `CYLMessageHUDActionTypeShow`, `CYLMessageHUDActionTypeHide`, `CYLMessageHUDActionTypeError`, `CYLMessageHUDActionTypeSuccess`
- `CYLScrollDirection` (`enum`): `CYLScrollDirectionNone`, `CYLScrollDirectionRight`, `CYLScrollDirectionLeft`, `CYLScrollDirectionUp`, `CYLScrollDirectionDown`, `CYLScrollDirectionCrazy`

**Typedefs**

```objc
typedef void (^CYLUserResultsCallBack)(NSArray<id<CYLUserDelegate>> *users, NSError *error);
typedef void (^CYLUserResultCallBack)(id<CYLUserDelegate> user, NSError *error);
typedef void (^CYLBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^CYLViewControllerBooleanResultBlock)(__kindof UIViewController *viewController, BOOL succeeded, NSError *error);
typedef void (^CYLIntegerResultBlock)(NSInteger number, NSError *error);
typedef void (^CYLStringResultBlock)(NSString *string, NSError *error);
typedef void (^CYLDictionaryResultBlock)(NSDictionary * dict, NSError *error);
typedef void (^CYLArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^CYLSetResultBlock)(NSSet *channels, NSError *error);
typedef void (^CYLDataResultBlock)(NSData *data, NSError *error);
typedef void (^CYLIdResultBlock)(id object, NSError *error);
typedef void (^CYLIdBoolResultBlock)(BOOL succeeded, id object, NSError *error);
typedef void (^CYLRequestAuthorizationBoolResultBlock)(BOOL granted, NSError *error);
typedef void (^CYLVoidBlock)(void);
typedef void (^CYLErrorBlock)(NSError *error);
typedef void (^CYLImageResultBlock)(UIImage * image, NSError *error);
typedef void (^CYLProgressBlock)(NSInteger percentDone);
```

**Constants and functions**

```objc
static CGFloat const CYLAvatarToMessageContent = 5.f;
static CGFloat const CYLAvatarBottomToMessageContentTop = -1.f;
static CGFloat const CYL_MSG_CELL_EDGES_OFFSET = 16;
static NSInteger const CYL_iPHONEX_OFFSET = 34;
static NSString *const CYLBadgeTextForNumberGreaterThanLimit = @"···";
static NSString * const CYLNotificationSessionResumed = @"CYLNotificationSessionResumed";
static NSString *const CYLNotificationUnreadsUpdated = @"CYLNotificationUnreadsUpdated";
static NSString *const CYLNotificationMessageReceived = @"CYLNotificationMessageReceived";
static NSString *const CYLNotificationMessageUpdated = @"CYLNotificationMessageUpdated";
static NSString *const CYLNotificationMessageSent = @"CYLNotificationMessageSent";
static NSString *const CYLNotificationCustomMessageReceived = @"CYLNotificationCustomMessageReceived";
static NSString *const CYLNotificationCustomTransientMessageReceived = @"CYLNotificationCustomTransientMessageReceived";
static NSString *const CYLNotificationMessageDelivered = @"CYLNotificationMessageDelivered";
static NSString *const CYLNotificationMessageRead = @"CYLNotificationMessageRead";
static NSString *const CYLNotificationConversationUpdated = @"CYLNotificationConversationUpdated";
static NSString *const CYLNotificationConnectivityUpdated = @"CYLNotificationConnectivityUpdated";
static NSString *const CYLNotificationCurrentConversationInvalided = @"CYLNotificationCurrentConversationInvalided";
static NSString *const CYLNotificationConversationViewControllerBackgroundImageDidChanged = @"CYLNotificationConversationViewControllerBackgroundImageDidChanged";
static NSString *const CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey = @"CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey";
static NSString *const CYLNotificationConversationInvalided = @"CYLNotificationConversationInvalided";
static NSString *const CYLNotificationConversationListDataSourceUpdated = @"CYLNotificationConversationListDataSourceUpdated";
static NSString *const CYLNotificationContactListDataSourceUpdated = @"CYLNotificationContactListDataSourceUpdated";
static NSString *const CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceKey = @"CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceKey";
static NSString *const CYLNotificationContactListDataSourceUserIdType = @"CYLNotificationContactListDataSourceUserIdType";
static NSString *const CYLNotificationContactListDataSourceContactObjType = @"CYLNotificationContactListDataSourceContactObjType";
static NSString *const CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey = @"CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey";
static NSString *const CYLNotificationConversionImageMessageDidDownloaded = @"CYLNotificationConversionImageMessageDidDownloaded";
static NSString *const CYLNotificationRecordNoPower = @"CYLChatBarRecordVoiceNoPower";
static NSString *const CYLNotificationTextLengthOut = @"CYLChatBarTextLengthOut";
static NSString *const CYLNotificationRecordTimeOut = @"CYLChatBarRecordVoiceTimeOut";
static NSInteger const CYLNotificationTextLengthOutLength = 1000;
static CYLMessageMediaType const kCYLIMMessageMediaTypeSystem = CYLMessageMediaTypeSystem;
static CGFloat const kCYLVolumeMaxTimeLength = 60;
static NSInteger const kCYLOnePageSize = 10;
static NSString *const CYL_CONVERSATION_TYPE = @"type";
static NSString *const CYLInstallationKeyChannels = @"channels";
static NSString *const CYLMessageNotifacationUserInfoConversationKey = @"conversation";
static NSString *const CYLDidReceiveMessagesUserInfoMessagesKey = @"receivedMessages";
static NSString *const CYLDidReceiveCustomMessageUserInfoMessageKey = @"receivedCustomMessage";
static NSString *const CYLMessageNotifacationUserInfoMessageKey = @"message";
static NSString *const CYLCustomMessageDegradeKey = @"degrade";
static NSString *const CYLCustomMessageTypeTitleKey = @"typeTitle";
static NSString *const CYLCustomMessageSummaryKey = @"summary";
static NSString *const CYLCustomMessageIsCustomKey = @"isCustom";
static NSString *const CYLCustomMessageOnlyVisiableForPartClientIds = @"OnlyVisiableForPartClientIds";
static NSString *const CYLCustomMessageConversationTypeKey = @"conversationType";
FOUNDATION_EXTERN NSMutableDictionary const * CYLChatMessageCellMediaTypeDict;
static NSString *const CYLCellIdentifierDefault = @"CYLCellIdentifierDefault";
static NSString *const CYLCellIdentifierCustom = @"CYLCellIdentifierCustom";
static NSString *const CYLCellIdentifierGroup = @"CYLCellIdentifierGroup";
static NSString *const CYLCellIdentifierSingle = @"CYLCellIdentifierSingle";
static NSString *const CYLCellIdentifierOwnerSelf = @"CYLCellIdentifierOwnerSelf";
static NSString *const CYLCellIdentifierOwnerOther = @"CYLCellIdentifierOwnerOther";
static NSString *const CYLCellIdentifierOwnerSystem = @"CYLCellIdentifierOwnerSystem";
FOUNDATION_EXTERN NSMutableDictionary const * CYLInputViewPluginDict;
FOUNDATION_EXTERN NSMutableArray const * CYLInputViewPluginArray;
static NSString *const CYLInputViewPluginTypeKey = @"CYLInputViewPluginTypeKey";
static NSString *const CYLInputViewPluginClassKey = @"CYLInputViewPluginClassKey";
static NSString *const CYLCustomConversationViewControllerBackgroundImageNamePrefix = @"CONVERSATION_BACKGROUND_";
static NSString *const CYLDefaultConversationViewControllerBackgroundImageName = @"CONVERSATION_BACKGROUND_ALL";
static CGFloat const CYLAnimateDuration = .25f;
```

**Macros**: `CYL_STATUSBAR_HEIGHT`, `CYL_IS_iPHONEX`, `CYL_DEPRECATED(explain)`, `CYLLocalizedStrings(key)`, `CYLLog(fmt, ...)`, `CYLLog(...)`, `XCODE_VERSION_GREATER_THAN_OR_EQUAL_TO_8`, `SYSTEM_VERSION_EQUAL_TO(v)`, `SYSTEM_VERSION_GREATER_THAN(v)`, `SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)`, `SYSTEM_VERSION_LESS_THAN(v)`, `SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)`, `CYL_CURRENT_TIMESTAMP`, `CYL_FUTURE_TIMESTAMP`, `CYL_TIMESTAMP_REGEX`, `CYLConversationGroupAvatarURLKey`, `CYL_CURRENT_CONVERSATIONVIEWCONTROLLER_OBJECT`, `CYLMessageCellLimit`, `CYL_STRETCH_IMAGE(image, edgeInsets)`, `CYL_CONVERSATIONVIEWCONTROLLER_BACKGROUNDCOLOR`, `CYLConversationTableName`, `CYLConversationTableKeyId`, `CYLConversationTableKeyData`, `CYLConversationTableKeyUnreadCount`, `CYLConversationTableKeyMentioned`, `CYLConversationTableKeyDraft`, `CYLConversatoinTableCreateSQL`, `CYLConversationTableInsertSQL`, `CYLConversationTableWhereClause`, `CYLConversationTableDeleteSQL`, `CYLDeleteConversationTable`, `CYLConversationTableIncreaseUnreadCountSQL`, `CYLConversationTableIncreaseOneUnreadCountSQL`, `CYLConversationTableUpdateUnreadCountSQL`, `CYLConversationTableUpdateMentionedSQL`, `CYLConversationTableUpdateDraftSQL`, `CYLConversationTableSelectSQL`, `CYLConversationTableSelectDraftSQL`, `CYLConversationTableSelectOneSQL`, `CYLConversationTableUpdateDataSQL`, `CYLFaildMessageTable`, `CYLKeyId`, `CYLKeyConversationId`, `CYLKeyMessage`, `CYLCreateTableSQL`, `CYLWhereConversationId`, `CYLSelectMessagesSQL`, `CYLWhereKeyId`, `CYLSelectMessagesByIDSQL`, `CYLInsertMessageSQL`, `CYLDeleteMessageSQL`

#### `CYLServiceDefinition.h`

Path: `ChatKit/Class/Tool/CYLServiceDefinition.h`

**Protocol `CYLSessionService`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, strong, readonly) id client;
@property (nonatomic, assign) BOOL disableSingleSignOn;
@property (nonatomic, copy) CYLForceReconnectSessionBlock forceReconnectSessionBlock;
- (void)openWithClientId:(NSString *)clientId callback:(CYLBooleanResultBlock)callback;
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(CYLBooleanResultBlock)callback;
- (void)closeWithCallback:(CYLBooleanResultBlock)callback;
- (void)setForceReconnectSessionBlock:(CYLForceReconnectSessionBlock)forceReconnectSessionBlock;
- (void)setMemberInfoChangedBlock:(void (^)(id<CYLConversationProtocol> conversation, NSString *byClientId, NSString *clientId, NSUInteger role))block;
```

**Protocol `CYLUserSystemService`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy) CYLFetchProfilesBlock fetchProfilesBlock;
- (void)setFetchProfilesBlock:(CYLFetchProfilesBlock)fetchProfilesBlock;
- (void)removeAllCachedProfiles;
- (void)removeCachedProfileForPeerId:(NSString *)peerId;
- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL error:(NSError * __autoreleasing *)error;
- (void)getCachedProfileIfExists:(NSString *)userId name:(NSString **)name avatarURL:(NSURL **)avatarURL userTye:(NSInteger *)userType error:(NSError * __autoreleasing *)theError;
- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error;
- (NSArray<id<CYLUserDelegate>> *)getCachedProfilesIfExists:(NSArray<NSString *> *)userIds shouldSameCount:(BOOL)shouldSameCount error:(NSError * __autoreleasing *)theError;
- (void)getProfileInBackgroundForUserId:(NSString *)userId callback:(CYLUserResultCallBack)callback;
- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback;
- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)error;
```

**Protocol `CYLSignatureService`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy) CYLGenerateSignatureBlock generateSignatureBlock;
- (void)setGenerateSignatureBlock:(CYLGenerateSignatureBlock)generateSignatureBlock;
```

**Protocol `CYLUIService`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy) CYLOpenProfileBlock openProfileBlock;
- (void)setOpenProfileBlock:(CYLOpenProfileBlock)openProfileBlock;
@property (nonatomic, copy) CYLPreviewImageMessageBlock previewImageMessageBlock;
- (void)setPreviewImageMessageBlock:(CYLPreviewImageMessageBlock)previewImageMessageBlock;
@property (nonatomic, copy) CYLPreviewLocationMessageBlock previewLocationMessageBlock;
- (void)setPreviewLocationMessageBlock:(CYLPreviewLocationMessageBlock)previewLocationMessageBlock;
@property (nonatomic, copy) CYLLongPressMessageBlock longPressMessageBlock;
- (void)setLongPressMessageBlock:(CYLLongPressMessageBlock)longPressMessageBlock;
@property (nonatomic, copy) CYLShowNotificationBlock showNotificationBlock;
- (void)setShowNotificationBlock:(CYLShowNotificationBlock)showNotificationBlock;
@property (nonatomic, copy) CYLHUDActionBlock HUDActionBlock;
- (void)setHUDActionBlock:(CYLHUDActionBlock)HUDActionBlock;
@property (nonatomic, copy) CYLAvatarImageViewCornerRadiusBlock avatarImageViewCornerRadiusBlock;
- (void)setAvatarImageViewCornerRadiusBlock:(CYLAvatarImageViewCornerRadiusBlock)avatarImageViewCornerRadiusBlock;
```

**Protocol `CYLSettingService`** adopts &lt;NSObject&gt;

```objc
+ (void)setAllLogsEnabled:(BOOL)enabled;
+ (BOOL)allLogsEnabled;
+ (NSString *)ChatKitVersion;
- (void)syncBadge;
@property (nonatomic, assign, getter=isDisablePreviewUserId) BOOL disablePreviewUserId;
@property (nonatomic, assign) BOOL useDevPushCerticate;
- (void)setBackgroundImage:(UIImage *)image forConversationId:(NSString *)conversationId scaledToSize:(CGSize)scaledToSize;
```

**Protocol `CYLConversationService`** adopts &lt;NSObject&gt;

```objc
@property (nonatomic, copy) CYLFetchConversationHandler fetchConversationHandler;
- (void)setFetchConversationHandler:(CYLFetchConversationHandler)fetchConversationHandler;
@property (nonatomic, copy) CYLConversationInvalidedHandler conversationInvalidedHandler;
- (void)setConversationInvalidedHandler:(CYLConversationInvalidedHandler)conversationInvalidedHandler;
- (void)setFilterMessagesBlock:(CYLFilterMessagesBlock)filterMessagesBlock;
@property (nonatomic, copy) CYLFilterMessagesBlock filterMessagesBlock;
- (void)setSendMessageHookBlock:(CYLSendMessageHookBlock)sendMessageHookBlock;
@property (nonatomic, copy) CYLSendMessageHookBlock sendMessageHookBlock;
@property (nonatomic, copy) CYLLoadLatestMessagesHandler loadLatestMessagesHandler;
- (void)setLoadLatestMessagesHandler:(CYLLoadLatestMessagesHandler)loadLatestMessagesHandler;
- (void)createConversationWithMembers:(NSArray *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(CYLConversationResultBlock)callback;
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation;
- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId;
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId;
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId;
- (BOOL)removeAllCachedRecentConversations;
- (void)sendWelcomeMessageToPeerId:(NSString *)peerId text:(NSString *)text block:(CYLBooleanResultBlock)block;
- (void)sendWelcomeMessageToConversationId:(NSString *)conversationId text:(NSString *)text block:(CYLBooleanResultBlock)block;
```

**Protocol `CYLConversationsListService`** adopts &lt;NSObject&gt;

```objc
- (void)setConversationListShowHookBlock:(CYLConversationListShowHookBlock)conversationListShowHookBlock;
@property (nonatomic, copy) CYLConversationListShowHookBlock conversationListShowHookBlock;
@property (nonatomic, copy) CYLDidSelectConversationsListCellBlock didSelectConversationsListCellBlock __deprecated_msg("CYLDidSelectConversationsListCellBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");
- (void)setDidSelectConversationsListCellBlock:(CYLDidSelectConversationsListCellBlock)didSelectConversationsListCellBlock __deprecated_msg("CYLDidSelectConversationsListCellBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");
@property (nonatomic, copy) CYLDidDeleteConversationsListCellBlock didDeleteConversationsListCellBlock;
- (void)setDidDeleteConversationsListCellBlock:(CYLDidDeleteConversationsListCellBlock)didDeleteConversationsListCellBlock;
@property (nonatomic, copy) CYLConversationEditActionsBlock conversationEditActionBlock;
- (void)setConversationEditActionBlock:(CYLConversationEditActionsBlock)conversationEditActionBlock;
@property (nonatomic, copy) CYLMarkBadgeWithTotalUnreadCountBlock markBadgeWithTotalUnreadCountBlock;
- (void)setMarkBadgeWithTotalUnreadCountBlock:(CYLMarkBadgeWithTotalUnreadCountBlock)markBadgeWithTotalUnreadCountBlock;
```

**Typedefs**

```objc
typedef void (^CYLReconnectSessionCompletionHandler)(BOOL succeeded, NSError *error);
typedef void (^CYLForceReconnectSessionBlock)(NSError *error, BOOL granted, __kindof UIViewController *viewController, CYLReconnectSessionCompletionHandler completionHandler);
typedef void(^CYLFetchProfilesCompletionHandler)(NSArray<id<CYLUserDelegate>> *users, NSError *error);
typedef void(^CYLFetchProfilesBlock)(NSArray<NSString *> *userIds, CYLFetchProfilesCompletionHandler completionHandler);
typedef void(^CYLGenerateSignatureCompletionHandler)(id signature, NSError *error);
typedef void(^CYLGenerateSignatureBlock)(NSString *clientId, NSString *conversationId, NSString *action, NSArray *clientIds, CYLGenerateSignatureCompletionHandler completionHandler);
typedef void(^CYLOpenProfileBlock)(NSString *userId, id<CYLUserDelegate> user, __kindof UIViewController *parentController);
typedef void(^CYLPreviewImageMessageBlock)(NSUInteger index, NSArray *allVisibleImages, NSArray *allVisibleThumbs, NSDictionary *userInfo);
typedef void(^CYLPreviewLocationMessageBlock)(CLLocation *location, NSString *geolocations, NSDictionary *userInfo);
typedef NSArray<CYLMenuItem *> *(^CYLLongPressMessageBlock)(CYLMessage *message, NSDictionary *userInfo);
typedef void(^CYLShowNotificationBlock)(__kindof UIViewController *viewController, NSString *title, NSString *subtitle, CYLMessageNotificationType type);
typedef void(^CYLHUDActionBlock)(__kindof UIViewController *viewController, UIView *view, NSString *title, CYLMessageHUDActionType type);
typedef CGFloat (^CYLAvatarImageViewCornerRadiusBlock)(CGSize avatarImageViewSize);
typedef void (^CYLConversationResultBlock)(id<CYLConversationProtocol> conversation, NSError *error);
typedef void (^CYLFetchConversationHandler) (id<CYLConversationProtocol> conversation, CYLConversationViewController *conversationController);
typedef void (^CYLConversationInvalidedHandler) (NSString *conversationId, CYLConversationViewController *conversationController, id<CYLUserDelegate> administrator, NSError *error);
typedef void (^CYLFilterMessagesCompletionHandler)(NSArray *filteredMessages, NSError *error);
typedef void (^CYLFilterMessagesBlock)(id<CYLConversationProtocol> conversation, NSArray<id<CYLIMMessageProtocol>> *messages, CYLFilterMessagesCompletionHandler completionHandler);
typedef void (^CYLSendMessageHookCompletionHandler)(BOOL granted, NSError *error);
typedef void (^CYLSendMessageHookBlock)(CYLConversationViewController *conversationController, id<CYLIMMessageProtocol> message, CYLSendMessageHookCompletionHandler completionHandler);
typedef void (^CYLLoadLatestMessagesHandler)(CYLConversationViewController *conversationController, BOOL succeeded, NSError *error);
typedef void (^CYLConversationListShowHookCompletionHandler)(NSArray<id<CYLConversationProtocol> > *conversations, NSError *error);
typedef void (^CYLConversationListShowHookBlock)(NSArray<id<CYLConversationProtocol> > *conversations, CYLConversationListShowHookCompletionHandler completionHandler);
typedef void(^CYLDidSelectConversationsListCellBlock)(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);
typedef void(^CYLDidDeleteConversationsListCellBlock)(NSIndexPath *indexPath, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);
typedef NSArray *(^CYLConversationEditActionsBlock)(NSIndexPath *indexPath, NSArray<UITableViewRowAction *> *editActions, id<CYLConversationProtocol> conversation, CYLConversationListViewController *controller);
typedef void(^CYLMarkBadgeWithTotalUnreadCountBlock)(NSInteger totalUnreadCount, __kindof UIViewController *controller);
```

**Macros**: `CYLPreviewImageMessageUserInfoKeyFromController`, `CYLPreviewImageMessageUserInfoKeyFromView`, `CYLPreviewImageMessageUserInfoKeyFromPlaceholderView`, `CYLPreviewImageMessageUserInfoKeyFromController`, `CYLPreviewImageMessageUserInfoKeyFromView`, `CYLPreviewImageMessageUserInfoKeyFromPlaceholderView`, `CYLPreviewLocationMessageUserInfoKeyFromController`, `CYLPreviewLocationMessageUserInfoKeyFromView`, `CYLLongPressMessageUserInfoKeyFromController`, `CYLLongPressMessageUserInfoKeyFromView`, `CYLLongPressMessageUserInfoKeyMessageOwner`, `CYLLongPressMessageUserInfoKeyMessageCell`

#### `CYLSingleton.h`

Path: `ChatKit/Class/Tool/CYLSingleton.h`

**Class `CYLSingleton`** : `NSObject`

```objc
+ (instancetype)sharedInstance;
+ (instancetype)instance;
+ (void)destroyInstance;
+ (void)destroyAllInstance;
@property (assign, readonly) BOOL isInitialized;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSMutableDictionary const *_sharedInstances;
```

#### `NSBundle+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/NSBundle+CYLExtension.h`

**Category `NSBundle (CYLExtension)`**

```objc
+ (NSBundle *)cyl_bundleForName:(NSString *)bundleName class:(Class)aClass;
```

#### `NSFileManager+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/NSFileManager+CYLExtension.h`

**Category `NSFileManager (CYLExtension)`**

```objc
+ (NSURL *)cyl_documentsURL;
+ (NSString *)cyl_documentsPath;
+ (NSURL *)cyl_libraryURL;
+ (NSString *)cyl_libraryPath;
+ (NSURL *)cyl_cachesURL;
+ (NSString *)cyl_cachesPath;
+ (BOOL)cyl_addSkipBackupAttributeToFile:(NSString *)cyl_path;
+ (double)cyl_availableDiskSpace;
```

#### `NSString+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/NSString+CYLExtension.h`

**Category `NSString (CYLExtension)`**

```objc
- (BOOL)cyl_containsString:(NSString *)string;
- (BOOL)cyl_onlyContainsLetterAndNumber;
- (BOOL)cyl_isLink;
- (BOOL)cyl_isPhoneNumber;
- (BOOL)cyl_isUserName;
- (BOOL)cyl_isSpace;
- (NSArray<NSString *> *)cyl_allURLLinks;
- (NSArray<NSString *> *)cyl_allPhoneNumbers;
- (NSArray<NSString *> *)cyl_allUserNames;
- (BOOL)cyl_isType:(NSTextCheckingType)type;
- (NSArray<NSString *> *)cyl_allCheckingTypeWithPattern:(NSString *)pattern error:(NSError **)error;
- (NSArray<NSValue *> *)cyl_allURLsWithPattern:(NSString *)pattern error:(NSError **)error;
- (UIColor *)cyl_hexStringToColor;
- (NSString *)cyl_pathForConversationBackgroundImage;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLURLRegex;
FOUNDATION_EXTERN NSString *const CYLPhoneRegex;
```

#### `NSString+CYLMD5.h`

Path: `ChatKit/Class/Tool/Categories/NSString+CYLMD5.h`

**Category `NSString (CYLMD5)`**

```objc
- (NSString *)cyl_MD5String;
```

#### `UIColor+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/UIColor+CYLExtension.h`

**Category `UIColor (CYLExtension)`**

```objc
+ (UIColor *)CJ_16_Color:(NSString *)code;
```

#### `UIImage+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/UIImage+CYLExtension.h`

**Category `UIImage (CYLExtension)`**

```objc
- (UIImage *)cyl_imageByScalingAspectFill;
- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize;
- (UIImage *)cyl_imageByScalingAspectFillWithOriginSize:(CGSize)originSize limitSize:(CGSize)limitSize;
+ (UIImage *)cyl_imageNamed:(NSString *)imageName bundleName:(NSString *)bundleName bundleForClass:(Class)aClass;
- (UIImage *)cyl_scalingPatternImageToSize:(CGSize)size;
```

#### `UIImageView+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/UIImageView+CYLExtension.h`

**Category `UIImageView (CYLExtension)`**

```objc
@property (nonatomic, assign) CGFloat cyl_cornerRadius;
```

#### `UIView+CYLExtension.h`

Path: `ChatKit/Class/Tool/Categories/UIView+CYLExtension.h`

**Category `UIView (CYLExtension)`**

```objc
- (NSMutableArray*)cyl_allSubViews;
- (void)cyl_logViewHierarchy:(CYLViewActionBlock)viewActionBlcok;
```

**Typedefs**

```objc
typedef void (^CYLViewActionBlock)(UIView *subview);
```

#### `LCChatKit_Internal.h`

Path: `ChatKit/Class/Tool/LCChatKit_Internal.h`

**Category `LCChatKit (CYLServices)`**

```objc
@property (nonatomic, strong, readonly) CYLSessionService *sessionService;
@property (nonatomic, strong, readonly) CYLUserSystemService *userSystemService;
@property (nonatomic, strong, readonly) CYLSignatureService *signatureService;
@property (nonatomic, strong, readonly) CYLSettingService *settingService;
@property (nonatomic, strong, readonly) CYLUIService *UIService;
@property (nonatomic, strong, readonly) CYLConversationService *conversationService;
@property (nonatomic, strong, readonly) CYLConversationListService *conversationListService;
```

#### `NSObject+CYLIsFirstLaunch.h`

Path: `ChatKit/Class/Tool/NSObject+CYLIsFirstLaunch.h`

**Category `NSObject (CYLIsFirstLaunch)`**

```objc
- (BOOL)cyl_isFirstLaunchToEvent:(NSString *)eventName evenUpdate:(BOOL)evenUpdate firstLaunch:(CYLFirstLaunchBlock)firstLaunch;
```

**Typedefs**

```objc
typedef BOOL (^CYLFirstLaunchBlock)(void);
```

#### `CYLConversationListService.h`

Path: `ChatKit/Class/Tool/Service/CYLConversationListService.h`

**Class `CYLConversationListService`** : `CYLSingleton` &lt;CYLConversationsListService&gt;

```objc
@property (nonatomic, copy, readonly) CYLPrepareConversationsWhenLoadBlock prepareConversationsWhenLoadBlock;
- (void)setPrepareConversationsWhenLoadBlock:(CYLPrepareConversationsWhenLoadBlock)prepareConversationsWhenLoadBlock;
- (void)findRecentConversationsWithBlock:(CYLRecentConversationsCallback)block;
@property (nonatomic, copy, readonly) CYLHeightForRowBlock heightForRowBlock;
- (void)setHeightForRowBlock:(CYLHeightForRowBlock)heightForRowBlock;
@property (nonatomic, copy, readonly) CYLCellForRowBlock cellForRowBlock __deprecated_msg("CYLCellForRowBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");
- (void)setCellForRowBlock:(CYLCellForRowBlock)cellForRowBlock __deprecated_msg("CYLCellForRowBlock is deprecated. Use <CYLConversationListViewControllerDelegate> instead");
@property (nonatomic, copy, readonly) CYLConfigureCellBlock configureCellBlock;
-(void)setConfigureCellBlock:(CYLConfigureCellBlock)configureCellBlock;
- (void)fetchRelationConversationsFromServerCallback:(CYLArrayResultBlock)block;
```

**Typedefs**

```objc
typedef void (^CYLRecentConversationsCallback)(NSArray *conversations, NSInteger totalUnreadCount, NSError *error);
typedef void(^CYLPrepareConversationsWhenLoadBlock)(NSArray<id<CYLConversationProtocol>> *conversations, CYLBooleanResultBlock callback);
typedef CGFloat (^CYLHeightForRowBlock) (UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
typedef UITableViewCell* (^CYLCellForRowBlock)(UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
typedef void (^CYLConfigureCellBlock) (UITableViewCell *cell, UITableView *tableView, NSIndexPath *indexPath, id<CYLConversationProtocol> conversation);
```

#### `CYLConversationService.h`

Path: `ChatKit/Class/Tool/Service/CYLConversationService.h`

**Class `CYLConversationService`** : `CYLSingleton` &lt;CYLConversationService&gt;

```objc
@property (nonatomic, strong) NSString *currentConversationId;
@property (nonatomic, strong) NSString *remoteNotificationConversationId;
@property (nonatomic, assign, readonly, getter=isChatting) BOOL chatting;
@property (nonatomic, strong) id<CYLConversationProtocol> currentConversation;
- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(CYLConversationResultBlock)callback;
- (void)fetchConversationsWithConversationIds:(NSSet *)conversationIds callback:(CYLArrayResultBlock)callback;
- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(CYLConversationResultBlock)callback;
- (void)sendMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation progressBlock:(CYLProgressBlock)progressBlock callback:(CYLBooleanResultBlock)block;
- (void)sendMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation mentionList:(NSArray<NSString *> *)mentionList progressBlock:(CYLProgressBlock)progressBlock callback:(CYLBooleanResultBlock)block;
- (void)queryTypedMessagesWithConversation:(id<CYLConversationProtocol>)conversation messageId:(NSString *)messageId timestamp:(int64_t)timestamp limit:(NSInteger)limit block:(CYLArrayResultBlock)block;
- (void)removeCacheForConversationId:(NSString *)conversationID;
- (void)updateConversationAsReadWithLastMessage:(id)lastMessage;
- (void)setupDatabaseWithUserId:(NSString *)userId;
- (void)insertRecentConversation:(id<CYLConversationProtocol>)conversation shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations;
- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId;
- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId;
- (void)updateDraft:(NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateRecentConversation:(NSArray *)conversations;
- (void)updateRecentConversation:(NSArray *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)increaseUnreadCountWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (NSArray *)allRecentConversations;
- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId;
- (NSString *)draftWithConversationId:(NSString *)conversationId;
- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message;
- (void)insertFailedCYLMessage:(CYLMessage *)message;
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;
- (NSArray<CYLMessage *> *)failedMessagesByConversationId:(NSString *)conversationId;
- (NSArray<CYLMessage *> *)failedMessageIdsByConversationId:(NSString *)conversationId;
- (NSArray<CYLMessage *> *)failedMessagesByMessageIds:(NSArray *)messageIds;
```

**Category `CYLConversationService (CYLDeprecated)`**

```objc
- (void)fecthConversationWithConversationId:(NSString *)conversationId callback:(CYLConversationResultBlock)callback CYL_DEPRECATED("deprecated after v0.8.11, use `-fetchConversationWithConversationId:callback:` instead");
- (void)fecthConversationWithPeerId:(NSString *)peerId callback:(CYLConversationResultBlock)callback CYL_DEPRECATED("deprecated after v0.8.11, use `-fetchConversationWithPeerId:callback:` instead");
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLConversationServiceErrorDomain;
```

#### `CYLIMProvider.h`

Path: `ChatKit/Class/Tool/Service/CYLIMProvider.h`

**Protocol `CYLIMSessionProvider`** adopts &lt;NSObject&gt;

```objc
@required
- (nullable NSString *)clientId;
- (BOOL)isConnected;
- (BOOL)isClientOpened;
- (void)openWithClientId:(NSString *)clientId force:(BOOL)force callback:(nullable CYLBooleanResultBlock)callback;
- (void)closeWithCallback:(nullable CYLBooleanResultBlock)callback;
@optional
- (nullable id)client;
- (void)setAppId:(NSString *)appId appKey:(NSString *)appKey;
- (void)setAllLogsEnabled:(BOOL)enabled;
```

**Protocol `CYLIMConversationProvider`** adopts &lt;NSObject&gt;

```objc
@required
- (void)fetchConversationWithConversationId:(NSString *)conversationId callback:(nullable CYLIMConversationResultBlock)callback;
- (void)fetchConversationsWithConversationIds:(NSSet<NSString *> *)conversationIds callback:(nullable CYLArrayResultBlock)callback;
- (void)fetchConversationWithPeerId:(NSString *)peerId callback:(nullable CYLIMConversationResultBlock)callback;
- (void)createConversationWithMembers:(NSArray<NSString *> *)members type:(CYLConversationType)type unique:(BOOL)unique callback:(nullable CYLIMConversationResultBlock)callback;
- (void)joinConversation:(id<CYLConversationProtocol>)conversation callback:(nullable CYLBooleanResultBlock)callback;
- (void)markConversationAsRead:(id<CYLConversationProtocol>)conversation;
@optional
- (void)prepareConversation:(id<CYLConversationProtocol>)conversation;
```

**Protocol `CYLIMMessageProvider`** adopts &lt;NSObject&gt;

```objc
@required
- (nullable id)displayMessageFromIMMessage:(id<CYLIMMessageProtocol>)message;
- (nullable id<CYLIMMessageProtocol>)IMMessageFromMessage:(id)message;
- (void)sendMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation mentionList:(nullable NSArray<NSString *> *)mentionList progressBlock:(nullable CYLProgressBlock)progressBlock callback:(nullable CYLBooleanResultBlock)callback;
- (void)queryMessagesWithConversation:(id<CYLConversationProtocol>)conversation messageId:(nullable NSString *)messageId timestamp:(int64_t)timestamp limit:(NSInteger)limit callback:(nullable CYLArrayResultBlock)callback;
- (void)updateMessage:(id<CYLIMMessageProtocol>)oldMessage withText:(NSString *)text conversation:(id<CYLConversationProtocol>)conversation callback:(nullable CYLIMMessageResultBlock)callback;
- (void)recallMessage:(id<CYLIMMessageProtocol>)message conversation:(id<CYLConversationProtocol>)conversation callback:(nullable CYLIMMessageResultBlock)callback;
@optional
- (void)downloadAttachmentOfMessage:(CYLMessage *)message completion:(void (^)(NSURL * _Nullable filePath, NSError * _Nullable error))completion;
```

**Protocol `CYLIMRecentConversationProvider`** adopts &lt;NSObject&gt;

```objc
@required
- (NSArray<id<CYLConversationProtocol>> *)allRecentConversations;
- (BOOL)isRecentConversationExistWithConversationId:(NSString *)conversationId;
- (void)insertRecentConversations:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateRecentConversation:(NSArray<id<CYLConversationProtocol>> *)conversations shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)deleteRecentConversationWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateUnreadCountToZeroWithConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)increaseUnreadCount:(NSUInteger)increaseUnreadCount withConversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateMentioned:(BOOL)mentioned conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (void)updateDraft:(nullable NSString *)draft conversationId:(NSString *)conversationId shouldRefreshWhenFinished:(BOOL)shouldRefreshWhenFinished;
- (nullable NSString *)draftWithConversationId:(NSString *)conversationId;
- (BOOL)removeAllCachedRecentConversations;
- (void)findRecentConversationsWithBlock:(nullable CYLIMRecentConversationsResultBlock)block;
- (void)fetchRelationConversationsFromServerCallback:(nullable CYLArrayResultBlock)block;
@optional
- (void)setupDatabaseWithUserId:(NSString *)userId;
```

**Protocol `CYLIMFailedMessageProvider`** adopts &lt;NSObject&gt;

```objc
- (void)insertFailedCYLMessage:(CYLMessage *)message;
- (void)insertFailedMessage:(id<CYLIMMessageProtocol>)message;
- (BOOL)deleteFailedMessageByRecordId:(NSString *)recordId;
- (NSArray<CYLMessage *> *)failedMessagesByConversationId:(NSString *)conversationId;
- (NSArray<NSString *> *)failedMessageIdsByConversationId:(NSString *)conversationId;
- (nullable NSArray<CYLMessage *> *)failedMessagesByMessageIds:(NSArray<NSString *> *)messageIds;
```

**Protocol `CYLIMPushProvider`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)registerForRemoteNotification;
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(nullable NSString *)userId;
- (void)pushMessage:(NSString *)message userIds:(NSArray<NSString *> *)userIds block:(nullable CYLBooleanResultBlock)block;
- (void)cleanBadge;
- (void)syncBadge;
- (void)setUseDevPushCerticate:(BOOL)useDevPushCerticate;
```

**Protocol `CYLIMProvider`** adopts &lt;CYLIMSessionProvider, CYLIMConversationProvider, CYLIMMessageProvider, CYLIMRecentConversationProvider, CYLIMFailedMessageProvider, CYLIMPushProvider&gt;

**Typedefs**

```objc
typedef void (^CYLIMConversationResultBlock)(id<CYLConversationProtocol> _Nullable conversation, NSError * _Nullable error);
typedef void (^CYLIMMessageResultBlock)(BOOL succeeded, NSError * _Nullable error, id<CYLIMMessageProtocol> _Nullable message);
typedef void (^CYLIMRecentConversationsResultBlock)(NSArray<id<CYLConversationProtocol>> * _Nullable conversations, NSInteger totalUnreadCount, NSError * _Nullable error);
```

#### `CYLSessionService.h`

Path: `ChatKit/Class/Tool/Service/CYLSessionService.h`

**Class `CYLSessionService`** : `CYLSingleton` &lt;CYLSessionService&gt;

```objc
@property (nonatomic, copy, readonly) NSString *clientId;
@property (nonatomic, strong, readonly) id client;
@property (nonatomic, assign, readonly) BOOL connect;
@property (nonatomic, assign, readonly, getter=isClientOpened) BOOL clientOpened;
@property (nonatomic, copy) void (^ memberInfoChangedBlock)(id<CYLConversationProtocol> conversation, NSString *byClientId, NSString *clientId, NSUInteger role);
- (void)reconnectForViewController:(UIViewController *)reconnectForViewController callback:(CYLBooleanResultBlock)aCallback;
- (void)handleSingleSignOnError:(NSError *)error callback:(CYLBooleanResultBlock)callback;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLSessionServiceErrorDemain;
```

#### `CYLSettingService.h`

Path: `ChatKit/Class/Tool/Service/CYLSettingService.h`

**Class `CYLSettingService`** : `CYLSingleton` &lt;CYLSettingService&gt;

```objc
@property (nonatomic, strong, readonly) NSDictionary *defaultSettings;
@property (nonatomic, strong, readonly) NSDictionary *defaultTheme;
@property (nonatomic, strong, readonly) NSDictionary *messageBubbleCustomizeSettings;
- (NSString *)tmpPath;
- (NSString *)getPathByObjectId:(NSString *)objectId;
- (NSString *)videoPathOfMessage:(id<CYLIMMessageProtocol>)message;
- (void)registerForRemoteNotification;
- (void)saveInstallationWithDeviceToken:(NSData *)deviceToken userId:(NSString *)userId;
- (void)pushMessage:(NSString *)message userIds:(NSArray *)userIds block:(CYLBooleanResultBlock)block;
- (void)cleanBadge;
- (void)syncBadge;
- (UIColor *)defaultThemeColorForKey:(NSString *)key;
- (UIFont *)defaultThemeTextMessageFont;
- (UIEdgeInsets)messageBubbleCustomizeSettingsForPosition:(NSString *)position capOrEdge:(NSString *)capOrEdge;
- (UIEdgeInsets)rightCapMessageBubbleCustomize;
- (UIEdgeInsets)rightEdgeMessageBubbleCustomize;
- (UIEdgeInsets)leftCapMessageBubbleCustomize;
- (UIEdgeInsets)leftEdgeMessageBubbleCustomize;
- (UIEdgeInsets)rightHollowCapMessageBubbleCustomize;
- (UIEdgeInsets)rightHollowEdgeMessageBubbleCustomize;
- (UIEdgeInsets)leftHollowCapMessageBubbleCustomize;
- (UIEdgeInsets)leftHollowEdgeMessageBubbleCustomize;
- (NSString *)imageNameForMessageBubbleCustomizeForPosition:(NSString *)position normalOrHighlight:(NSString *)normalOrHighlight;
- (NSString *)leftNormalImageNameMessageBubbleCustomize;
- (NSString *)leftHighlightImageNameMessageBubbleCustomize;
- (NSString *)rightHighlightImageNameMessageBubbleCustomize;
- (NSString *)rightNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowRightNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowRightHighlightImageNameMessageBubbleCustomize;
- (NSString *)hollowLeftNormalImageNameMessageBubbleCustomize;
- (NSString *)hollowLeftHighlightImageNameMessageBubbleCustomize;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLSettingServiceErrorDomain;
```

**Macros**: `CYL_STRING_BY_SEL(sel)`

#### `CYLSignatureService.h`

Path: `ChatKit/Class/Tool/Service/CYLSignatureService.h`

**Class `CYLSignatureService`** : `CYLSingleton` &lt;CYLSignatureService&gt;

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLSignatureServiceErrorDomain;
```

#### `CYLUIService.h`

Path: `ChatKit/Class/Tool/Service/CYLUIService.h`

**Class `CYLUIService`** : `CYLSingleton` &lt;CYLUIService&gt;

```objc
@property (nonatomic, copy, readonly) CYLUnreadCountChangedBlock unreadCountChangedBlock;
- (void)setUnreadCountChangedBlock:(CYLUnreadCountChangedBlock)unreadCountChangedBlock;
```

**Typedefs**

```objc
typedef void(^CYLUnreadCountChangedBlock)(NSInteger count);
typedef void(^CYLOnNewMessageBlock)(NSString *senderId, NSString *content, NSInteger type, NSDate *time);
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLUIServiceErrorDomain;
```

#### `CYLUserSystemService.h`

Path: `ChatKit/Class/Tool/Service/CYLUserSystemService.h`

**Class `CYLUserSystemService`** : `CYLSingleton` &lt;CYLUserSystemService&gt;

```objc
- (NSArray<id<CYLUserDelegate>> *)getProfilesForUserIds:(NSArray<NSString *> *)userIds error:(NSError * __autoreleasing *)theError;
- (void)getProfilesInBackgroundForUserIds:(NSArray<NSString *> *)userIds callback:(CYLUserResultsCallBack)callback;
- (id<CYLUserDelegate>)getProfileForUserId:(NSString *)userId error:(NSError * __autoreleasing *)theError;
- (id<CYLUserDelegate>)fetchCurrentUser;
- (void)fetchCurrentUserInBackground:(CYLUserResultCallBack)callback;
- (void)cacheUsersWithIds:(NSSet<id<CYLUserDelegate>> *)userIds callback:(CYLBooleanResultBlock)callback;
- (void)cacheUsers:(NSArray<id<CYLUserDelegate>> *)users;
```

**Constants and functions**

```objc
FOUNDATION_EXTERN NSString *const CYLUserSystemServiceErrorDomain;
```

### View

#### `CYLBadgeView.h`

Path: `ChatKit/Class/View/CYLBadgeView.h`

**Class `CYLBadgeView`** : `UIView`

```objc
@property (nonatomic, copy) NSString *badgeText;
@property (nonatomic, assign) CYLBadgeViewAlignment badgeAlignment UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize badgeTextShadowOffset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeTextShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *badgeTextFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeBackgroundColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeOverlayColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeShadowColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGSize badgeShadowSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat badgeStrokeWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *badgeStrokeColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGPoint badgePositionAdjustment UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGRect frameToPositionInRelationWith UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat badgeMinWidth UI_APPEARANCE_SELECTOR;
- (id)initWithParentView:(UIView *)parentView alignment:(CYLBadgeViewAlignment)alignment;
```

**Enums**

- `CYLBadgeViewAlignment` (`NSUInteger`): `CYLBadgeViewAlignmentTopLeft`, `CYLBadgeViewAlignmentTopRight`, `CYLBadgeViewAlignmentTopCenter`, `CYLBadgeViewAlignmentCenterLeft`, `CYLBadgeViewAlignmentCenterRight`, `CYLBadgeViewAlignmentBottomLeft`, `CYLBadgeViewAlignmentBottomRight`, `CYLBadgeViewAlignmentBottomCenter`, `CYLBadgeViewAlignmentCenter`

#### `CYLConversationRefreshHeader.h`

Path: `ChatKit/Class/View/CYLConversationRefreshHeader.h`

**Class `CYLConversationRefreshHeader`** : `MJRefreshHeader`

#### `CYLStatusView.h`

Path: `ChatKit/Class/View/CYLStatusView.h`

**Class `CYLStatusView`** : `UIView`

```objc
@property (nonatomic, weak) id<CYLStatusViewDelegate> delegate;
```

**Protocol `CYLStatusViewDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)statusViewClicked:(id)sender;
```

**Constants and functions**

```objc
static CGFloat CYLStatusViewHight = 44;
```

#### `CYLSwipeView.h`

Path: `ChatKit/Class/View/CYLSwipeView.h`

**Class `CYLSwipeView`** : `UIView`

```objc
@property (nonatomic, weak_delegate) IBOutlet id<CYLSwipeViewDataSource> dataSource;
@property (nonatomic, weak_delegate) IBOutlet id<CYLSwipeViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfItems;
@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, readonly) CGSize itemSize;
@property (nonatomic, assign) NSInteger itemsPerPage;
@property (nonatomic, assign) BOOL truncateFinalPage;
@property (nonatomic, strong, readonly) NSArray *indexesForVisibleItems;
@property (nonatomic, strong, readonly) NSArray *visibleItemViews;
@property (nonatomic, strong, readonly) UIView *currentItemView;
@property (nonatomic, assign) NSInteger currentItemIndex;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) CYLSwipeViewAlignment alignment;
@property (nonatomic, assign) CGFloat scrollOffset;
@property (nonatomic, assign, getter = isPagingEnabled) BOOL pagingEnabled;
@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;
@property (nonatomic, assign, getter = isWrapEnabled) BOOL wrapEnabled;
@property (nonatomic, assign) BOOL delaysContentTouches;
@property (nonatomic, assign) BOOL bounces;
@property (nonatomic, assign) float decelerationRate;
@property (nonatomic, assign) CGFloat autoscroll;
@property (nonatomic, readonly, getter = isDragging) BOOL dragging;
@property (nonatomic, readonly, getter = isDecelerating) BOOL decelerating;
@property (nonatomic, readonly, getter = isScrolling) BOOL scrolling;
@property (nonatomic, assign) BOOL defersItemViewLoading;
@property (nonatomic, assign, getter = isVertical) BOOL vertical;
- (void)reloadData;
- (void)reloadItemAtIndex:(NSInteger)index;
- (void)scrollByOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollToOffset:(CGFloat)offset duration:(NSTimeInterval)duration;
- (void)scrollByNumberOfItems:(NSInteger)itemCount duration:(NSTimeInterval)duration;
- (void)scrollToItemAtIndex:(NSInteger)index duration:(NSTimeInterval)duration;
- (void)scrollToPage:(NSInteger)page duration:(NSTimeInterval)duration;
- (UIView *)itemViewAtIndex:(NSInteger)index;
- (NSInteger)indexOfItemView:(UIView *)view;
- (NSInteger)indexOfItemViewOrSubview:(UIView *)view;
```

**Protocol `CYLSwipeViewDataSource`** adopts &lt;NSObject&gt;

```objc
- (NSInteger)numberOfItemsInCYLSwipeView:(CYLSwipeView *)swipeView;
- (UIView *)swipeView:(CYLSwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view;
```

**Protocol `CYLSwipeViewDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (CGSize)swipeViewItemSize:(CYLSwipeView *)swipeView;
- (void)swipeViewDidScroll:(CYLSwipeView *)swipeView;
- (void)swipeViewCurrentItemIndexDidChange:(CYLSwipeView *)swipeView;
- (void)swipeViewWillBeginDragging:(CYLSwipeView *)swipeView;
- (void)swipeViewDidEndDragging:(CYLSwipeView *)swipeView willDecelerate:(BOOL)decelerate;
- (void)swipeViewWillBeginDecelerating:(CYLSwipeView *)swipeView;
- (void)swipeViewDidEndDecelerating:(CYLSwipeView *)swipeView;
- (void)swipeViewDidEndScrollingAnimation:(CYLSwipeView *)swipeView;
- (BOOL)swipeView:(CYLSwipeView *)swipeView shouldSelectItemAtIndex:(NSInteger)index;
- (void)swipeView:(CYLSwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index;
```

**Enums**

- `CYLSwipeViewAlignment` (`NSUInteger`): `CYLSwipeViewAlignmentEdge`, `CYLSwipeViewAlignmentCenter`

**Macros**: `weak_delegate`, `weak_delegate`

### Vendor (CYLAlertController)

#### `CYLAlertController.h`

Path: `ChatKit/Class/Tool/Vendor/CYLAlertController/CYLAlertController.h`

**Class `CYLAlertAction`** : `NSObject`

```objc
+ (instancetype)actionWithTitle:(NSString *)title style:(CYLAlertActionStyle)style handler:(void (^ __nullable)(CYLAlertAction *action))handler;
+ (instancetype)actionWithTitle:(NSString *)title handler:(void (^ __nullable)(CYLAlertAction *action))handler;
@property (nonatomic, readonly) CYLAlertActionStyle style;
@property (nonatomic, weak) CYLAlertController *alertController;
```

**Class `CYLAlertController`** : `NSObject`

```objc
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(CYLAlertControllerStyle)preferredStyle;
- (instancetype)init NS_UNAVAILABLE;
- (void)addAction:(CYLAlertAction *)action;
- (void)addWillDismissBlock:(void (^)(CYLAlertAction *action))willDismissBlock;
- (void)addDidDismissBlock:(void (^)(CYLAlertAction *action))didDismissBlock;
@property (nullable, nonatomic, copy, readonly) NSArray<CYLAlertAction *> *actions;
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;
@property (nullable, nonatomic, copy) NSString *title;
@property (nullable, nonatomic, copy) NSString *message;
@property (nonatomic, readonly) CYLAlertControllerStyle preferredStyle;
- (void)showWithSender:(nullable id)sender controller:(nullable UIViewController *)controller animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;
- (void)showWithSender:(nullable id)sender arrowDirection:(UIPopoverArrowDirection)arrowDirection controller:(nullable UIViewController *)controller animated:(BOOL)animated completion:(void (^ __nullable)(void))completion;
- (void)dismissAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion;
+ (BOOL)hasVisibleAlertController;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
```

**Category `CYLAlertController (Convenience)`**

```objc
+ (instancetype)actionSheetWithTitle:(nullable NSString *)title;
+ (instancetype)alertWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
+ (instancetype)presentDismissableAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message controller:(nullable UIViewController *)controller;
+ (instancetype)presentDismissableAlertWithTitle:(nullable NSString *)title error:(nullable NSError *)error controller:(nullable UIViewController *)controller;
- (void)addCancelActionWithHandler:(void (^ __nullable)(CYLAlertAction *action))handler;
@property (nullable, nonatomic, readonly) UITextField *textField;
```

**Category `CYLAlertController (Internal)`**

```objc
@property (nullable, nonatomic, strong, readonly) UIAlertController *alertController;
@property (nullable, nonatomic, strong, readonly) UIActionSheet *actionSheet;
@property (nullable, nonatomic, strong, readonly) UIAlertView *alertView;
@property (nullable, nonatomic, strong, readonly) id presentedObject;
```

**Enums**

- `CYLAlertControllerStyle` (`NSInteger`): `CYLAlertControllerStyleActionSheet`, `CYLAlertControllerStyleAlert`
- `CYLAlertActionStyle` (`NSInteger`): `CYLAlertActionStyleDefault`, `CYLAlertActionStyleCancel`, `CYLAlertActionStyleDestructive`

### Vendor (CYLPhotoBrowser)

#### `CYLCaptionView.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLCaptionView.h`

**Class `CYLCaptionView`** : `UIView`

```objc
- (id)initWithPhoto:(id<CYLPhoto>)photo;
- (void)setupCaption;
- (CGSize)sizeThatFits:(CGSize)size;
```

#### `CYLPBConstants.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLPBConstants.h`

**Macros**: `PADDING`, `PAGE_INDEX_TAG_OFFSET`, `PAGE_INDEX(page)`, `CYLPBLog(x, ...)`, `CYLPBLog(x, ...)`, `SYSTEM_VERSION_EQUAL_TO(v)`, `SYSTEM_VERSION_GREATER_THAN(v)`, `SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)`, `SYSTEM_VERSION_LESS_THAN(v)`, `SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)`

#### `CYLPhoto.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLPhoto.h`

**Class `CYLPhoto`** : `NSObject` &lt;CYLPhoto&gt;

```objc
@property (nonatomic, strong) CYLProgressUpdateBlock progressUpdateBlock;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *underlyingImage;
@property (nonatomic, strong) UIImageView *placeholderImageView;
@property (nonatomic, assign, readonly) CGRect placeholderFrame;
@property (nonatomic, assign, readonly) BOOL loadingInProgress;
+ (CYLPhoto *)photoWithImage:(UIImage *)image;
+ (CYLPhoto *)photoWithFilePath:(NSString *)path;
+ (CYLPhoto *)photoWithURL:(NSURL *)url;
+ (NSArray *)photosWithImages:(NSArray *)imagesArray;
+ (NSArray *)photosWithFilePaths:(NSArray *)pathsArray;
+ (NSArray *)photosWithURLs:(NSArray *)urlsArray;
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;
```

**Typedefs**

```objc
typedef void (^CYLProgressUpdateBlock)(CGFloat progress);
```

#### `CYLPhotoBrowser.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLPhotoBrowser.h`

**Class `CYLPhotoBrowser`** : `UIViewController` &lt;UIScrollViewDelegate, UIActionSheetDelegate&gt;

```objc
@property (nonatomic, strong) id <CYLPhotoBrowserDelegate> delegate;
@property (nonatomic, strong) NSArray *actionButtonTitles;
@property (nonatomic) BOOL useWhiteBackgroundColor;
@property (nonatomic, weak) UIColor *trackTintColor, *progressTintColor;
@property (nonatomic) BOOL forceHideStatusBar;
@property (nonatomic) BOOL usePopAnimation;
@property (nonatomic) float backgroundScaleFactor;
@property (nonatomic) float animationDuration;
- (id)initWithPhotos:(NSArray *)photosArray;
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray;
- (void)reloadData;
- (void)setInitialPageIndex:(NSUInteger)index;
- (id<CYLPhoto>)photoAtIndex:(NSUInteger)index;
```

**Protocol `CYLPhotoBrowserDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex;
- (void)photoBrowser:(CYLPhotoBrowser *)photoBrowser clickedButtonAtIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex;
- (CYLCaptionView *)photoBrowser:(CYLPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
```

#### `CYLPhotoProtocol.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLPhotoProtocol.h`

**Protocol `CYLPhoto`** adopts &lt;NSObject&gt;

```objc
@required
- (UIImage *)underlyingImage;
- (void)loadUnderlyingImageAndNotify;
- (void)unloadUnderlyingImage;
@optional
- (NSString *)caption;
- (UIImage *)placeholderImage;
- (UIImageView *)placeholderImageView;
- (CGRect)placeholderFrame;
- (BOOL)loadingInProgress;
- (BOOL)underlyingImageExisted;
```

**Macros**: `CYLPhoto_LOADING_DID_END_NOTIFICATION`

#### `CYLTapDetectingImageView.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLTapDetectingImageView.h`

**Class `CYLTapDetectingImageView`** : `UIImageView`

```objc
@property (nonatomic, weak) id <CYLTapDetectingImageViewDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
```

**Protocol `CYLTapDetectingImageViewDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
```

#### `CYLTapDetectingView.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLTapDetectingView.h`

**Class `CYLTapDetectingView`** : `UIView`

```objc
@property (nonatomic, weak) id <CYLTapDetectingViewDelegate> tapDelegate;
- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
```

**Protocol `CYLTapDetectingViewDelegate`** adopts &lt;NSObject&gt;

```objc
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
```

#### `CYLZoomingScrollView.h`

Path: `ChatKit/Class/Tool/Vendor/CYLPhotoBrowser/CYLZoomingScrollView.h`

**Class `CYLZoomingScrollView`** : `UIScrollView` &lt;UIScrollViewDelegate, CYLTapDetectingImageViewDelegate, CYLTapDetectingViewDelegate&gt;

```objc
@property (nonatomic, strong) CYLTapDetectingImageView *photoImageView;
@property (nonatomic, strong) CYLCaptionView *captionView;
@property (nonatomic, strong) id<CYLPhoto> photo;
- (id)initWithPhotoDelegate:(id<CYLZoomingScrollViewDelegate>)photoDelegate;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(CYLPhoto*)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;
- (void)animateImage;
```

**Protocol `CYLZoomingScrollViewDelegate`** adopts &lt;NSObject&gt;

```objc
@required
- (UIImage *)imageForPhoto:(id<CYLPhoto>)photo zoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
@optional
- (UIColor *)trackTintColorForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (UIColor *)progressTintColorForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (CGFloat)animationDurationForZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (void)singleTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (void)doubleTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
- (void)longTapInZoomingScrollView:(CYLZoomingScrollView *)zoomingScrollView;
```

### Vendor (CYLTableViewRowAction)

#### `UITableViewRowAction+CYLExtension.h`

Path: `ChatKit/Class/Tool/Vendor/CYLTableViewRowAction/UITableViewRowAction+CYLExtension.h`

**Category `UITableViewRowAction (CYLExtension)`**

```objc
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, assign) BOOL enabled;
+ (nonnull instancetype)rowActionWithStyle:(UITableViewRowActionStyle)style image:(nullable UIImage *)image handler:(nullable void (^)(UITableViewRowAction * _Nullable action, NSIndexPath * _Nullable indexPath))handler;
```

### Vendor (CYLWebViewController)

#### `CYLSafariActivity.h`

Path: `ChatKit/Class/Tool/Vendor/CYLWebViewController/CYLSafariActivity/CYLSafariActivity.h`

**Class `CYLSafariActivity`** : `UIActivity`

#### `CYLWebViewController.h`

Path: `ChatKit/Class/Tool/Vendor/CYLWebViewController/CYLWebViewController/CYLWebViewController.h`

**Class `CYLWebViewController`** : `UIViewController` &lt;UIWebViewDelegate&gt;

```objc
@property (strong, nonatomic, nullable) NSURL *URL;
@property (strong, nonatomic, nullable) NSURLRequest *URLRequest;
@property (strong, nonatomic, nullable) NSArray *activityItems;
@property (strong, nonatomic, nullable) NSArray *applicationActivities;
@property (strong, nonatomic, nullable) NSArray *excludedActivityTypes;
@property (assign, nonatomic) BOOL showsNavigationToolbar;
- (void)load;
- (void)clear;
```

#### `CYLWebViewProgress.h`

Path: `ChatKit/Class/Tool/Vendor/CYLWebViewController/CYLWebViewProgress/CYLWebViewProgress.h`

**Class `CYLWebViewProgress`** : `NSObject` &lt;UIWebViewDelegate&gt;

```objc
@property (nonatomic, njk_weak) id<CYLWebViewProgressDelegate>progressDelegate;
@property (nonatomic, njk_weak) id<UIWebViewDelegate>webViewProxyDelegate;
@property (nonatomic, copy) CYLWebViewProgressBlock progressBlock;
@property (nonatomic, readonly) float progress;
- (void)reset;
```

**Protocol `CYLWebViewProgressDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)webViewProgress:(CYLWebViewProgress *)webViewProgress updateProgress:(float)progress;
```

**Typedefs**

```objc
typedef void (^CYLWebViewProgressBlock)(float progress);
```

**Constants and functions**

```objc
extern const float CYLInitialProgressValue;
extern const float CYLInteractiveProgressValue;
extern const float CYLFinalProgressValue;
```

**Macros**: `njk_weak`, `njk_weak`

#### `CYLWebViewProgressView.h`

Path: `ChatKit/Class/Tool/Vendor/CYLWebViewController/CYLWebViewProgress/CYLWebViewProgressView.h`

**Class `CYLWebViewProgressView`** : `UIView`

```objc
@property (nonatomic) float progress;
@property (nonatomic) UIView *progressBarView;
@property (nonatomic) NSTimeInterval barAnimationDuration;
@property (nonatomic) NSTimeInterval fadeAnimationDuration;
@property (nonatomic) NSTimeInterval fadeOutDelay;
- (void)setProgress:(float)progress animated:(BOOL)animated;
```

### Vendor (DateTools)

#### `CYLDateToolsConstants.h`

Path: `ChatKit/Class/Tool/Vendor/DateTools/CYLDateToolsConstants.h`

**Constants and functions**

```objc
static const long long SECONDS_IN_YEAR = 31556900;
static const NSInteger SECONDS_IN_MONTH_28 = 2419200;
static const NSInteger SECONDS_IN_MONTH_29 = 2505600;
static const NSInteger SECONDS_IN_MONTH_30 = 2592000;
static const NSInteger SECONDS_IN_MONTH_31 = 2678400;
static const NSInteger SECONDS_IN_WEEK = 604800;
static const NSInteger SECONDS_IN_DAY = 86400;
static const NSInteger SECONDS_IN_HOUR = 3600;
static const NSInteger SECONDS_IN_MINUTE = 60;
static const NSInteger MILLISECONDS_IN_DAY = 86400000;
```

#### `CYLError.h`

Path: `ChatKit/Class/Tool/Vendor/DateTools/CYLError.h`

**Class `CYLError`** : `NSObject`

```objc
+(void)throwInsertOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+(void)throwRemoveOutOfBoundsException:(NSInteger)index array:(NSArray *)array;
+(void)throwBadTypeException:(id)obj expectedClass:(Class)classType;
```

**Constants and functions**

```objc
extern NSString *const CYLErrorDomain;
static const NSUInteger DTInsertOutOfBoundsException = 0;
static const NSUInteger DTRemoveOutOfBoundsException = 1;
static const NSUInteger DTBadTypeException = 2;
```

#### `NSDate+CYLDateTools.h`

Path: `ChatKit/Class/Tool/Vendor/DateTools/NSDate+CYLDateTools.h`

**Category `NSDate (DateTools)`**

```objc
+ (NSString *)cyl_timeAgoSinceDate:(NSDate *)date;
+ (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date;
- (NSString *)cyl_timeAgoSinceNow;
- (NSString *)cyl_shortTimeAgoSinceNow;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates numericTimes:(BOOL)useNumericTimes;
- (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date;
- (NSInteger)cyl_era;
- (NSInteger)cyl_year;
- (NSInteger)cyl_month;
- (NSInteger)cyl_day;
- (NSInteger)cyl_hour;
- (NSInteger)cyl_minute;
- (NSInteger)cyl_second;
- (NSInteger)cyl_weekday;
- (NSInteger)cyl_weekdayOrdinal;
- (NSInteger)cyl_quarter;
- (NSInteger)cyl_weekOfMonth;
- (NSInteger)cyl_weekOfYear;
- (NSInteger)cyl_yearForWeekOfYear;
- (NSInteger)cyl_daysInMonth;
- (NSInteger)cyl_dayOfYear;
- (NSInteger)cyl_daysInYear;
- (BOOL)cyl_isInLeapYear;
- (BOOL)cyl_isToday;
- (BOOL)cyl_isTomorrow;
- (BOOL)cyl_isYesterday;
- (BOOL)cyl_isWeekend;
- (BOOL)cyl_isSameDay:(NSDate *)date;
+ (BOOL)cyl_isSameDay:(NSDate *)date asDate:(NSDate *)compareDate;
- (NSInteger)cyl_eraWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_yearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_monthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_dayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_hourWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_minuteWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_secondWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekdayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekdayOrdinalWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_quarterWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekOfMonthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekOfYearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_yearForWeekOfYearWithCalendar:(NSCalendar *)calendar;
+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString;
+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString timeZone:(NSTimeZone *)timeZone;
- (NSDate *)cyl_dateByAddingYears:(NSInteger)years;
- (NSDate *)cyl_dateByAddingMonths:(NSInteger)months;
- (NSDate *)cyl_dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)cyl_dateByAddingDays:(NSInteger)days;
- (NSDate *)cyl_dateByAddingHours:(NSInteger)hours;
- (NSDate *)cyl_dateByAddingMinutes:(NSInteger)minutes;
- (NSDate *)cyl_dateByAddingSeconds:(NSInteger)seconds;
- (NSDate *)cyl_dateBySubtractingYears:(NSInteger)years;
- (NSDate *)cyl_dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)cyl_dateBySubtractingWeeks:(NSInteger)weeks;
- (NSDate *)cyl_dateBySubtractingDays:(NSInteger)days;
- (NSDate *)cyl_dateBySubtractingHours:(NSInteger)hours;
- (NSDate *)cyl_dateBySubtractingMinutes:(NSInteger)minutes;
- (NSDate *)cyl_dateBySubtractingSeconds:(NSInteger)seconds;
-(NSInteger)cyl_yearsFrom:(NSDate *)date;
-(NSInteger)cyl_monthsFrom:(NSDate *)date;
-(NSInteger)cyl_weeksFrom:(NSDate *)date;
-(NSInteger)cyl_daysFrom:(NSDate *)date;
-(double)cyl_hoursFrom:(NSDate *)date;
-(double)cyl_minutesFrom:(NSDate *)date;
-(double)cyl_secondsFrom:(NSDate *)date;
-(NSInteger)cyl_yearsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_monthsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_weeksFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_daysFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_yearsUntil;
-(NSInteger)cyl_monthsUntil;
-(NSInteger)cyl_weeksUntil;
-(NSInteger)cyl_daysUntil;
-(double)cyl_hoursUntil;
-(double)cyl_minutesUntil;
-(double)cyl_secondsUntil;
-(NSInteger)cyl_yearsAgo;
-(NSInteger)cyl_monthsAgo;
-(NSInteger)cyl_weeksAgo;
-(NSInteger)cyl_daysAgo;
-(double)cyl_hoursAgo;
-(double)cyl_minutesAgo;
-(double)cyl_secondsAgo;
-(NSInteger)cyl_yearsEarlierThan:(NSDate *)date;
-(NSInteger)cyl_monthsEarlierThan:(NSDate *)date;
-(NSInteger)cyl_weeksEarlierThan:(NSDate *)date;
-(NSInteger)cyl_daysEarlierThan:(NSDate *)date;
-(double)cyl_hoursEarlierThan:(NSDate *)date;
-(double)cyl_minutesEarlierThan:(NSDate *)date;
-(double)cyl_secondsEarlierThan:(NSDate *)date;
-(NSInteger)cyl_yearsLaterThan:(NSDate *)date;
-(NSInteger)cyl_monthsLaterThan:(NSDate *)date;
-(NSInteger)cyl_weeksLaterThan:(NSDate *)date;
-(NSInteger)cyl_daysLaterThan:(NSDate *)date;
-(double)cyl_hoursLaterThan:(NSDate *)date;
-(double)cyl_minutesLaterThan:(NSDate *)date;
-(double)cyl_secondsLaterThan:(NSDate *)date;
-(BOOL)cyl_isEarlierThan:(NSDate *)date;
-(BOOL)cyl_isLaterThan:(NSDate *)date;
-(BOOL)cyl_isEarlierThanOrEqualTo:(NSDate *)date;
-(BOOL)cyl_isLaterThanOrEqualTo:(NSDate *)date;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style locale:(NSLocale *)locale;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;
+(NSString *)cyl_defaultCalendarIdentifier;
+ (void)cyl_setDefaultCalendarIdentifier:(NSString *)identifier;
```

**Macros**: `DateToolsLocalizedStrings(key)`

### Vendor (VoiceLib)

#### `Mp3Recorder.h`

Path: `ChatKit/Class/Tool/Vendor/VoiceLib/Mp3Recorder.h`

**Class `Mp3Recorder`** : `NSObject`

```objc
@property (nonatomic, weak) id<Mp3RecorderDelegate> delegate;
- (id)initWithDelegate:(id<Mp3RecorderDelegate>)delegate;
- (void)startRecord;
- (void)stopRecord;
- (void)cancelRecord;
```

**Protocol `Mp3RecorderDelegate`** adopts &lt;NSObject&gt;

```objc
- (void)failRecord;
- (void)beginConvert;
- (void)endConvertWithMP3FileName:(NSString *)fileName;
- (void)realTimeVolumeSize:(float)size timeLength:(NSTimeInterval)timeLength;
```

#### `lame.h`

Path: `ChatKit/Class/Tool/Vendor/VoiceLib/lame.framework/Headers/lame.h`

**Enums**

- `vbr_mode` (`enum`): `vbr_off`, `vbr_mt`, `vbr_rh`, `vbr_abr`, `vbr_mtrh`, `vbr_max_indicator`, `vbr_default`
- `MPEG_mode` (`enum`): `STEREO`, `JOINT_STEREO`, `DUAL_CHANNEL`, `MONO`, `NOT_SET`, `MAX_INDICATOR`
- `Padding_type` (`enum`): `PAD_NO`, `PAD_ALL`, `PAD_ADJUST`, `PAD_MAX_INDICATOR`
- `preset_mode` (`enum`): `ABR_8`, `ABR_320`, `V9`, `VBR_10`, `V8`, `VBR_20`, `V7`, `VBR_30`, `V6`, `VBR_40`, `V5`, `VBR_50`, `V4`, `VBR_60`, `V3`, `VBR_70`, `V2`, `VBR_80`, `V1`, `VBR_90`, `V0`, `VBR_100`, `R3MIX`, `STANDARD`, `EXTREME`, `INSANE`, `STANDARD_FAST`, `EXTREME_FAST`, `MEDIUM`, `MEDIUM_FAST`
- `asm_optimizations` (`enum`): `MMX`, `AMD_3DNOW`, `SSE`
- `Psy_model` (`enum`): `PSY_GPSYCHO`, `PSY_NSPSYTUNE`
- `buffer_constraint` (`enum`): `MDB_DEFAULT`, `MDB_STRICT_ISO`, `MDB_MAXIMUM`
- `lame_errorcodes_t` (`enum`): `LAME_OKAY`, `LAME_NOERROR`, `LAME_GENERICERROR`, `LAME_NOMEM`, `LAME_BADBITRATE`, `LAME_BADSAMPFREQ`, `LAME_INTERNALERROR`, `FRONTEND_READERROR`, `FRONTEND_WRITEERROR`, `FRONTEND_FILETOOLARGE`

**Typedefs**

```objc
typedef lame_global_flags * lame_t;
typedef hip_global_flags * hip_t;
```

**Macros**: `LAME_LAME_H`, `CDECL`, `CDECL`, `DEPRECATED_OR_OBSOLETE_CODE_REMOVED`, `LAME_MAXALBUMART`, `LAME_MAXMP3BUFFER`

## Migration from LCCK names

Types, constants, and macros. Members of a renamed type keep their selectors unless listed in the next table.

| Kind | Old | New |
|:---|:---|:---|
| blocks | `LCCKArrayResultBlock` | `CYLArrayResultBlock` |
| blocks | `LCCKAvatarImageViewCornerRadiusBlock` | `CYLAvatarImageViewCornerRadiusBlock` |
| blocks | `LCCKBarButtonItemActionBlock` | `CYLBarButtonItemActionBlock` |
| blocks | `LCCKBooleanResultBlock` | `CYLBooleanResultBlock` |
| blocks | `LCCKCellForRowBlock` | `CYLCellForRowBlock` |
| blocks | `LCCKConfigureCellBlock` | `CYLConfigureCellBlock` |
| blocks | `LCCKConversationEditActionsBlock` | `CYLConversationEditActionsBlock` |
| blocks | `LCCKConversationInvalidedHandler` | `CYLConversationInvalidedHandler` |
| blocks | `LCCKConversationListShowHookBlock` | `CYLConversationListShowHookBlock` |
| blocks | `LCCKConversationListShowHookCompletionHandler` | `CYLConversationListShowHookCompletionHandler` |
| blocks | `LCCKConversationResultBlock` | `CYLConversationResultBlock` |
| blocks | `LCCKDataResultBlock` | `CYLDataResultBlock` |
| blocks | `LCCKDeleteContactCallback` | `CYLDeleteContactCallback` |
| blocks | `LCCKDictionaryResultBlock` | `CYLDictionaryResultBlock` |
| blocks | `LCCKDidDeleteConversationsListCellBlock` | `CYLDidDeleteConversationsListCellBlock` |
| blocks | `LCCKDidSelectConversationsListCellBlock` | `CYLDidSelectConversationsListCellBlock` |
| blocks | `LCCKErrorBlock` | `CYLErrorBlock` |
| blocks | `LCCKFetchConversationHandler` | `CYLFetchConversationHandler` |
| blocks | `LCCKFetchProfilesBlock` | `CYLFetchProfilesBlock` |
| blocks | `LCCKFetchProfilesCompletionHandler` | `CYLFetchProfilesCompletionHandler` |
| blocks | `LCCKFilterMessagesBlock` | `CYLFilterMessagesBlock` |
| blocks | `LCCKFilterMessagesCompletionHandler` | `CYLFilterMessagesCompletionHandler` |
| blocks | `LCCKFirstLaunchBlock` | `CYLFirstLaunchBlock` |
| blocks | `LCCKForceReconnectSessionBlock` | `CYLForceReconnectSessionBlock` |
| blocks | `LCCKGenerateSignatureBlock` | `CYLGenerateSignatureBlock` |
| blocks | `LCCKGenerateSignatureCompletionHandler` | `CYLGenerateSignatureCompletionHandler` |
| blocks | `LCCKHUDActionBlock` | `CYLHUDActionBlock` |
| blocks | `LCCKHeightForRowBlock` | `CYLHeightForRowBlock` |
| blocks | `LCCKIdBoolResultBlock` | `CYLIdBoolResultBlock` |
| blocks | `LCCKIdResultBlock` | `CYLIdResultBlock` |
| blocks | `LCCKImageResultBlock` | `CYLImageResultBlock` |
| blocks | `LCCKIntegerResultBlock` | `CYLIntegerResultBlock` |
| blocks | `LCCKLoadLatestMessagesHandler` | `CYLLoadLatestMessagesHandler` |
| blocks | `LCCKLongPressMessageBlock` | `CYLLongPressMessageBlock` |
| blocks | `LCCKMarkBadgeWithTotalUnreadCountBlock` | `CYLMarkBadgeWithTotalUnreadCountBlock` |
| blocks | `LCCKOnNewMessageBlock` | `CYLOnNewMessageBlock` |
| blocks | `LCCKOpenProfileBlock` | `CYLOpenProfileBlock` |
| blocks | `LCCKPrepareConversationsWhenLoadBlock` | `CYLPrepareConversationsWhenLoadBlock` |
| blocks | `LCCKPreviewImageMessageBlock` | `CYLPreviewImageMessageBlock` |
| blocks | `LCCKPreviewLocationMessageBlock` | `CYLPreviewLocationMessageBlock` |
| blocks | `LCCKProgressBlock` | `CYLProgressBlock` |
| blocks | `LCCKProgressUpdateBlock` | `CYLProgressUpdateBlock` |
| blocks | `LCCKRecentConversationsCallback` | `CYLRecentConversationsCallback` |
| blocks | `LCCKReconnectSessionCompletionHandler` | `CYLReconnectSessionCompletionHandler` |
| blocks | `LCCKRemoveFromWindowHandler` | `CYLRemoveFromWindowHandler` |
| blocks | `LCCKRequestAuthorizationBoolResultBlock` | `CYLRequestAuthorizationBoolResultBlock` |
| blocks | `LCCKSelectedContactCallback` | `CYLSelectedContactCallback` |
| blocks | `LCCKSelectedContactsCallback` | `CYLSelectedContactsCallback` |
| blocks | `LCCKSendMessageHookBlock` | `CYLSendMessageHookBlock` |
| blocks | `LCCKSendMessageHookCompletionHandler` | `CYLSendMessageHookCompletionHandler` |
| blocks | `LCCKSendMessageSuccessBlock` | `CYLSendMessageSuccessBlock` |
| blocks | `LCCKSendMessageSuccessFailedBlock` | `CYLSendMessageSuccessFailedBlock` |
| blocks | `LCCKSetResultBlock` | `CYLSetResultBlock` |
| blocks | `LCCKShouldDisplayTimestampCallBack` | `CYLShouldDisplayTimestampCallBack` |
| blocks | `LCCKShowNotificationBlock` | `CYLShowNotificationBlock` |
| blocks | `LCCKStringResultBlock` | `CYLStringResultBlock` |
| blocks | `LCCKUnreadCountChangedBlock` | `CYLUnreadCountChangedBlock` |
| blocks | `LCCKUserResultCallBack` | `CYLUserResultCallBack` |
| blocks | `LCCKUserResultsCallBack` | `CYLUserResultsCallBack` |
| blocks | `LCCKViewActionBlock` | `CYLViewActionBlock` |
| blocks | `LCCKViewControllerBooleanResultBlock` | `CYLViewControllerBooleanResultBlock` |
| blocks | `LCCKViewControllerWillDeallocBlock` | `CYLViewControllerWillDeallocBlock` |
| blocks | `LCCKViewDidAppearBlock` | `CYLViewDidAppearBlock` |
| blocks | `LCCKViewDidDisappearBlock` | `CYLViewDidDisappearBlock` |
| blocks | `LCCKViewDidDismissBlock` | `CYLViewDidDismissBlock` |
| blocks | `LCCKViewDidLoadBlock` | `CYLViewDidLoadBlock` |
| blocks | `LCCKViewDidReceiveMemoryWarningBlock` | `CYLViewDidReceiveMemoryWarningBlock` |
| blocks | `LCCKViewWillAppearBlock` | `CYLViewWillAppearBlock` |
| blocks | `LCCKViewWillDisappearBlock` | `CYLViewWillDisappearBlock` |
| blocks | `LCCKVoidBlock` | `CYLVoidBlock` |
| blocks | `LCCKWeakReference` | `CYLWeakReference` |
| blocks | `LCCKWebViewProgressBlock` | `CYLWebViewProgressBlock` |
| case | `LCCKAlertActionStyleCancel` | `CYLAlertActionStyleCancel` |
| case | `LCCKAlertActionStyleDefault` | `CYLAlertActionStyleDefault` |
| case | `LCCKAlertActionStyleDestructive` | `CYLAlertActionStyleDestructive` |
| case | `LCCKAlertControllerStyleActionSheet` | `CYLAlertControllerStyleActionSheet` |
| case | `LCCKAlertControllerStyleAlert` | `CYLAlertControllerStyleAlert` |
| case | `LCCKBadgeViewAlignmentBottomCenter` | `CYLBadgeViewAlignmentBottomCenter` |
| case | `LCCKBadgeViewAlignmentBottomLeft` | `CYLBadgeViewAlignmentBottomLeft` |
| case | `LCCKBadgeViewAlignmentBottomRight` | `CYLBadgeViewAlignmentBottomRight` |
| case | `LCCKBadgeViewAlignmentCenter` | `CYLBadgeViewAlignmentCenter` |
| case | `LCCKBadgeViewAlignmentCenterLeft` | `CYLBadgeViewAlignmentCenterLeft` |
| case | `LCCKBadgeViewAlignmentCenterRight` | `CYLBadgeViewAlignmentCenterRight` |
| case | `LCCKBadgeViewAlignmentTopCenter` | `CYLBadgeViewAlignmentTopCenter` |
| case | `LCCKBadgeViewAlignmentTopLeft` | `CYLBadgeViewAlignmentTopLeft` |
| case | `LCCKBadgeViewAlignmentTopRight` | `CYLBadgeViewAlignmentTopRight` |
| case | `LCCKBarButtonItemStyleAdd` | `CYLBarButtonItemStyleAdd` |
| case | `LCCKBarButtonItemStyleAddFriends` | `CYLBarButtonItemStyleAddFriends` |
| case | `LCCKBarButtonItemStyleGroupProfile` | `CYLBarButtonItemStyleGroupProfile` |
| case | `LCCKBarButtonItemStyleMore` | `CYLBarButtonItemStyleMore` |
| case | `LCCKBarButtonItemStyleSetting` | `CYLBarButtonItemStyleSetting` |
| case | `LCCKBarButtonItemStyleShare` | `CYLBarButtonItemStyleShare` |
| case | `LCCKBarButtonItemStyleSingleProfile` | `CYLBarButtonItemStyleSingleProfile` |
| case | `LCCKBubbleMessageMenuSelectedTypePhotoCopy` | `CYLBubbleMessageMenuSelectedTypePhotoCopy` |
| case | `LCCKBubbleMessageMenuSelectedTypePhotoFavorites` | `CYLBubbleMessageMenuSelectedTypePhotoFavorites` |
| case | `LCCKBubbleMessageMenuSelectedTypePhotoMore` | `CYLBubbleMessageMenuSelectedTypePhotoMore` |
| case | `LCCKBubbleMessageMenuSelectedTypePhotoTranspond` | `CYLBubbleMessageMenuSelectedTypePhotoTranspond` |
| case | `LCCKBubbleMessageMenuSelectedTypeTextCopy` | `CYLBubbleMessageMenuSelectedTypeTextCopy` |
| case | `LCCKBubbleMessageMenuSelectedTypeTextFavorites` | `CYLBubbleMessageMenuSelectedTypeTextFavorites` |
| case | `LCCKBubbleMessageMenuSelectedTypeTextMore` | `CYLBubbleMessageMenuSelectedTypeTextMore` |
| case | `LCCKBubbleMessageMenuSelectedTypeTextTranspond` | `CYLBubbleMessageMenuSelectedTypeTextTranspond` |
| case | `LCCKBubbleMessageMenuSelectedTypeVideoFavorites` | `CYLBubbleMessageMenuSelectedTypeVideoFavorites` |
| case | `LCCKBubbleMessageMenuSelectedTypeVideoMore` | `CYLBubbleMessageMenuSelectedTypeVideoMore` |
| case | `LCCKBubbleMessageMenuSelectedTypeVideoTranspond` | `CYLBubbleMessageMenuSelectedTypeVideoTranspond` |
| case | `LCCKBubbleMessageMenuSelectedTypeVoiceFavorites` | `CYLBubbleMessageMenuSelectedTypeVoiceFavorites` |
| case | `LCCKBubbleMessageMenuSelectedTypeVoiceMore` | `CYLBubbleMessageMenuSelectedTypeVoiceMore` |
| case | `LCCKBubbleMessageMenuSelectedTypeVoicePlay` | `CYLBubbleMessageMenuSelectedTypeVoicePlay` |
| case | `LCCKBubbleMessageMenuSelectedTypeVoiceTurnToText` | `CYLBubbleMessageMenuSelectedTypeVoiceTurnToText` |
| case | `LCCKChatMessageCellMenuActionTypeCopy` | `CYLChatMessageCellMenuActionTypeCopy` |
| case | `LCCKChatMessageCellMenuActionTypeRelay` | `CYLChatMessageCellMenuActionTypeRelay` |
| case | `LCCKContactListModeMultipleSelection` | `CYLContactListModeMultipleSelection` |
| case | `LCCKContactListModeNormal` | `CYLContactListModeNormal` |
| case | `LCCKContactListModeSingleSelection` | `CYLContactListModeSingleSelection` |
| case | `LCCKConversationTypeGroup` | `CYLConversationTypeGroup` |
| case | `LCCKConversationTypeSingle` | `CYLConversationTypeSingle` |
| case | `LCCKFunctionViewShowFace` | `CYLFunctionViewShowFace` |
| case | `LCCKFunctionViewShowKeyboard` | `CYLFunctionViewShowKeyboard` |
| case | `LCCKFunctionViewShowMore` | `CYLFunctionViewShowMore` |
| case | `LCCKFunctionViewShowNothing` | `CYLFunctionViewShowNothing` |
| case | `LCCKFunctionViewShowVoice` | `CYLFunctionViewShowVoice` |
| case | `LCCKInputViewPluginTypeDefault` | `CYLInputViewPluginTypeDefault` |
| case | `LCCKInputViewPluginTypeLocation` | `CYLInputViewPluginTypeLocation` |
| case | `LCCKInputViewPluginTypePickImage` | `CYLInputViewPluginTypePickImage` |
| case | `LCCKInputViewPluginTypeShortVideo` | `CYLInputViewPluginTypeShortVideo` |
| case | `LCCKInputViewPluginTypeTakePhoto` | `CYLInputViewPluginTypeTakePhoto` |
| case | `LCCKMessageHUDActionTypeError` | `CYLMessageHUDActionTypeError` |
| case | `LCCKMessageHUDActionTypeHide` | `CYLMessageHUDActionTypeHide` |
| case | `LCCKMessageHUDActionTypeShow` | `CYLMessageHUDActionTypeShow` |
| case | `LCCKMessageHUDActionTypeSuccess` | `CYLMessageHUDActionTypeSuccess` |
| case | `LCCKMessageNotificationTypeError` | `CYLMessageNotificationTypeError` |
| case | `LCCKMessageNotificationTypeMessage` | `CYLMessageNotificationTypeMessage` |
| case | `LCCKMessageNotificationTypeSuccess` | `CYLMessageNotificationTypeSuccess` |
| case | `LCCKMessageNotificationTypeWarning` | `CYLMessageNotificationTypeWarning` |
| case | `LCCKMessageOwnerTypeOther` | `CYLMessageOwnerTypeOther` |
| case | `LCCKMessageOwnerTypeSelf` | `CYLMessageOwnerTypeSelf` |
| case | `LCCKMessageOwnerTypeSystem` | `CYLMessageOwnerTypeSystem` |
| case | `LCCKMessageOwnerTypeUnknown` | `CYLMessageOwnerTypeUnknown` |
| case | `LCCKMessageReaded` | `CYLMessageReaded` |
| case | `LCCKMessageReading` | `CYLMessageReading` |
| case | `LCCKMessageSendStateDelivered` | `CYLMessageSendStateDelivered` |
| case | `LCCKMessageSendStateFailed` | `CYLMessageSendStateFailed` |
| case | `LCCKMessageSendStateNone` | `CYLMessageSendStateNone` |
| case | `LCCKMessageSendStateRead` | `CYLMessageSendStateRead` |
| case | `LCCKMessageSendStateSending` | `CYLMessageSendStateSending` |
| case | `LCCKMessageSendStateSent` | `CYLMessageSendStateSent` |
| case | `LCCKMessageUnRead` | `CYLMessageUnRead` |
| case | `LCCKProgressError` | `CYLProgressError` |
| case | `LCCKProgressMessage` | `CYLProgressMessage` |
| case | `LCCKProgressOverTime` | `CYLProgressOverTime` |
| case | `LCCKProgressShort` | `CYLProgressShort` |
| case | `LCCKProgressSuccess` | `CYLProgressSuccess` |
| case | `LCCKRecoderResultStateCancel` | `CYLRecoderResultStateCancel` |
| case | `LCCKRecoderResultStateFail` | `CYLRecoderResultStateFail` |
| case | `LCCKRecoderResultStateLong` | `CYLRecoderResultStateLong` |
| case | `LCCKRecoderResultStateShort` | `CYLRecoderResultStateShort` |
| case | `LCCKRecoderResultStateSuccess` | `CYLRecoderResultStateSuccess` |
| case | `LCCKRecordProgressStateInSide` | `CYLRecordProgressStateInSide` |
| case | `LCCKRecordProgressStateOutSide` | `CYLRecordProgressStateOutSide` |
| case | `LCCKScrollDirectionCrazy` | `CYLScrollDirectionCrazy` |
| case | `LCCKScrollDirectionDown` | `CYLScrollDirectionDown` |
| case | `LCCKScrollDirectionLeft` | `CYLScrollDirectionLeft` |
| case | `LCCKScrollDirectionNone` | `CYLScrollDirectionNone` |
| case | `LCCKScrollDirectionRight` | `CYLScrollDirectionRight` |
| case | `LCCKScrollDirectionUp` | `CYLScrollDirectionUp` |
| case | `LCCKShowEmojiFace` | `CYLShowEmojiFace` |
| case | `LCCKShowGifFace` | `CYLShowGifFace` |
| case | `LCCKShowRecentFace` | `CYLShowRecentFace` |
| case | `LCCKSwipeViewAlignmentCenter` | `CYLSwipeViewAlignmentCenter` |
| case | `LCCKSwipeViewAlignmentEdge` | `CYLSwipeViewAlignmentEdge` |
| case | `LCCKViewControllerStylePlain` | `CYLViewControllerStylePlain` |
| case | `LCCKViewControllerStylePresenting` | `CYLViewControllerStylePresenting` |
| case | `LCCKVoiceMessageStateCancel` | `CYLVoiceMessageStateCancel` |
| case | `LCCKVoiceMessageStateDownloading` | `CYLVoiceMessageStateDownloading` |
| case | `LCCKVoiceMessageStateNormal` | `CYLVoiceMessageStateNormal` |
| case | `LCCKVoiceMessageStatePlaying` | `CYLVoiceMessageStatePlaying` |
| category | `LCCKAlertController(Convenience)` | `CYLAlertController(Convenience)` |
| category | `LCCKAlertController(Internal)` | `CYLAlertController(Internal)` |
| category | `LCCKConversationService(LCCKDeprecated)` | `CYLConversationService(CYLDeprecated)` |
| category | `LCChatKit(LCCKServices)` | `LCChatKit(CYLServices)` |
| category | `NSBundle(LCCKExtension)` | `NSBundle(CYLExtension)` |
| category | `NSBundle(LCCKSCaleArray)` | `NSBundle(CYLSCaleArray)` |
| category | `NSFileManager(LCCKExtension)` | `NSFileManager(CYLExtension)` |
| category | `NSMutableArray(LCCKMessageExtention)` | `NSMutableArray(CYLMessageExtention)` |
| category | `NSMutableDictionary(LCCKWeakReference)` | `NSMutableDictionary(CYLWeakReference)` |
| category | `NSObject(LCCKExtension)` | `NSObject(CYLExtension)` |
| category | `NSObject(LCCKIsFirstLaunch)` | `NSObject(CYLIsFirstLaunch)` |
| category | `NSString(LCCKAddScale)` | `NSString(CYLAddScale)` |
| category | `NSString(LCCKExtension)` | `NSString(CYLExtension)` |
| category | `NSString(LCCKMD5)` | `NSString(CYLMD5)` |
| category | `UIColor(LCCKExtension)` | `UIColor(CYLExtension)` |
| category | `UIImage(LCCKExtension)` | `UIImage(CYLExtension)` |
| category | `UIImageView(LCCKExtension)` | `UIImageView(CYLExtension)` |
| category | `UITableViewRowAction(LCCKExtension)` | `UITableViewRowAction(CYLExtension)` |
| category | `UIView(LCCKExtension)` | `UIView(CYLExtension)` |
| class | `LCCKAVAudioPlayer` | `CYLAVAudioPlayer` |
| class | `LCCKAlertAction` | `CYLAlertAction` |
| class | `LCCKAlertController` | `CYLAlertController` |
| class | `LCCKBadgeView` | `CYLBadgeView` |
| class | `LCCKBaseConversationViewController` | `CYLBaseConversationViewController` |
| class | `LCCKBaseNavigationController` | `CYLChatBaseNavigationController` |
| class | `LCCKBaseTableViewController` | `CYLChatBaseTableViewController` |
| class | `LCCKBaseViewController` | `CYLChatBaseViewController` |
| class | `LCCKBubbleImageFactory` | `CYLBubbleImageFactory` |
| class | `LCCKCaptionView` | `CYLCaptionView` |
| class | `LCCKCellIdentifierFactory` | `CYLCellIdentifierFactory` |
| class | `LCCKCellRegisterController` | `CYLCellRegisterController` |
| class | `LCCKChatBar` | `CYLChatBar` |
| class | `LCCKChatFaceView` | `CYLChatFaceView` |
| class | `LCCKChatImageMessageCell` | `CYLChatImageMessageCell` |
| class | `LCCKChatLocationMessageCell` | `CYLChatLocationMessageCell` |
| class | `LCCKChatMessageCell` | `CYLChatMessageCell` |
| class | `LCCKChatMoreItem` | `CYLChatMoreItem` |
| class | `LCCKChatMoreView` | `CYLChatMoreView` |
| class | `LCCKChatSystemMessageCell` | `CYLChatSystemMessageCell` |
| class | `LCCKChatTextMessageCell` | `CYLChatTextMessageCell` |
| class | `LCCKChatVoiceMessageCell` | `CYLChatVoiceMessageCell` |
| class | `LCCKCommonUtils` | `CYLCommonUtils` |
| class | `LCCKContact` | `CYLContact` |
| class | `LCCKContactCell` | `CYLContactCell` |
| class | `LCCKContactListViewController` | `CYLContactListViewController` |
| class | `LCCKContentView` | `CYLContentView` |
| class | `LCCKConversationListCell` | `CYLConversationListCell` |
| class | `LCCKConversationListService` | `CYLConversationListService` |
| class | `LCCKConversationListViewController` | `CYLConversationListViewController` |
| class | `LCCKConversationListViewModel` | `CYLConversationListViewModel` |
| class | `LCCKConversationNavigationTitleView` | `CYLConversationNavigationTitleView` |
| class | `LCCKConversationRefreshHeader` | `CYLConversationRefreshHeader` |
| class | `LCCKConversationService` | `CYLConversationService` |
| class | `LCCKConversationViewController` | `CYLConversationViewController` |
| class | `LCCKConversationViewModel` | `CYLConversationViewModel` |
| class | `LCCKError` | `CYLError` |
| class | `LCCKFaceManager` | `CYLFaceManager` |
| class | `LCCKFacePageView` | `CYLFacePageView` |
| class | `LCCKImageManager` | `CYLImageManager` |
| class | `LCCKInputViewPlugin` | `CYLInputViewPlugin` |
| class | `LCCKInputViewPluginLocation` | `CYLInputViewPluginLocation` |
| class | `LCCKInputViewPluginPickImage` | `CYLInputViewPluginPickImage` |
| class | `LCCKInputViewPluginTakePhoto` | `CYLInputViewPluginTakePhoto` |
| class | `LCCKLastMessageTypeManager` | `CYLLastMessageTypeManager` |
| class | `LCCKLocationController` | `CYLLocationController` |
| class | `LCCKLocationManager` | `CYLLocationManager` |
| class | `LCCKMenuItem` | `CYLMenuItem` |
| class | `LCCKMessage` | `CYLMessage` |
| class | `LCCKMessageSendStateView` | `CYLMessageSendStateView` |
| class | `LCCKMessageVoiceFactory` | `CYLMessageVoiceFactory` |
| class | `LCCKPhoto` | `CYLPhoto` |
| class | `LCCKPhotoBrowser` | `CYLPhotoBrowser` |
| class | `LCCKProgressHUD` | `CYLProgressHUD` |
| class | `LCCKRecordAudioHUD` | `CYLRecordAudioHUD` |
| class | `LCCKSafariActivity` | `CYLSafariActivity` |
| class | `LCCKSendImageView` | `CYLSendImageView` |
| class | `LCCKSessionService` | `CYLSessionService` |
| class | `LCCKSettingService` | `CYLSettingService` |
| class | `LCCKSignatureService` | `CYLSignatureService` |
| class | `LCCKSingleton` | `CYLSingleton` |
| class | `LCCKSoundManager` | `CYLSoundManager` |
| class | `LCCKStatusView` | `CYLStatusView` |
| class | `LCCKSwipeView` | `CYLSwipeView` |
| class | `LCCKTapDetectingImageView` | `CYLTapDetectingImageView` |
| class | `LCCKTapDetectingView` | `CYLTapDetectingView` |
| class | `LCCKTextFullScreenViewController` | `CYLTextFullScreenViewController` |
| class | `LCCKUIService` | `CYLUIService` |
| class | `LCCKUserSystemService` | `CYLUserSystemService` |
| class | `LCCKWebViewController` | `CYLWebViewController` |
| class | `LCCKWebViewProgress` | `CYLWebViewProgress` |
| class | `LCCKWebViewProgressView` | `CYLWebViewProgressView` |
| class | `LCCKZoomingScrollView` | `CYLZoomingScrollView` |
| constants | `LCCKAnimateDuration` | `CYLAnimateDuration` |
| constants | `LCCKAvatarBottomToMessageContentTop` | `CYLAvatarBottomToMessageContentTop` |
| constants | `LCCKAvatarToMessageContent` | `CYLAvatarToMessageContent` |
| constants | `LCCKBadgeTextForNumberGreaterThanLimit` | `CYLBadgeTextForNumberGreaterThanLimit` |
| constants | `LCCKCellIdentifierCustom` | `CYLCellIdentifierCustom` |
| constants | `LCCKCellIdentifierDefault` | `CYLCellIdentifierDefault` |
| constants | `LCCKCellIdentifierGroup` | `CYLCellIdentifierGroup` |
| constants | `LCCKCellIdentifierOwnerOther` | `CYLCellIdentifierOwnerOther` |
| constants | `LCCKCellIdentifierOwnerSelf` | `CYLCellIdentifierOwnerSelf` |
| constants | `LCCKCellIdentifierOwnerSystem` | `CYLCellIdentifierOwnerSystem` |
| constants | `LCCKCellIdentifierSingle` | `CYLCellIdentifierSingle` |
| constants | `LCCKChatBarBottomOffset` | `CYLChatBarBottomOffset` |
| constants | `LCCKChatBarTextViewBottomOffset` | `CYLChatBarTextViewBottomOffset` |
| constants | `LCCKChatMessageCellMediaTypeDict` | `CYLChatMessageCellMediaTypeDict` |
| constants | `LCCKConversationListCellDefaultHeight` | `CYLConversationListCellDefaultHeight` |
| constants | `LCCKConversationServiceErrorDomain` | `CYLConversationServiceErrorDomain` |
| constants | `LCCKConversationViewControllerErrorDomain` | `CYLConversationViewControllerErrorDomain` |
| constants | `LCCKCustomConversationViewControllerBackgroundImageNamePrefix` | `CYLCustomConversationViewControllerBackgroundImageNamePrefix` |
| constants | `LCCKCustomMessageConversationTypeKey` | `CYLCustomMessageConversationTypeKey` |
| constants | `LCCKCustomMessageDegradeKey` | `CYLCustomMessageDegradeKey` |
| constants | `LCCKCustomMessageIsCustomKey` | `CYLCustomMessageIsCustomKey` |
| constants | `LCCKCustomMessageOnlyVisiableForPartClientIds` | `CYLCustomMessageOnlyVisiableForPartClientIds` |
| constants | `LCCKCustomMessageSummaryKey` | `CYLCustomMessageSummaryKey` |
| constants | `LCCKCustomMessageTypeTitleKey` | `CYLCustomMessageTypeTitleKey` |
| constants | `LCCKDefaultConversationViewControllerBackgroundImageName` | `CYLDefaultConversationViewControllerBackgroundImageName` |
| constants | `LCCKDidReceiveCustomMessageUserInfoMessageKey` | `CYLDidReceiveCustomMessageUserInfoMessageKey` |
| constants | `LCCKDidReceiveMessagesUserInfoMessagesKey` | `CYLDidReceiveMessagesUserInfoMessagesKey` |
| constants | `LCCKErrorDomain` | `CYLErrorDomain` |
| constants | `LCCKFinalProgressValue` | `CYLFinalProgressValue` |
| constants | `LCCKInitialProgressValue` | `CYLInitialProgressValue` |
| constants | `LCCKInputViewPluginArray` | `CYLInputViewPluginArray` |
| constants | `LCCKInputViewPluginClassKey` | `CYLInputViewPluginClassKey` |
| constants | `LCCKInputViewPluginDict` | `CYLInputViewPluginDict` |
| constants | `LCCKInputViewPluginTypeKey` | `CYLInputViewPluginTypeKey` |
| constants | `LCCKInstallationKeyChannels` | `CYLInstallationKeyChannels` |
| constants | `LCCKInteractiveProgressValue` | `CYLInteractiveProgressValue` |
| constants | `LCCKMessageNotifacationUserInfoConversationKey` | `CYLMessageNotifacationUserInfoConversationKey` |
| constants | `LCCKMessageNotifacationUserInfoMessageKey` | `CYLMessageNotifacationUserInfoMessageKey` |
| constants | `LCCKNotificationConnectivityUpdated` | `CYLNotificationConnectivityUpdated` |
| constants | `LCCKNotificationContactListDataSourceContactObjType` | `CYLNotificationContactListDataSourceContactObjType` |
| constants | `LCCKNotificationContactListDataSourceUpdated` | `CYLNotificationContactListDataSourceUpdated` |
| constants | `LCCKNotificationContactListDataSourceUpdatedUserInfoDataSourceKey` | `CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceKey` |
| constants | `LCCKNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey` | `CYLNotificationContactListDataSourceUpdatedUserInfoDataSourceTypeKey` |
| constants | `LCCKNotificationContactListDataSourceUserIdType` | `CYLNotificationContactListDataSourceUserIdType` |
| constants | `LCCKNotificationConversationInvalided` | `CYLNotificationConversationInvalided` |
| constants | `LCCKNotificationConversationListDataSourceUpdated` | `CYLNotificationConversationListDataSourceUpdated` |
| constants | `LCCKNotificationConversationUpdated` | `CYLNotificationConversationUpdated` |
| constants | `LCCKNotificationConversationViewControllerBackgroundImageDidChanged` | `CYLNotificationConversationViewControllerBackgroundImageDidChanged` |
| constants | `LCCKNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey` | `CYLNotificationConversationViewControllerBackgroundImageDidChangedUserInfoConversationIdKey` |
| constants | `LCCKNotificationConversionImageMessageDidDownloaded` | `CYLNotificationConversionImageMessageDidDownloaded` |
| constants | `LCCKNotificationCurrentConversationInvalided` | `CYLNotificationCurrentConversationInvalided` |
| constants | `LCCKNotificationCustomMessageReceived` | `CYLNotificationCustomMessageReceived` |
| constants | `LCCKNotificationCustomTransientMessageReceived` | `CYLNotificationCustomTransientMessageReceived` |
| constants | `LCCKNotificationMessageDelivered` | `CYLNotificationMessageDelivered` |
| constants | `LCCKNotificationMessageRead` | `CYLNotificationMessageRead` |
| constants | `LCCKNotificationMessageReceived` | `CYLNotificationMessageReceived` |
| constants | `LCCKNotificationMessageSent` | `CYLNotificationMessageSent` |
| constants | `LCCKNotificationMessageUpdated` | `CYLNotificationMessageUpdated` |
| constants | `LCCKNotificationRecordNoPower` | `CYLNotificationRecordNoPower` |
| constants | `LCCKNotificationRecordTimeOut` | `CYLNotificationRecordTimeOut` |
| constants | `LCCKNotificationSessionResumed` | `CYLNotificationSessionResumed` |
| constants | `LCCKNotificationTextLengthOut` | `CYLNotificationTextLengthOut` |
| constants | `LCCKNotificationTextLengthOutLength` | `CYLNotificationTextLengthOutLength` |
| constants | `LCCKNotificationUnreadsUpdated` | `CYLNotificationUnreadsUpdated` |
| constants | `LCCKPhoneRegex` | `CYLPhoneRegex` |
| constants | `LCCKSessionServiceErrorDemain` | `CYLSessionServiceErrorDemain` |
| constants | `LCCKSettingServiceErrorDomain` | `CYLSettingServiceErrorDomain` |
| constants | `LCCKSignatureServiceErrorDomain` | `CYLSignatureServiceErrorDomain` |
| constants | `LCCKStatusViewHight` | `CYLStatusViewHight` |
| constants | `LCCKUIServiceErrorDomain` | `CYLUIServiceErrorDomain` |
| constants | `LCCKURLRegex` | `CYLURLRegex` |
| constants | `LCCKUserSystemServiceErrorDomain` | `CYLUserSystemServiceErrorDomain` |
| constants | `LCCK_CONVERSATION_TYPE` | `CYL_CONVERSATION_TYPE` |
| constants | `LCCK_MSG_CELL_EDGES_OFFSET` | `CYL_MSG_CELL_EDGES_OFFSET` |
| constants | `kAVIMMessageMediaTypeSystem` | `kCYLIMMessageMediaTypeSystem` |
| constants | `kLCCKBatchDeleteTextPrefix` | `kCYLBatchDeleteTextPrefix` |
| constants | `kLCCKBatchDeleteTextSuffix` | `kCYLBatchDeleteTextSuffix` |
| constants | `kLCCKChatBarMaxHeight` | `kCYLChatBarMaxHeight` |
| constants | `kLCCKChatBarMinHeight` | `kCYLChatBarMinHeight` |
| constants | `kLCCKChatBarTextViewFrameMaxHeight` | `kCYLChatBarTextViewFrameMaxHeight` |
| constants | `kLCCKChatBarTextViewFrameMinHeight` | `kCYLChatBarTextViewFrameMinHeight` |
| constants | `kLCCKMessageConfigurationAvatorKey` | `kCYLMessageConfigurationAvatorKey` |
| constants | `kLCCKMessageConfigurationGroupKey` | `kCYLMessageConfigurationGroupKey` |
| constants | `kLCCKMessageConfigurationImageKey` | `kCYLMessageConfigurationImageKey` |
| constants | `kLCCKMessageConfigurationLocationKey` | `kCYLMessageConfigurationLocationKey` |
| constants | `kLCCKMessageConfigurationNicknameKey` | `kCYLMessageConfigurationNicknameKey` |
| constants | `kLCCKMessageConfigurationOwnerKey` | `kCYLMessageConfigurationOwnerKey` |
| constants | `kLCCKMessageConfigurationReadStateKey` | `kCYLMessageConfigurationReadStateKey` |
| constants | `kLCCKMessageConfigurationSendStateKey` | `kCYLMessageConfigurationSendStateKey` |
| constants | `kLCCKMessageConfigurationTextKey` | `kCYLMessageConfigurationTextKey` |
| constants | `kLCCKMessageConfigurationTypeKey` | `kCYLMessageConfigurationTypeKey` |
| constants | `kLCCKMessageConfigurationVoiceKey` | `kCYLMessageConfigurationVoiceKey` |
| constants | `kLCCKMessageConfigurationVoiceSecondsKey` | `kCYLMessageConfigurationVoiceSecondsKey` |
| constants | `kLCCKOnePageSize` | `kCYLOnePageSize` |
| constants | `kLCCKVolumeMaxTimeLength` | `kCYLVolumeMaxTimeLength` |
| enum | `LCCKAlertActionStyle` | `CYLAlertActionStyle` |
| enum | `LCCKAlertControllerStyle` | `CYLAlertControllerStyle` |
| enum | `LCCKBadgeViewAlignment` | `CYLBadgeViewAlignment` |
| enum | `LCCKBarButtonItemStyle` | `CYLBarButtonItemStyle` |
| enum | `LCCKBubbleMessageMenuSelectedType` | `CYLBubbleMessageMenuSelectedType` |
| enum | `LCCKChatMessageCellMenuActionType` | `CYLChatMessageCellMenuActionType` |
| enum | `LCCKContactListMode` | `CYLContactListMode` |
| enum | `LCCKConversationType` | `CYLConversationType` |
| enum | `LCCKFunctionViewShowType` | `CYLFunctionViewShowType` |
| enum | `LCCKInputViewPluginType` | `CYLInputViewPluginType` |
| enum | `LCCKMessageHUDActionType` | `CYLMessageHUDActionType` |
| enum | `LCCKMessageNotificationType` | `CYLMessageNotificationType` |
| enum | `LCCKMessageOwnerType` | `CYLMessageOwnerType` |
| enum | `LCCKMessageReadState` | `CYLMessageReadState` |
| enum | `LCCKMessageSendState` | `CYLMessageSendState` |
| enum | `LCCKProgressState` | `CYLProgressState` |
| enum | `LCCKRecordProgressState` | `CYLRecordProgressState` |
| enum | `LCCKRecordResultState` | `CYLRecordResultState` |
| enum | `LCCKScrollDirection` | `CYLScrollDirection` |
| enum | `LCCKShowFaceViewType` | `CYLShowFaceViewType` |
| enum | `LCCKSwipeViewAlignment` | `CYLSwipeViewAlignment` |
| enum | `LCCKViewControllerStyle` | `CYLViewControllerStyle` |
| enum | `LCCKVoiceMessageState` | `CYLVoiceMessageState` |
| macro | `LCCKChatUntiles_h` | `CYLChatUntiles_h` |
| macro | `LCCKChat_h` | `CYLChat_h` |
| macro | `LCCKConversationGroupAvatarURLKey` | `CYLConversationGroupAvatarURLKey` |
| macro | `LCCKConversationTableDeleteSQL` | `CYLConversationTableDeleteSQL` |
| macro | `LCCKConversationTableIncreaseOneUnreadCountSQL` | `CYLConversationTableIncreaseOneUnreadCountSQL` |
| macro | `LCCKConversationTableIncreaseUnreadCountSQL` | `CYLConversationTableIncreaseUnreadCountSQL` |
| macro | `LCCKConversationTableInsertSQL` | `CYLConversationTableInsertSQL` |
| macro | `LCCKConversationTableKeyData` | `CYLConversationTableKeyData` |
| macro | `LCCKConversationTableKeyDraft` | `CYLConversationTableKeyDraft` |
| macro | `LCCKConversationTableKeyId` | `CYLConversationTableKeyId` |
| macro | `LCCKConversationTableKeyMentioned` | `CYLConversationTableKeyMentioned` |
| macro | `LCCKConversationTableKeyUnreadCount` | `CYLConversationTableKeyUnreadCount` |
| macro | `LCCKConversationTableName` | `CYLConversationTableName` |
| macro | `LCCKConversationTableSelectDraftSQL` | `CYLConversationTableSelectDraftSQL` |
| macro | `LCCKConversationTableSelectOneSQL` | `CYLConversationTableSelectOneSQL` |
| macro | `LCCKConversationTableSelectSQL` | `CYLConversationTableSelectSQL` |
| macro | `LCCKConversationTableUpdateDataSQL` | `CYLConversationTableUpdateDataSQL` |
| macro | `LCCKConversationTableUpdateDraftSQL` | `CYLConversationTableUpdateDraftSQL` |
| macro | `LCCKConversationTableUpdateMentionedSQL` | `CYLConversationTableUpdateMentionedSQL` |
| macro | `LCCKConversationTableUpdateUnreadCountSQL` | `CYLConversationTableUpdateUnreadCountSQL` |
| macro | `LCCKConversationTableWhereClause` | `CYLConversationTableWhereClause` |
| macro | `LCCKConversatoinTableCreateSQL` | `CYLConversatoinTableCreateSQL` |
| macro | `LCCKCreateTableSQL` | `CYLCreateTableSQL` |
| macro | `LCCKDeleteConversationTable` | `CYLDeleteConversationTable` |
| macro | `LCCKDeleteMessageSQL` | `CYLDeleteMessageSQL` |
| macro | `LCCKFaildMessageTable` | `CYLFaildMessageTable` |
| macro | `LCCKInsertMessageSQL` | `CYLInsertMessageSQL` |
| macro | `LCCKKeyConversationId` | `CYLKeyConversationId` |
| macro | `LCCKKeyId` | `CYLKeyId` |
| macro | `LCCKKeyMessage` | `CYLKeyMessage` |
| macro | `LCCKLocalizedStrings` | `CYLLocalizedStrings` |
| macro | `LCCKLog` | `CYLLog` |
| macro | `LCCKLongPressMessageUserInfoKeyFromController` | `CYLLongPressMessageUserInfoKeyFromController` |
| macro | `LCCKLongPressMessageUserInfoKeyFromView` | `CYLLongPressMessageUserInfoKeyFromView` |
| macro | `LCCKLongPressMessageUserInfoKeyMessageCell` | `CYLLongPressMessageUserInfoKeyMessageCell` |
| macro | `LCCKLongPressMessageUserInfoKeyMessageOwner` | `CYLLongPressMessageUserInfoKeyMessageOwner` |
| macro | `LCCKMessageCellLimit` | `CYLMessageCellLimit` |
| macro | `LCCKPBLog` | `CYLPBLog` |
| macro | `LCCKPhoto_LOADING_DID_END_NOTIFICATION` | `CYLPhoto_LOADING_DID_END_NOTIFICATION` |
| macro | `LCCKPreviewImageMessageUserInfoKeyFromController` | `CYLPreviewImageMessageUserInfoKeyFromController` |
| macro | `LCCKPreviewImageMessageUserInfoKeyFromPlaceholderView` | `CYLPreviewImageMessageUserInfoKeyFromPlaceholderView` |
| macro | `LCCKPreviewImageMessageUserInfoKeyFromView` | `CYLPreviewImageMessageUserInfoKeyFromView` |
| macro | `LCCKPreviewLocationMessageUserInfoKeyFromController` | `CYLPreviewLocationMessageUserInfoKeyFromController` |
| macro | `LCCKPreviewLocationMessageUserInfoKeyFromView` | `CYLPreviewLocationMessageUserInfoKeyFromView` |
| macro | `LCCKSelectMessagesByIDSQL` | `CYLSelectMessagesByIDSQL` |
| macro | `LCCKSelectMessagesSQL` | `CYLSelectMessagesSQL` |
| macro | `LCCKWhereConversationId` | `CYLWhereConversationId` |
| macro | `LCCKWhereKeyId` | `CYLWhereKeyId` |
| macro | `LCCK_CONVERSATIONVIEWCONTROLLER_BACKGROUNDCOLOR` | `CYL_CONVERSATIONVIEWCONTROLLER_BACKGROUNDCOLOR` |
| macro | `LCCK_CURRENT_CONVERSATIONVIEWCONTROLLER_OBJECT` | `CYL_CURRENT_CONVERSATIONVIEWCONTROLLER_OBJECT` |
| macro | `LCCK_CURRENT_TIMESTAMP` | `CYL_CURRENT_TIMESTAMP` |
| macro | `LCCK_DEPRECATED` | `CYL_DEPRECATED` |
| macro | `LCCK_FUTURE_TIMESTAMP` | `CYL_FUTURE_TIMESTAMP` |
| macro | `LCCK_STRETCH_IMAGE` | `CYL_STRETCH_IMAGE` |
| macro | `LCCK_STRING_BY_SEL` | `CYL_STRING_BY_SEL` |
| macro | `LCCK_TIMESTAMP_REGEX` | `CYL_TIMESTAMP_REGEX` |
| macro | `kLCCKMessageTextColor` | `kCYLMessageTextColor` |
| macro | `kLCCKRecordAudioTooLong` | `kCYLRecordAudioTooLong` |
| macro | `kLCCKTopLineBackgroundColor` | `kCYLTopLineBackgroundColor` |
| protocol | `LCCKChatBarDelegate` | `CYLChatBarDelegate` |
| protocol | `LCCKChatFaceViewDelegate` | `CYLChatFaceViewDelegate` |
| protocol | `LCCKChatMessageCellDelegate` | `CYLChatMessageCellDelegate` |
| protocol | `LCCKChatMessageCellSubclassing` | `CYLChatMessageCellSubclassing` |
| protocol | `LCCKConversationListViewControllerDelegate` | `CYLConversationListViewControllerDelegate` |
| protocol | `LCCKConversationService` | `CYLConversationService` |
| protocol | `LCCKConversationViewModelDelegate` | `CYLConversationViewModelDelegate` |
| protocol | `LCCKConversationsListService` | `CYLConversationsListService` |
| protocol | `LCCKFacePageViewDelegate` | `CYLFacePageViewDelegate` |
| protocol | `LCCKInputViewPluginDelegate` | `CYLInputViewPluginDelegate` |
| protocol | `LCCKInputViewPluginSubclassing` | `CYLInputViewPluginSubclassing` |
| protocol | `LCCKLocationControllerDelegate` | `CYLLocationControllerDelegate` |
| protocol | `LCCKMessageDelegate` | `CYLMessageDelegate` |
| protocol | `LCCKPhoto` | `CYLPhoto` |
| protocol | `LCCKPhotoBrowserDelegate` | `CYLPhotoBrowserDelegate` |
| protocol | `LCCKSendImageViewDelegate` | `CYLSendImageViewDelegate` |
| protocol | `LCCKSessionService` | `CYLSessionService` |
| protocol | `LCCKSettingService` | `CYLSettingService` |
| protocol | `LCCKSignatureService` | `CYLSignatureService` |
| protocol | `LCCKStatusViewDelegate` | `CYLStatusViewDelegate` |
| protocol | `LCCKSwipeViewDataSource` | `CYLSwipeViewDataSource` |
| protocol | `LCCKSwipeViewDelegate` | `CYLSwipeViewDelegate` |
| protocol | `LCCKTapDetectingImageViewDelegate` | `CYLTapDetectingImageViewDelegate` |
| protocol | `LCCKTapDetectingViewDelegate` | `CYLTapDetectingViewDelegate` |
| protocol | `LCCKUIService` | `CYLUIService` |
| protocol | `LCCKUserDelegate` | `CYLUserDelegate` |
| protocol | `LCCKUserModelDelegate` | `CYLUserModelDelegate` |
| protocol | `LCCKUserSystemService` | `CYLUserSystemService` |
| protocol | `LCCKViewControllerEventProtocol` | `CYLViewControllerEventProtocol` |
| protocol | `LCCKWebViewProgressDelegate` | `CYLWebViewProgressDelegate` |
| protocol | `LCCKZoomingScrollViewDelegate` | `CYLZoomingScrollViewDelegate` |

Members whose selector changed:

| Old | New |
|:---|:---|
| `LCCKBaseViewController -alertAVIMError:` | `CYLChatBaseViewController -alertCYLIMError:` |
| `LCCKBaseViewController -filterAVIMError:` | `CYLChatBaseViewController -filterCYLIMError:` |
| `LCCKConversationService -insertFailedLCCKMessage:` | `CYLConversationService -insertFailedCYLMessage:` |
| `LCCKConversationViewModel avimTypedMessage` | `CYLConversationViewModel cylimTypedMessage` |
| `LCCKSwipeViewDataSource -numberOfItemsInLCCKSwipeView:` | `CYLSwipeViewDataSource -numberOfItemsInCYLSwipeView:` |
| `NSBundle(LCCKExtension) +lcck_bundleForName:class:` | `NSBundle(CYLExtension) +cyl_bundleForName:class:` |
| `NSBundle(LCCKExtension) +lcck_bundleForbundleName:class:` | `NSBundle(CYLExtension) +cyl_bundleForbundleName:class:` |
| `NSBundle(LCCKExtension) +lcck_bundlePathForbundleName:class:` | `NSBundle(CYLExtension) +cyl_bundlePathForbundleName:class:` |
| `NSBundle(LCCKSCaleArray) +lcck_scaleArray` | `NSBundle(CYLSCaleArray) +cyl_scaleArray` |
| `NSDate(DateTools) -lcck_dateByAddingDays:` | `NSDate(DateTools) -cyl_dateByAddingDays:` |
| `NSDate(DateTools) -lcck_dateByAddingHours:` | `NSDate(DateTools) -cyl_dateByAddingHours:` |
| `NSDate(DateTools) -lcck_dateByAddingMinutes:` | `NSDate(DateTools) -cyl_dateByAddingMinutes:` |
| `NSDate(DateTools) -lcck_dateByAddingMonths:` | `NSDate(DateTools) -cyl_dateByAddingMonths:` |
| `NSDate(DateTools) -lcck_dateByAddingSeconds:` | `NSDate(DateTools) -cyl_dateByAddingSeconds:` |
| `NSDate(DateTools) -lcck_dateByAddingWeeks:` | `NSDate(DateTools) -cyl_dateByAddingWeeks:` |
| `NSDate(DateTools) -lcck_dateByAddingYears:` | `NSDate(DateTools) -cyl_dateByAddingYears:` |
| `NSDate(DateTools) -lcck_dateBySubtractingDays:` | `NSDate(DateTools) -cyl_dateBySubtractingDays:` |
| `NSDate(DateTools) -lcck_dateBySubtractingHours:` | `NSDate(DateTools) -cyl_dateBySubtractingHours:` |
| `NSDate(DateTools) -lcck_dateBySubtractingMinutes:` | `NSDate(DateTools) -cyl_dateBySubtractingMinutes:` |
| `NSDate(DateTools) -lcck_dateBySubtractingMonths:` | `NSDate(DateTools) -cyl_dateBySubtractingMonths:` |
| `NSDate(DateTools) -lcck_dateBySubtractingSeconds:` | `NSDate(DateTools) -cyl_dateBySubtractingSeconds:` |
| `NSDate(DateTools) -lcck_dateBySubtractingWeeks:` | `NSDate(DateTools) -cyl_dateBySubtractingWeeks:` |
| `NSDate(DateTools) -lcck_dateBySubtractingYears:` | `NSDate(DateTools) -cyl_dateBySubtractingYears:` |
| `NSDate(DateTools) +lcck_dateWithString:formatString:` | `NSDate(DateTools) +cyl_dateWithString:formatString:` |
| `NSDate(DateTools) +lcck_dateWithString:formatString:timeZone:` | `NSDate(DateTools) +cyl_dateWithString:formatString:timeZone:` |
| `NSDate(DateTools) +lcck_dateWithYear:month:day:` | `NSDate(DateTools) +cyl_dateWithYear:month:day:` |
| `NSDate(DateTools) +lcck_dateWithYear:month:day:hour:minute:second:` | `NSDate(DateTools) +cyl_dateWithYear:month:day:hour:minute:second:` |
| `NSDate(DateTools) -lcck_day` | `NSDate(DateTools) -cyl_day` |
| `NSDate(DateTools) -lcck_dayOfYear` | `NSDate(DateTools) -cyl_dayOfYear` |
| `NSDate(DateTools) -lcck_dayWithCalendar:` | `NSDate(DateTools) -cyl_dayWithCalendar:` |
| `NSDate(DateTools) -lcck_daysAgo` | `NSDate(DateTools) -cyl_daysAgo` |
| `NSDate(DateTools) -lcck_daysEarlierThan:` | `NSDate(DateTools) -cyl_daysEarlierThan:` |
| `NSDate(DateTools) -lcck_daysFrom:` | `NSDate(DateTools) -cyl_daysFrom:` |
| `NSDate(DateTools) -lcck_daysFrom:calendar:` | `NSDate(DateTools) -cyl_daysFrom:calendar:` |
| `NSDate(DateTools) -lcck_daysInMonth` | `NSDate(DateTools) -cyl_daysInMonth` |
| `NSDate(DateTools) -lcck_daysInYear` | `NSDate(DateTools) -cyl_daysInYear` |
| `NSDate(DateTools) -lcck_daysLaterThan:` | `NSDate(DateTools) -cyl_daysLaterThan:` |
| `NSDate(DateTools) -lcck_daysUntil` | `NSDate(DateTools) -cyl_daysUntil` |
| `NSDate(DateTools) +lcck_defaultCalendarIdentifier` | `NSDate(DateTools) +cyl_defaultCalendarIdentifier` |
| `NSDate(DateTools) -lcck_era` | `NSDate(DateTools) -cyl_era` |
| `NSDate(DateTools) -lcck_eraWithCalendar:` | `NSDate(DateTools) -cyl_eraWithCalendar:` |
| `NSDate(DateTools) -lcck_formattedDateWithFormat:` | `NSDate(DateTools) -cyl_formattedDateWithFormat:` |
| `NSDate(DateTools) -lcck_formattedDateWithFormat:locale:` | `NSDate(DateTools) -cyl_formattedDateWithFormat:locale:` |
| `NSDate(DateTools) -lcck_formattedDateWithFormat:timeZone:` | `NSDate(DateTools) -cyl_formattedDateWithFormat:timeZone:` |
| `NSDate(DateTools) -lcck_formattedDateWithFormat:timeZone:locale:` | `NSDate(DateTools) -cyl_formattedDateWithFormat:timeZone:locale:` |
| `NSDate(DateTools) -lcck_formattedDateWithStyle:` | `NSDate(DateTools) -cyl_formattedDateWithStyle:` |
| `NSDate(DateTools) -lcck_formattedDateWithStyle:locale:` | `NSDate(DateTools) -cyl_formattedDateWithStyle:locale:` |
| `NSDate(DateTools) -lcck_formattedDateWithStyle:timeZone:` | `NSDate(DateTools) -cyl_formattedDateWithStyle:timeZone:` |
| `NSDate(DateTools) -lcck_formattedDateWithStyle:timeZone:locale:` | `NSDate(DateTools) -cyl_formattedDateWithStyle:timeZone:locale:` |
| `NSDate(DateTools) -lcck_hour` | `NSDate(DateTools) -cyl_hour` |
| `NSDate(DateTools) -lcck_hourWithCalendar:` | `NSDate(DateTools) -cyl_hourWithCalendar:` |
| `NSDate(DateTools) -lcck_hoursAgo` | `NSDate(DateTools) -cyl_hoursAgo` |
| `NSDate(DateTools) -lcck_hoursEarlierThan:` | `NSDate(DateTools) -cyl_hoursEarlierThan:` |
| `NSDate(DateTools) -lcck_hoursFrom:` | `NSDate(DateTools) -cyl_hoursFrom:` |
| `NSDate(DateTools) -lcck_hoursLaterThan:` | `NSDate(DateTools) -cyl_hoursLaterThan:` |
| `NSDate(DateTools) -lcck_hoursUntil` | `NSDate(DateTools) -cyl_hoursUntil` |
| `NSDate(DateTools) -lcck_isEarlierThan:` | `NSDate(DateTools) -cyl_isEarlierThan:` |
| `NSDate(DateTools) -lcck_isEarlierThanOrEqualTo:` | `NSDate(DateTools) -cyl_isEarlierThanOrEqualTo:` |
| `NSDate(DateTools) -lcck_isInLeapYear` | `NSDate(DateTools) -cyl_isInLeapYear` |
| `NSDate(DateTools) -lcck_isLaterThan:` | `NSDate(DateTools) -cyl_isLaterThan:` |
| `NSDate(DateTools) -lcck_isLaterThanOrEqualTo:` | `NSDate(DateTools) -cyl_isLaterThanOrEqualTo:` |
| `NSDate(DateTools) -lcck_isSameDay:` | `NSDate(DateTools) -cyl_isSameDay:` |
| `NSDate(DateTools) +lcck_isSameDay:asDate:` | `NSDate(DateTools) +cyl_isSameDay:asDate:` |
| `NSDate(DateTools) -lcck_isToday` | `NSDate(DateTools) -cyl_isToday` |
| `NSDate(DateTools) -lcck_isTomorrow` | `NSDate(DateTools) -cyl_isTomorrow` |
| `NSDate(DateTools) -lcck_isWeekend` | `NSDate(DateTools) -cyl_isWeekend` |
| `NSDate(DateTools) -lcck_isYesterday` | `NSDate(DateTools) -cyl_isYesterday` |
| `NSDate(DateTools) -lcck_minute` | `NSDate(DateTools) -cyl_minute` |
| `NSDate(DateTools) -lcck_minuteWithCalendar:` | `NSDate(DateTools) -cyl_minuteWithCalendar:` |
| `NSDate(DateTools) -lcck_minutesAgo` | `NSDate(DateTools) -cyl_minutesAgo` |
| `NSDate(DateTools) -lcck_minutesEarlierThan:` | `NSDate(DateTools) -cyl_minutesEarlierThan:` |
| `NSDate(DateTools) -lcck_minutesFrom:` | `NSDate(DateTools) -cyl_minutesFrom:` |
| `NSDate(DateTools) -lcck_minutesLaterThan:` | `NSDate(DateTools) -cyl_minutesLaterThan:` |
| `NSDate(DateTools) -lcck_minutesUntil` | `NSDate(DateTools) -cyl_minutesUntil` |
| `NSDate(DateTools) -lcck_month` | `NSDate(DateTools) -cyl_month` |
| `NSDate(DateTools) -lcck_monthWithCalendar:` | `NSDate(DateTools) -cyl_monthWithCalendar:` |
| `NSDate(DateTools) -lcck_monthsAgo` | `NSDate(DateTools) -cyl_monthsAgo` |
| `NSDate(DateTools) -lcck_monthsEarlierThan:` | `NSDate(DateTools) -cyl_monthsEarlierThan:` |
| `NSDate(DateTools) -lcck_monthsFrom:` | `NSDate(DateTools) -cyl_monthsFrom:` |
| `NSDate(DateTools) -lcck_monthsFrom:calendar:` | `NSDate(DateTools) -cyl_monthsFrom:calendar:` |
| `NSDate(DateTools) -lcck_monthsLaterThan:` | `NSDate(DateTools) -cyl_monthsLaterThan:` |
| `NSDate(DateTools) -lcck_monthsUntil` | `NSDate(DateTools) -cyl_monthsUntil` |
| `NSDate(DateTools) -lcck_quarter` | `NSDate(DateTools) -cyl_quarter` |
| `NSDate(DateTools) -lcck_quarterWithCalendar:` | `NSDate(DateTools) -cyl_quarterWithCalendar:` |
| `NSDate(DateTools) -lcck_second` | `NSDate(DateTools) -cyl_second` |
| `NSDate(DateTools) -lcck_secondWithCalendar:` | `NSDate(DateTools) -cyl_secondWithCalendar:` |
| `NSDate(DateTools) -lcck_secondsAgo` | `NSDate(DateTools) -cyl_secondsAgo` |
| `NSDate(DateTools) -lcck_secondsEarlierThan:` | `NSDate(DateTools) -cyl_secondsEarlierThan:` |
| `NSDate(DateTools) -lcck_secondsFrom:` | `NSDate(DateTools) -cyl_secondsFrom:` |
| `NSDate(DateTools) -lcck_secondsLaterThan:` | `NSDate(DateTools) -cyl_secondsLaterThan:` |
| `NSDate(DateTools) -lcck_secondsUntil` | `NSDate(DateTools) -cyl_secondsUntil` |
| `NSDate(DateTools) +lcck_setDefaultCalendarIdentifier:` | `NSDate(DateTools) +cyl_setDefaultCalendarIdentifier:` |
| `NSDate(DateTools) -lcck_shortTimeAgoSinceDate:` | `NSDate(DateTools) -cyl_shortTimeAgoSinceDate:` |
| `NSDate(DateTools) -lcck_shortTimeAgoSinceNow` | `NSDate(DateTools) -cyl_shortTimeAgoSinceNow` |
| `NSDate(DateTools) -lcck_timeAgoSinceDate:` | `NSDate(DateTools) -cyl_timeAgoSinceDate:` |
| `NSDate(DateTools) -lcck_timeAgoSinceDate:numericDates:` | `NSDate(DateTools) -cyl_timeAgoSinceDate:numericDates:` |
| `NSDate(DateTools) -lcck_timeAgoSinceDate:numericDates:numericTimes:` | `NSDate(DateTools) -cyl_timeAgoSinceDate:numericDates:numericTimes:` |
| `NSDate(DateTools) -lcck_timeAgoSinceNow` | `NSDate(DateTools) -cyl_timeAgoSinceNow` |
| `NSDate(DateTools) -lcck_weekOfMonth` | `NSDate(DateTools) -cyl_weekOfMonth` |
| `NSDate(DateTools) -lcck_weekOfMonthWithCalendar:` | `NSDate(DateTools) -cyl_weekOfMonthWithCalendar:` |
| `NSDate(DateTools) -lcck_weekOfYear` | `NSDate(DateTools) -cyl_weekOfYear` |
| `NSDate(DateTools) -lcck_weekOfYearWithCalendar:` | `NSDate(DateTools) -cyl_weekOfYearWithCalendar:` |
| `NSDate(DateTools) -lcck_weekday` | `NSDate(DateTools) -cyl_weekday` |
| `NSDate(DateTools) -lcck_weekdayOrdinal` | `NSDate(DateTools) -cyl_weekdayOrdinal` |
| `NSDate(DateTools) -lcck_weekdayOrdinalWithCalendar:` | `NSDate(DateTools) -cyl_weekdayOrdinalWithCalendar:` |
| `NSDate(DateTools) -lcck_weekdayWithCalendar:` | `NSDate(DateTools) -cyl_weekdayWithCalendar:` |
| `NSDate(DateTools) -lcck_weeksAgo` | `NSDate(DateTools) -cyl_weeksAgo` |
| `NSDate(DateTools) -lcck_weeksEarlierThan:` | `NSDate(DateTools) -cyl_weeksEarlierThan:` |
| `NSDate(DateTools) -lcck_weeksFrom:` | `NSDate(DateTools) -cyl_weeksFrom:` |
| `NSDate(DateTools) -lcck_weeksFrom:calendar:` | `NSDate(DateTools) -cyl_weeksFrom:calendar:` |
| `NSDate(DateTools) -lcck_weeksLaterThan:` | `NSDate(DateTools) -cyl_weeksLaterThan:` |
| `NSDate(DateTools) -lcck_weeksUntil` | `NSDate(DateTools) -cyl_weeksUntil` |
| `NSDate(DateTools) -lcck_year` | `NSDate(DateTools) -cyl_year` |
| `NSDate(DateTools) -lcck_yearForWeekOfYear` | `NSDate(DateTools) -cyl_yearForWeekOfYear` |
| `NSDate(DateTools) -lcck_yearForWeekOfYearWithCalendar:` | `NSDate(DateTools) -cyl_yearForWeekOfYearWithCalendar:` |
| `NSDate(DateTools) -lcck_yearWithCalendar:` | `NSDate(DateTools) -cyl_yearWithCalendar:` |
| `NSDate(DateTools) -lcck_yearsAgo` | `NSDate(DateTools) -cyl_yearsAgo` |
| `NSDate(DateTools) -lcck_yearsEarlierThan:` | `NSDate(DateTools) -cyl_yearsEarlierThan:` |
| `NSDate(DateTools) -lcck_yearsFrom:` | `NSDate(DateTools) -cyl_yearsFrom:` |
| `NSDate(DateTools) -lcck_yearsFrom:calendar:` | `NSDate(DateTools) -cyl_yearsFrom:calendar:` |
| `NSDate(DateTools) -lcck_yearsLaterThan:` | `NSDate(DateTools) -cyl_yearsLaterThan:` |
| `NSDate(DateTools) -lcck_yearsUntil` | `NSDate(DateTools) -cyl_yearsUntil` |
| `NSFileManager(LCCKExtension) +lcck_addSkipBackupAttributeToFile:` | `NSFileManager(CYLExtension) +cyl_addSkipBackupAttributeToFile:` |
| `NSFileManager(LCCKExtension) +lcck_availableDiskSpace` | `NSFileManager(CYLExtension) +cyl_availableDiskSpace` |
| `NSFileManager(LCCKExtension) +lcck_cachesPath` | `NSFileManager(CYLExtension) +cyl_cachesPath` |
| `NSFileManager(LCCKExtension) +lcck_cachesURL` | `NSFileManager(CYLExtension) +cyl_cachesURL` |
| `NSFileManager(LCCKExtension) +lcck_documentsPath` | `NSFileManager(CYLExtension) +cyl_documentsPath` |
| `NSFileManager(LCCKExtension) +lcck_documentsURL` | `NSFileManager(CYLExtension) +cyl_documentsURL` |
| `NSFileManager(LCCKExtension) +lcck_libraryPath` | `NSFileManager(CYLExtension) +cyl_libraryPath` |
| `NSFileManager(LCCKExtension) +lcck_libraryURL` | `NSFileManager(CYLExtension) +cyl_libraryURL` |
| `NSMutableArray(LCCKMessageExtention) -lcck_messageAtIndex:` | `NSMutableArray(CYLMessageExtention) -cyl_messageAtIndex:` |
| `NSMutableArray(LCCKMessageExtention) +lcck_messagesWithAVIMMessages:` | `NSMutableArray(CYLMessageExtention) +cyl_messagesWithCYLIMMessages:` |
| `NSMutableArray(LCCKMessageExtention) -lcck_removeMessageAtIndex:` | `NSMutableArray(CYLMessageExtention) -cyl_removeMessageAtIndex:` |
| `NSMutableDictionary(LCCKWeakReference) -lcck_weak_getObjectForKey:` | `NSMutableDictionary(CYLWeakReference) -cyl_weak_getObjectForKey:` |
| `NSMutableDictionary(LCCKWeakReference) -lcck_weak_setObject:forKey:` | `NSMutableDictionary(CYLWeakReference) -cyl_weak_setObject:forKey:` |
| `NSMutableDictionary(LCCKWeakReference) -lcck_weak_setObjectWithDictionary:` | `NSMutableDictionary(CYLWeakReference) -cyl_weak_setObjectWithDictionary:` |
| `NSObject(LCCKExtension) -lcck_JSONValue` | `NSObject(CYLExtension) -cyl_JSONValue` |
| `NSObject(LCCKExtension) -lcck_isCreatorForCurrentGroupConversaton` | `NSObject(CYLExtension) -cyl_isCreatorForCurrentGroupConversaton` |
| `NSObject(LCCKExtension) -lcck_isCustomLCCKMessage` | `NSObject(CYLExtension) -cyl_isCustomCYLMessage` |
| `NSObject(LCCKExtension) -lcck_isCustomMessage` | `NSObject(CYLExtension) -cyl_isCustomMessage` |
| `NSObject(LCCKExtension) -lcck_messageTimestamp` | `NSObject(CYLExtension) -cyl_messageTimestamp` |
| `NSObject(LCCKExtension) -lcck_shouldDisplayTimestampForMessages:callback:` | `NSObject(CYLExtension) -cyl_shouldDisplayTimestampForMessages:callback:` |
| `NSObject(LCCKIsFirstLaunch) -lcck_isFirstLaunchToEvent:evenUpdate:firstLaunch:` | `NSObject(CYLIsFirstLaunch) -cyl_isFirstLaunchToEvent:evenUpdate:firstLaunch:` |
| `NSString(LCCKAddScale) -lcck_stringByAppendingScale:` | `NSString(CYLAddScale) -cyl_stringByAppendingScale:` |
| `NSString(LCCKExtension) -lcck_allCheckingTypeWithPattern:error:` | `NSString(CYLExtension) -cyl_allCheckingTypeWithPattern:error:` |
| `NSString(LCCKExtension) -lcck_allPhoneNumbers` | `NSString(CYLExtension) -cyl_allPhoneNumbers` |
| `NSString(LCCKExtension) -lcck_allURLLinks` | `NSString(CYLExtension) -cyl_allURLLinks` |
| `NSString(LCCKExtension) -lcck_allURLsWithPattern:error:` | `NSString(CYLExtension) -cyl_allURLsWithPattern:error:` |
| `NSString(LCCKExtension) -lcck_allUserNames` | `NSString(CYLExtension) -cyl_allUserNames` |
| `NSString(LCCKExtension) -lcck_containsString:` | `NSString(CYLExtension) -cyl_containsString:` |
| `NSString(LCCKExtension) -lcck_hexStringToColor` | `NSString(CYLExtension) -cyl_hexStringToColor` |
| `NSString(LCCKExtension) -lcck_isLink` | `NSString(CYLExtension) -cyl_isLink` |
| `NSString(LCCKExtension) -lcck_isPhoneNumber` | `NSString(CYLExtension) -cyl_isPhoneNumber` |
| `NSString(LCCKExtension) -lcck_isSpace` | `NSString(CYLExtension) -cyl_isSpace` |
| `NSString(LCCKExtension) -lcck_isType:` | `NSString(CYLExtension) -cyl_isType:` |
| `NSString(LCCKExtension) -lcck_isUserName` | `NSString(CYLExtension) -cyl_isUserName` |
| `NSString(LCCKExtension) -lcck_onlyContainsLetterAndNumber` | `NSString(CYLExtension) -cyl_onlyContainsLetterAndNumber` |
| `NSString(LCCKExtension) -lcck_pathForConversationBackgroundImage` | `NSString(CYLExtension) -cyl_pathForConversationBackgroundImage` |
| `NSString(LCCKMD5) -lcck_MD5String` | `NSString(CYLMD5) -cyl_MD5String` |
| `UIImage(LCCKExtension) -lcck_imageByScalingAspectFill` | `UIImage(CYLExtension) -cyl_imageByScalingAspectFill` |
| `UIImage(LCCKExtension) -lcck_imageByScalingAspectFillWithOriginSize:` | `UIImage(CYLExtension) -cyl_imageByScalingAspectFillWithOriginSize:` |
| `UIImage(LCCKExtension) -lcck_imageByScalingAspectFillWithOriginSize:limitSize:` | `UIImage(CYLExtension) -cyl_imageByScalingAspectFillWithOriginSize:limitSize:` |
| `UIImage(LCCKExtension) +lcck_imageNamed:bundleName:bundleForClass:` | `UIImage(CYLExtension) +cyl_imageNamed:bundleName:bundleForClass:` |
| `UIImage(LCCKExtension) -lcck_scalingPatternImageToSize:` | `UIImage(CYLExtension) -cyl_scalingPatternImageToSize:` |
| `UIImageView(LCCKExtension) -lcck_attachBorderWidth:color:` | `UIImageView(CYLExtension) -cyl_attachBorderWidth:color:` |
| `UIImageView(LCCKExtension) lcck_cornerRadius` | `UIImageView(CYLExtension) cyl_cornerRadius` |
| `UIImageView(LCCKExtension) -lcck_cornerRadiusAdvance:rectCornerType:` | `UIImageView(CYLExtension) -cyl_cornerRadiusAdvance:rectCornerType:` |
| `UIImageView(LCCKExtension) -lcck_cornerRadiusRoundingRect` | `UIImageView(CYLExtension) -cyl_cornerRadiusRoundingRect` |
| `UIView(LCCKExtension) -lcck_allSubViews` | `UIView(CYLExtension) -cyl_allSubViews` |
| `UIView(LCCKExtension) -lcck_logViewHierarchy:` | `UIView(CYLExtension) -cyl_logViewHierarchy:` |

### Moved and removed

| Kind | Old | Status | Replacement or reason |
|:---|:---|:---|:---|
| blocks | `DeallocExecutorBlock` | removed | removed with the vendored dealloc executor |
| category | `AVIMConversation(LCCKAddition)` | removed | removed: duplicated `AVIMConversation (LCCKExtension)` methods (undefined runtime winner) |
| category | `AVIMConversation(LCCKExtension)` | moved | moved to the demo (`ChatKit-OC/Example/Class/LeanCloud`), conforms to `CYLConversationProtocol` |
| category | `AVIMMessage(LCCKExtension)` | moved | moved to the demo |
| category | `AVIMTypedMessage(LCCKExtension)` | moved | moved to the demo, conforms to `CYLIMMessageProtocol` |
| category | `AVIMTypedMessage(LCCKExtention)` | removed | removed: never compiled (read a nonexistent property) |
| category | `NSObject(LCCKDeallocBlockExecutor)` | removed | removed: use `-cyl_willDeallocWithSelfCallback:` from the `CYLDeallocBlockExecutor` pod |
| class | `AVIMEmotionMessage` | moved | moved to the demo |
| class | `LCCKDeallocExecutor` | removed | removed: vendored copy of the `CYLDeallocBlockExecutor` pod; use the pod |
| constants | `_typeDict` | moved | moved to the demo: declared in `AVIMTypedMessage+LCCKExtension.m` (a LeanCloud SDK private symbol) |
| constants | `kAVIMMessageMediaTypeEmotion` | moved | moved to the demo with `AVIMEmotionMessage` |
| member | `LCCKCommonUtils +getPathFromFile:` | moved | moved to the demo category `CYLCommonUtils (LCCKExtension)` |
| member | `LCCKCommonUtils +isCacheDataAvailableForFile:` | moved | moved to the demo category `CYLCommonUtils (LCCKExtension)` |
| member | `LCCKConversationService -sendMessage:conversation:options:progressBlock:callback:` | moved | moved to the demo: `-[LCCKLeanCloudConversationService sendMessage:conversation:options:mentionList:progressBlock:callback:]` |
| member | `LCCKMessage +messageWithAVIMTypedMessage:` | moved | moved to the demo category `CYLMessage (LCCKExtension)` |
| member | `NSObject(LCCKDeallocBlockExecutor) -lcck_executeAtDealloc:` | removed | removed: use `-cyl_willDeallocWithSelfCallback:` from the `CYLDeallocBlockExecutor` pod |
| member | `UIImage(LCCKExtension) +lcck_imageNamed:` | removed | removed: declared but never implemented; would clash with CYLTabBarController |

### Added since `b730b8d`

These public types did not exist in the original headers: `CYLConversationProtocol`, `CYLIMConversationProvider`, `CYLIMConversationResultBlock`, `CYLIMErrorCode`, `CYLIMFailedMessageProvider`, `CYLIMMessageProtocol`, `CYLIMMessageProvider`, `CYLIMMessageResultBlock`, `CYLIMProvider`, `CYLIMPushProvider`, `CYLIMRecentConversationProvider`, `CYLIMRecentConversationsResultBlock`, `CYLIMSessionProvider`, `CYLMessageMediaType`.

