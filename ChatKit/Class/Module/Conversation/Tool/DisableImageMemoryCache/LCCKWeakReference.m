//
//  LCCKWeakReference.m
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "LCCKWeakReference.h"

LCCKWeakReference makeLCCKWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(LCCKWeakReference ref) {
	return ref ? ref() : nil;
}
