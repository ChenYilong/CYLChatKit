//
//  DEMOCustomAutoCompleteObject.h
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 4/19/13.
//  Copyright (c) 2018 ChenYilong（wechat id：chenyilong1010）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLPAutoCompletionObject.h"

@interface DEMOCustomAutoCompleteObject : NSObject <MLPAutoCompletionObject>

- (id)initWithCountry:(NSString *)name;

@end
