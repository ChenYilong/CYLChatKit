//
//  AVIMMessage+LCCKExtension.h
//  Pods
//
//  Created by 陈宜龙 on 18/6/20.
//
//

#import <AVOSCloudIM/AVOSCloudIM.h>

@interface AVIMMessage (LCCKExtension)

- (AVIMTypedMessage *)lcck_getValidTypedMessage;
- (BOOL)lcck_isValidMessage;

@end
