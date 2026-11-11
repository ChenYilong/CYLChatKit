//
//  AVIMTypedMessage+CYLDemoExtension.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/5/26.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "AVIMTypedMessage+CYLDemoExtension.h"

/// The registry of `AVIMTypedMessage` subclasses, defined by the LeanCloud SDK.
FOUNDATION_EXTERN NSMutableDictionary const *_typeDict;

@implementation AVIMTypedMessage (CYLDemoExtension)

#pragma mark - CYLIMMessageProtocol

- (NSString *)cyl_senderId {
    return self.clientId;
}

- (void)setCyl_senderId:(NSString *)senderId {
    [self setValue:senderId forKey:@"clientId"];
}

- (CYLMessageOwnerType)cyl_ownerType {
    switch (self.ioType) {
        case AVIMMessageIOTypeOut:
            return CYLMessageOwnerTypeSelf;
        case AVIMMessageIOTypeIn:
            return CYLMessageOwnerTypeOther;
        default:
            return CYLMessageOwnerTypeUnknown;
    }
}

- (CYLMessageSendState)cyl_sendStatus {
    // AVIMMessageStatus and CYLMessageSendState share the same raw values.
    return (CYLMessageSendState)self.status;
}

- (int64_t)cyl_sendTimestamp {
    return self.sendTimestamp;
}

#pragma mark - LeanCloud helpers

- (BOOL)cyl_demo_isSupportThisCustomMessage {
    NSNumber *typeDictKey = @([(AVIMTypedMessage *)self mediaType]);
    Class class = [_typeDict objectForKey:typeDictKey];
    return class;
}

+ (AVIMTypedMessage *)cyl_demo_messageWithCYLDemoMessage:(CYLMessage *)message {
    AVIMTypedMessage *avimTypedMessage;
    switch (message.mediaType) {
        case CYLMessageMediaTypeText: {
            avimTypedMessage = [AVIMTextMessage messageWithText:message.text attributes:nil];
            break;
        }
        case CYLMessageMediaTypeVideo:
        case CYLMessageMediaTypeImage: {
            
            NSString *localPhotoPath = message.photoPath;
            // `originPhotoURL` is an NSURL; reading it as an NSString crashed on `-hasPrefix:`.
            NSString *remotePhotoPath = message.originPhotoURL.absoluteString;

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
        case CYLMessageMediaTypeAudio: {
            avimTypedMessage = [AVIMAudioMessage messageWithText:nil attachedFilePath:message.voicePath attributes:nil];
            break;
        }
        case CYLMessageMediaTypeLocation: {
            avimTypedMessage = [AVIMLocationMessage messageWithText:message.geolocations
                                                           latitude:message.location.coordinate.latitude
                                                          longitude:message.location.coordinate.longitude
                                                         attributes:nil];
            break;
        case CYLMessageMediaTypeNone:
            //TODO:
            break;
        }
        default:
            break;
    }
    [avimTypedMessage setObject:@(CYL_CURRENT_TIMESTAMP) forKey:@"sendTimestamp"];
    return avimTypedMessage;
}

- (void)cyl_demo_setObject:(id)object forKey:(NSString *)key {
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
