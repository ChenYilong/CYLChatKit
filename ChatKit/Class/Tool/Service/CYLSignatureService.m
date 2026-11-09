//
//  CYLSignatureService.m
//  LeanCloudChatKit-iOS
//
//  v2.1.1 Created by ElonChan on 18/6/22.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "CYLSignatureService.h"

NSString *const CYLSignatureServiceErrorDomain = @"CYLSignatureServiceErrorDomain";

@implementation CYLSignatureService
@synthesize generateSignatureBlock = _generateSignatureBlock;

- (void)setGenerateSignatureBlock:(CYLGenerateSignatureBlock)generateSignatureBlock {
    _generateSignatureBlock = generateSignatureBlock;
}

@end
