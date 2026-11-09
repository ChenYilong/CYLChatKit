//
//  CYLWeakReference.m
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import "CYLWeakReference.h"

CYLWeakReference makeCYLWeakReference(id object) {
    __weak id weakref = object;
    return ^{
        return weakref;
    };
}

id weakReferenceNonretainedObjectValue(CYLWeakReference ref) {
	return ref ? ref() : nil;
}
