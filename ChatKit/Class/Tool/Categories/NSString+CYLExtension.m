//
//  NSString+CYLExtension.m
//  ChatKit
//
//  v2.1.1 Created by ElonChan on 16/7/12.
//  Copyright © 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import "NSString+CYLExtension.h"
#import "NSFileManager+CYLExtension.h"
#import "CYLChatConstants.h"
#import "CYLSessionService.h"
#import "CYLConversationService.h"

NSString *const CYLURLRegex = @"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))";
//匹配10到12位连续数字，或者带连字符/空格的固话号，空格和连字符可以省略。
NSString *const CYLPhoneRegex =  @"\\d{3,4}[- ]?\\d{7,8}";

@implementation NSString (CYLExtension)

- (BOOL)cyl_containsString:(NSString *)string {
    if ([self rangeOfString:string].location == NSNotFound) {
        return NO;
    }
    return YES;
}

- (BOOL)cyl_onlyContainsLetterAndNumber {
    if (![[self stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] isEqualToString:self]
        && ![[self stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]] isEqualToString:self]) {
        return YES;
    }
    return NO;
}
- (BOOL)cyl_isLink {
    return [self cyl_isType:NSTextCheckingTypeLink];
}

- (BOOL)cyl_isPhoneNumber {
    return (self.cyl_allPhoneNumbers.count > 0);
}

- (BOOL)cyl_isUserName {
    return [self hasPrefix:@"@"];
}

- (BOOL)cyl_isSpace {
    if (!self) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[self stringByTrimmingCharactersInSet: set] length] == 0) {
        return YES;
    }
    return NO;
}

- (NSArray<NSString *> *)cyl_allURLLinks {
    NSString *URLRegex =  CYLURLRegex;
    NSArray *allURLLinksFromRegex = [self cyl_allCheckingTypeWithPattern:URLRegex error:nil];
    return allURLLinksFromRegex;
}

- (NSArray<NSString *> *)cyl_allPhoneNumbers {
    //匹配10到12位连续数字，或者带连字符/空格的固话号，空格和连字符可以省略。
    NSString *phoneRegex = CYLPhoneRegex;
    NSArray *phoneNumbersFromRegex = [self cyl_allCheckingTypeWithPattern:phoneRegex error:nil];
    return phoneNumbersFromRegex;
}

- (NSArray<NSString *> *)cyl_allUserNames {
    //[^\s#@] will match everything except space characters, # and @.And remember to double escape \ when put in the objective-c string literal.
    NSString *pattern = @"@[^\\s#@]*";
    return [self cyl_allCheckingTypeWithPattern:pattern error:nil];
}

- (BOOL)cyl_isType:(NSTextCheckingType)type {
    switch (type) {
        case NSTextCheckingTypeLink:
            return ([self cyl_allMatchsWithPattern:CYLURLRegex error:nil].count > 0);
            break;
            case NSTextCheckingTypePhoneNumber:
            return ([self cyl_allMatchsWithPattern:CYLPhoneRegex error:nil].count > 0);
            break;
        default:
            break;
    }
    return NO;
}

- (NSArray<NSTextCheckingResult *> *)cyl_allMatchsWithPattern:(NSString *)pattern error:(NSError **)error {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:error];
    NSArray *arrayOfAllMatches = [regex matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    return arrayOfAllMatches;
}

- (NSArray *)cyl_allRangesWithPattern:(NSString *)pattern error:(NSError **)error {
    NSArray *arrayOfAllMatches = [self cyl_allMatchsWithPattern:pattern error:error];
    NSMutableArray *allRanges = [NSMutableArray arrayWithCapacity:1];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        [allRanges addObject:[NSValue valueWithRange:match.range]];
    }
    return [allRanges copy];
}

- (NSArray<NSValue *> *)cyl_allURLsWithPattern:(NSString *)pattern error:(NSError **)error {
    NSArray *arrayOfAllMatches = [self cyl_allMatchsWithPattern:pattern error:error];
    NSMutableArray *allRanges = [NSMutableArray arrayWithCapacity:1];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        [allRanges addObject:[NSValue valueWithRange:match.range]];
    }
    return [allRanges copy];
}

- (NSArray<NSString *> *)cyl_allCheckingTypeWithPattern:(NSString *)pattern error:(NSError **)error {
    NSArray *arrayOfAllMatches = [self cyl_allMatchsWithPattern:pattern error:error];
    NSMutableArray *arrayOfCheckingType = [[NSMutableArray alloc] init];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [self substringWithRange:match.range];
        [arrayOfCheckingType addObject:substringForMatch];
    }
    // return non-mutable version of the array
    return [NSArray arrayWithArray:arrayOfCheckingType];
}

- (UIColor *)cyl_hexStringToColor {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSString *)cyl_pathForConversationBackgroundImage {
    NSString *path = [NSString stringWithFormat:@"%@/APP/%@/User/%@/Conversation/%@/Background/", [NSFileManager cyl_documentsPath], [CYLChatKit sharedInstance].appId,[CYLSessionService sharedInstance].clientId, [CYLConversationService sharedInstance].currentConversation.conversationId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            CYLLog(@"File Create Failed: %@", path);
        }
    }
    return [path stringByAppendingString:self];
}

@end
