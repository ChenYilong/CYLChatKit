//
//  AVIMMessage+CYLDemoExtension.h
//  Pods
//
//  Created by 陈宜龙 on 18/6/20.
//
//

#import <AVOSCloudIM/AVOSCloudIM.h>

@interface AVIMMessage (CYLDemoExtension)

- (AVIMTypedMessage *)cyl_demo_getValidTypedMessage;
- (BOOL)cyl_demo_isValidMessage;

@end
