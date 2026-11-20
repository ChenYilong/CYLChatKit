//
//  CYLWeakReference.h
//  Kuber
//
//  v2.1.1 Created by Kuber on 16/4/29.
//  Copyright © 2016年 Huaxu Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^CYLWeakReference)(void);

CYLWeakReference makeCYLWeakReference(id object);

id weakReferenceNonretainedObjectValue(CYLWeakReference ref);
