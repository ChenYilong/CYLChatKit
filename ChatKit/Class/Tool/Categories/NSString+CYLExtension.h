//
//  NSString+CYLExtension.h
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/7/12.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString *const CYLURLRegex;
FOUNDATION_EXTERN NSString *const CYLPhoneRegex;

@interface NSString (CYLExtension)

- (BOOL)cyl_containsString:(NSString *)string;

/*!
 * 含标点符号，也返回NO
 */
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

@end
