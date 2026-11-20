//
//  NSMutableDictionary+CYLWeakReference.m
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "NSMutableDictionary+CYLWeakReference.h"
#import "CYLWeakReference.h"

@implementation NSMutableDictionary (CYLWeakReference)

- (void)cyl_weak_setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:makeCYLWeakReference(anObject) forKey:aKey];
}

- (void)cyl_weak_setObjectWithDictionary:(NSDictionary *)dictionary {
    for (NSString *key in dictionary.allKeys) {
        [self setObject:makeCYLWeakReference(dictionary[key]) forKey:key];
    }
}

- (id)cyl_weak_getObjectForKey:(NSString *)key {
    return weakReferenceNonretainedObjectValue(self[key]);
}

@end
