//
//  LCCKSignatureService.m
//  LeanCloudChatKit-iOS
//
//  v0.8.5 Created by ElonChan on 16/2/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "LCCKSignatureService.h"

NSString *const LCCKSignatureServiceErrorDomain = @"LCCKSignatureServiceErrorDomain";

@implementation LCCKSignatureService
@synthesize generateSignatureBlock = _generateSignatureBlock;

- (void)setGenerateSignatureBlock:(LCCKGenerateSignatureBlock)generateSignatureBlock {
    _generateSignatureBlock = generateSignatureBlock;
}

@end
