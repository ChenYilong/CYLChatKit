//
//  NSMutableDictionary+CYLWeakReference.h
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (CYLWeakReference)

- (void)cyl_weak_setObject:(id)anObject forKey:(NSString *)aKey;

- (void)cyl_weak_setObjectWithDictionary:(NSDictionary *)dic;

- (id)cyl_weak_getObjectForKey:(NSString *)key;

@end
