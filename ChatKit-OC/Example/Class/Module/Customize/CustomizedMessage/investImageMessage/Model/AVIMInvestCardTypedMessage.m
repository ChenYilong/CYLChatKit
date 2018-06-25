//
//  AVIMInvestCardTypedMessage.m
//  ChatKit-OC
//
//  Created by chenyilong on 21/6/2018.
//  Copyright © 2018 ElonChan. All rights reserved.
//

#import "AVIMInvestCardTypedMessage.h"
#import "LCCKUtil.h"

@interface AVIMInvestCardTypedMessage()
@property (nonatomic, assign) CGSize photoSize; // photoWidth/photoHeight
@end

@implementation AVIMInvestCardTypedMessage
@synthesize photoPath = _photoPath;
@synthesize thumbnailPhoto = _thumbnailPhoto;
@synthesize photo = _photo;
@synthesize originPhotoURL = _originPhotoURL;

#pragma mark -
#pragma mark - initialize Method

#pragma mark -
#pragma mark - initialize Method

/*!
 * 有几个必须添加的字段：
 *  - degrade 用来定义如何展示老版本未支持的自定义消息类型
 *  - typeTitle 最近对话列表中最近一条消息的title，比如：最近一条消息是图片，可设置该字段内容为：`@"图片"`，相应会展示：`[图片]`。
 *  - summary 会显示在 push 提示中
 *  - conversationType 用来展示在推送提示中，以达到这样的效果： [群消息]Tom：hello gays!
 * @attention 务必添加这几个字段，ChatKit 内部会使用到。
 */
- (instancetype)initWithImageURL:(NSURL *)imageURL conversationType:(LCCKConversationType)conversationType {
    self = [super init];
    if (!self) {
        return nil;
    }
    AVFile *file = [AVFile fileWithRemoteURL:imageURL];
    self = [[self class] messageWithText:nil file:file attributes:nil];
    [self lcck_setObject:@"饭局邀请" forKey:LCCKCustomMessageTypeTitleKey];
    [self lcck_setObject:@"这是一条饭局邀请消息，当前版本过低无法显示，请尝试升级APP查看" forKey:LCCKCustomMessageDegradeKey];
    [self lcck_setObject:@"有人向您发送了一条饭局邀请消息，请打开APP查看" forKey:LCCKCustomMessageSummaryKey];
    [self lcck_setObject:@(conversationType) forKey:LCCKCustomMessageConversationTypeKey];
//    NSDictionary *dictionary = @{
//                                 @"width" : @(size.width),
//                                 @"height" : @(size.height),
//                                 };
//    self.file.metaData = dictionary;
    return self;
}

- (CGSize)photoSize {
    if (_photoSize.width > 0 && _photoSize.height > 0) {
        return _photoSize;
    }
    CGSize size = [LCCKUtil sizeFromOSSURLString:self.originPhotoURL.absoluteString];
    _photoSize = size;
    return _photoSize;
};

- (NSString *)photoPath {
    return self.file.persistentCachePath;
}

- (int)photoHeight {
    return self.photoSize.height;
}

- (int)photoWidth {
    return self.photoSize.width;
}

- (NSURL *)originPhotoURL {
    return [NSURL URLWithString:self.file.url];
}

+ (instancetype)investCardMessageWithImageURL:(NSURL *)imageURL  conversationType:(LCCKConversationType)conversationType {
    return [[self alloc] initWithImageURL:imageURL conversationType:conversationType];
}

#pragma mark -
#pragma mark - Override Methods

#pragma mark -
#pragma mark - AVIMTypedMessageSubclassing Method

+ (void)load {
    [self registerSubclass];
}

+ (AVIMMessageMediaType)classMediaType {
    return kAVIMInvestCardTypedMessage;
}

@end
