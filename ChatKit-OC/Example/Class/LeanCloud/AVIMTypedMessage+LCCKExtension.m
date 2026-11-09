//
//  AVIMTypedMessage+LCCKExtension.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "AVIMTypedMessage+LCCKExtension.h"

/// The registry of `AVIMTypedMessage` subclasses, defined by the LeanCloud SDK.
FOUNDATION_EXTERN NSMutableDictionary const *_typeDict;

@implementation AVIMTypedMessage (LCCKExtension)

#pragma mark - LCCKIMMessageDelegate

- (NSString *)lcck_senderId {
    return self.clientId;
}

- (void)lcck_setSenderId:(NSString *)senderId {
    [self setValue:senderId forKey:@"clientId"];
}

- (LCCKMessageOwnerType)lcck_ownerType {
    switch (self.ioType) {
        case AVIMMessageIOTypeOut:
            return LCCKMessageOwnerTypeSelf;
        case AVIMMessageIOTypeIn:
            return LCCKMessageOwnerTypeOther;
        default:
            return LCCKMessageOwnerTypeUnknown;
    }
}

- (LCCKMessageSendState)lcck_sendStatus {
    // AVIMMessageStatus and LCCKMessageSendState share the same raw values.
    return (LCCKMessageSendState)self.status;
}

- (int64_t)lcck_sendTimestamp {
    return self.sendTimestamp;
}

#pragma mark - LeanCloud helpers

- (BOOL)lcck_isSupportThisCustomMessage {
    NSNumber *typeDictKey = @([(AVIMTypedMessage *)self mediaType]);
    Class class = [_typeDict objectForKey:typeDictKey];
    return class;
}

+ (AVIMTypedMessage *)lcck_messageWithLCCKMessage:(LCCKMessage *)message {
    AVIMTypedMessage *avimTypedMessage;
    switch (message.mediaType) {
        case kAVIMMessageMediaTypeText: {
            avimTypedMessage = [AVIMTextMessage messageWithText:message.text attributes:nil];
            break;
        }
        case kAVIMMessageMediaTypeVideo:
        case kAVIMMessageMediaTypeImage: {
            
            NSString *localPhotoPath = message.photoPath;
            NSString *remotePhotoPath = message.originPhotoURL;

            if ([remotePhotoPath hasPrefix:@"http"]) {
                AVFile *file = [AVFile fileWithRemoteURL:[NSURL URLWithString:remotePhotoPath]];
                avimTypedMessage = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
            } else if ([localPhotoPath hasPrefix:@"http"]) {
                AVFile *file = [AVFile fileWithRemoteURL:[NSURL URLWithString:localPhotoPath]];
                avimTypedMessage = [AVIMImageMessage messageWithText:nil file:file attributes:nil];
            } else {
                avimTypedMessage = [AVIMImageMessage messageWithText:nil attachedFilePath:message.photoPath attributes:nil];
            }
            
            break;
        }
        case kAVIMMessageMediaTypeAudio: {
            avimTypedMessage = [AVIMAudioMessage messageWithText:nil attachedFilePath:message.voicePath attributes:nil];
            break;
        }
        case kAVIMMessageMediaTypeLocation: {
            avimTypedMessage = [AVIMLocationMessage messageWithText:message.geolocations
                                                           latitude:message.location.coordinate.latitude
                                                          longitude:message.location.coordinate.longitude
                                                         attributes:nil];
            break;
        case kAVIMMessageMediaTypeNone:
            //TODO:
            break;
        }
    }
    [avimTypedMessage setObject:@(LCCK_CURRENT_TIMESTAMP) forKey:@"sendTimestamp"];
    return avimTypedMessage;
}

- (void)lcck_setObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:object forKey:key];
    if (self.attributes == nil) {
        self.attributes = attributes;
    } else {
        [attributes addEntriesFromDictionary:self.attributes];
        self.attributes = attributes;
    }
    self.attributes = attributes;
}

@end
