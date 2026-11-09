//
//  CYLMessage+LCCKExtension.m
//  ChatKit-OC
//
//  Created by ChenYilong on 2026/11/09.
//  Copyright © 2026 ChenYilong. All rights reserved.
//

#import "CYLMessage+LCCKExtension.h"
#import "AVIMTypedMessage+LCCKExtension.h"
#import "CYLCommonUtils+LCCKExtension.h"
#import "UIImage+LCCKExtension.h"
#import "NSObject+LCCKExtension.h"

@implementation CYLMessage (LCCKExtension)

+ (id)messageWithAVIMTypedMessage:(AVIMTypedMessage *)message {
    //FIXME:自定义消息
    if ([message cyl_isCustomMessage]) {
        if ([message lcck_isSupportThisCustomMessage]) {
            return message;
        }
    }
    NSError *error = nil;
    NSString *senderId = message.clientId;
    id<CYLUserDelegate> sender = [[CYLUserSystemService sharedInstance] getProfileForUserId:message.clientId error:&error];
    CYLMessage *lcckMessage;
    NSTimeInterval time = message.sendTimestamp;
    NSString *serverMessageId = message.messageId;
    //FIXME:
    AVIMMessageMediaType mediaType = message.mediaType;
    switch (mediaType) {
        case kAVIMMessageMediaTypeText: {
            AVIMTextMessage *textMsg = (AVIMTextMessage *)message;
            lcckMessage = [[CYLMessage alloc] initWithText:textMsg.text senderId:senderId sender:sender timestamp:time serverMessageId:serverMessageId];
            break;
        }
        case kAVIMMessageMediaTypeAudio: {
            AVIMAudioMessage *audioMsg = (AVIMAudioMessage *)message;
            NSString *duration = [NSString stringWithFormat:@"%.0f", audioMsg.duration];
            NSString *voicePath;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *localPath = [CYLCommonUtils getPathFromFile:audioMsg.file];
            NSString *pathForFile = localPath;
            if ([fileManager fileExistsAtPath:pathForFile]){
                voicePath = localPath;
            } else {
                voicePath = audioMsg.file.url;
            }
            lcckMessage = [[CYLMessage alloc] initWithVoicePath:voicePath voiceURL:nil voiceDuration:duration senderId:senderId sender:sender timestamp:time serverMessageId:serverMessageId];
            break;
        }
            
        case kAVIMMessageMediaTypeLocation: {
            AVIMLocationMessage *locationMsg = (AVIMLocationMessage *)message;
            lcckMessage = [[CYLMessage alloc] initWithLocalPositionPhoto:({
                NSString *imageName = @"MessageBubble_Location";
                UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"MessageBubble" bundleForClass:[self class]];
                image;})
                                                             geolocations:locationMsg.text location:[[CLLocation alloc] initWithLatitude:locationMsg.latitude longitude:locationMsg.longitude] senderId:senderId sender:sender timestamp:time serverMessageId:serverMessageId];
            break;
        }
        case kAVIMMessageMediaTypeImage: {
            AVIMImageMessage *imageMsg = (AVIMImageMessage *)message;
            NSString *imagePath = [CYLCommonUtils getPathFromFile:imageMsg.file];
            lcckMessage = [[CYLMessage alloc] initWithPhoto:nil photoWidth:imageMsg.width photoHeight: imageMsg.height thumbnailPhoto:nil photoPath:imagePath thumbnailURL:nil originPhotoURL:[NSURL URLWithString:imageMsg.file.url] senderId:senderId sender:sender timestamp:time serverMessageId:serverMessageId];
            break;
        }
        case kAVIMMessageMediaTypeVideo: {
            return nil;
       }
        case kAVIMMessageMediaTypeFile: {
            return nil;
        }
        case kAVIMMessageMediaTypeRecalled: {
            return nil;
        }
        default: {
            NSString *degradeContent;
            @try {
                degradeContent = [message.attributes objectForKey:CYLCustomMessageDegradeKey];
            } @catch (NSException *exception) {} @finally {
                if (!degradeContent) {
                    degradeContent = CYLLocalizedStrings(@"unknownMessage");
                }
            }
            lcckMessage = [[CYLMessage alloc] initWithText:degradeContent senderId:senderId sender:sender timestamp:time serverMessageId:serverMessageId];
            CYLLog(@"%@", CYLLocalizedStrings(@"unknownMessage"));
            break;
        }
    }
    
    if ([[CYLSessionService sharedInstance].clientId isEqualToString:message.clientId]) {
        lcckMessage.ownerType = CYLMessageOwnerTypeSelf;
    } else {
        lcckMessage.ownerType = CYLMessageOwnerTypeOther;
    }
    lcckMessage.sendStatus = (CYLMessageSendState)message.status;
    lcckMessage.message = message;
    return lcckMessage;
}

@end
