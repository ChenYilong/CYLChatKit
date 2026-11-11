//
//  CYLChatConstants.m
//  CYLChatKit
//
//  Function form of the CYLLocalizedStrings macro, so Swift callers can read the core strings.
//

#import "CYLChatConstants.h"
#import "CYLChatKit.h"
#import "NSBundle+CYLExtension.h"

NSString *CYLLocalizedStringForKey(NSString *key) {
    return CYLLocalizedStrings(key);
}
