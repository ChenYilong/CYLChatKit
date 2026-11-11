//
//  CYLDemoLoginDataSource.h
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 5/28/14.
//  Copyright (c) 2014 Mainloop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompleteTextFieldDataSource.h"
#if __has_include(<ChatKit/CYLChatKit.h>)
#import <ChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

@interface CYLDemoLoginDataSource : NSObject <MLPAutoCompleteTextFieldDataSource>

//Set this to true to return an array of autocomplete objects to the autocomplete textfield instead of strings.
//The objects returned respond to the MLPAutoCompletionObject protocol.
@property (assign) BOOL testWithAutoCompleteObjectsInsteadOfStrings;


//Set this to true to prevent auto complete terms from returning instantly.
@property (assign) BOOL simulateLatency;

@end
