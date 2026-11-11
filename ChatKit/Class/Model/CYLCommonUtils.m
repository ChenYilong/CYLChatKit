//
//  CYLCommonUtils.m
//  CYLChatKit
//
//  Created by chenyilong on 14/6/2018.
//

#import "CYLCommonUtils.h"
#import <MapKit/MapKit.h>

@implementation CYLCommonUtils

// `+getPathFromFile:` and `+isCacheDataAvailableForFile:` take a LeanCloud file object,
// so they moved to the demo category `CYLCommonUtils+CYLExtension`.

+ (void)recognitionWithImage:(UIImage *)image callback:(void(^)(NSDictionary *dict))callback {
    
    if (!image) {
        callback(@{@"success": @"0"});
        return;
    }
    
    CIDetector*detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count == 0) {
        callback(@{@"success": @"0"});
        return;
    }
    
    //扫描结果
    CIQRCodeFeature *feature;
    @try {
        feature = [features objectAtIndex:0];
    } @catch (NSException *exception) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
    }
    
    callback(@{@"data": feature.messageString, @"success": @"1"});
}

+ (void)getLocationFromDataString:(NSString *)dataString
               latitudeFloatValue:(CGFloat *)theLatitudeFloatValue
              longitudeFloatValue:(CGFloat *)theLongitudeFloatValue
                             name:(NSString **)theName {
    if (![[self class] isValidString:dataString]) {
        return;
    }
    NSDictionary *hdlLocation = [[self class] jsonStringToDictionary:dataString];
    NSString *latitude;
    NSString *longitude;
    NSString *name;
    @try {
        latitude =  hdlLocation[@"hdlLocation"][@"latitude"];
        longitude = hdlLocation[@"hdlLocation"][@"longitude"];
        name = hdlLocation[@"hdlLocation"][@"name"];
    } @catch(NSException *exc) {}
    if (![[self class] isValidString:latitude] ||![[self class] isValidString:longitude] || ![[self class] isValidString:name] ) {
        return;
    }
    CGFloat latitudeFloatValue = [latitude floatValue];
    CGFloat longitudeFloatValue = [longitude floatValue];
    *theLatitudeFloatValue = latitudeFloatValue;
    *theLongitudeFloatValue = longitudeFloatValue;
    if (theName != NULL) {
        *theName = name;
    }
}

+ (BOOL)isValidString:(id)notValidString {
    if (!notValidString) {
        return NO;
    }
    BOOL isKindOf = NO;
    @try {
        isKindOf = [notValidString isKindOfClass:[NSString class]];
    } @catch (NSException *exception) {}
    if (!isKindOf) {
        return NO;
    }
    
    NSInteger stringLength = 0;
    @try {
        stringLength = [notValidString length];
    } @catch (NSException *exception) {}
    if (stringLength == 0) {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidJSON:(id)JSON {
    BOOL isValid;
    @try {
        isValid = ([JSON isKindOfClass:[NSDictionary class]] || [JSON isKindOfClass:[NSArray class]]);
    } @catch (NSException *exception) {}
    return isValid;
}
+ (BOOL)isValidDictionary:(id)obj {
    if ((obj != nil) && ([obj isKindOfClass:[NSDictionary class]])) {
        NSDictionary *dic = obj;
        return (dic.count > 0);
    }
    return NO;
}

+ (NSDictionary *)jsonStringToDictionary:(NSString *)jsonString {
    if (!jsonString) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

- (void)jusmAMapWithURLString:(NSString *)urlString {
    NSString *latitude;
    NSString *longitude;
    NSString *address;
    [[self class] getInfoFromAmap:urlString latitude:&latitude longitude:&longitude address:&address];
    if (!latitude || !longitude) {
//        [[self class] performOnceAliveCallbackWithCallback:self.callback success:NO];
        return;
    }
    CLLocationCoordinate2D locationCoordinate2D = CLLocationCoordinate2DMake([latitude floatValue], [longitude floatValue]);
    [self jumpMapWithName:@"高德地图" coordinate:locationCoordinate2D destinationName:address];
}

+ (void)getInfoFromAmap:(NSString *)url latitude:(NSString **)outLatitude longitude:(NSString **)outLongitude address:(NSString **)outAddress {
    //@"https://uri.amap.com/navigation?to={{coordinate.latitude}},{{coordinate.longitude}},{{address}}&src=海乐汇";
    NSString *latitude;
    NSString *longitude;
    NSString *address;
    
    NSString *toValue;
    if (!(url && url.length >0)) {
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), @"无法识别");
        return;
    }
    @synchronized (self) {
        //        @try {
        if (![url containsString:@"://"]) {
            return;
        }
        
        NSString *decodeURLString = url;//[[self class] decodeWithParemsForURLString:url];
        NSURL *theURL = [NSURL URLWithString:decodeURLString];
        NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:theURL resolvingAgainstBaseURL:NO];
        NSArray<NSURLQueryItem *> *queryItems = urlComponents.queryItems;
        
        NSPredicate *pagePredicate = [NSPredicate predicateWithFormat:@"name = 'to'"];
        //            NSPredicate *moduleIdPredicate = [NSPredicate predicateWithFormat:@"name = 'moduleId'"];
        NSArray *pagePredicateArray = [queryItems filteredArrayUsingPredicate:pagePredicate];
        //            NSArray *moduleIdPredicateArray = [queryItems filteredArrayUsingPredicate:moduleIdPredicate];
        NSLog(@"pagePredicate: %@", pagePredicateArray);
        //            NSLog(@"moduleIdPredicate: %@", moduleIdPredicateArray);
        if (!queryItems || queryItems.count == 0) {
            return;
        }
        NSURLQueryItem *pageItem = pagePredicateArray[0];
        toValue = pageItem.value;
        NSArray *array = [toValue componentsSeparatedByString:@","];
        if (!array || array.count == 0) {
            return;
        }
        
        @try {
            longitude = array[0];
            latitude = array[1];
            address = array[2];
        } @catch (NSException *exception) {
            NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), exception.reason);
        }
        
        if (outLatitude != NULL && [[self class] isValidString:latitude]) {
            *outLatitude = latitude;
        }
        if (outLongitude != NULL && [[self class] isValidString:longitude]) {
            *outLongitude = longitude;
        }
        if (outAddress != NULL && [[self class] isValidString:address]) {
            *outAddress = address;
        }
    }
}
- (void)jumpMapWithName:(NSString *)mapname coordinate:(CLLocationCoordinate2D)coordinate destinationName:(NSString *)name {
    if ([mapname isEqualToString:@"高德地图"]) {
        [self aNaviWithCoordinate:coordinate andWithMapTitle:name];
    } else if ([mapname isEqualToString:@"腾讯地图"]) {
        [self qqNaviWithCoordinate:coordinate andWithMapTitle:name];
    } else if ([mapname isEqualToString:@"Apple地图"]) {
        [self appleNaiWithCoordinate:coordinate andWithMapTitle:name];
    }
}

//唤醒苹果自带导航
- (void)appleNaiWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *tolocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    tolocation.name = map_title;
    [MKMapItem openMapsWithItems:@[currentLocation,tolocation] launchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                                                               MKLaunchOptionsShowsTrafficKey:[NSNumber numberWithBool:YES]}];
}

static NSString *mapUrlSrc = @"海乐汇";

/**
 高德导航
 */
- (void)aNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    
    
    //判断是否安装了高德地图，如果安装了高德地图，则使用高德地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]] && map_title && (map_title.length > 0)) {
        NSString *myLocationScheme = [NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&dlat=%f&dlon=%f&dname=%@&dev=0&t=0", mapUrlSrc, coordinate.latitude, coordinate.longitude, map_title];
        [self openWithUrlString:myLocationScheme isWeb:NO];

    }else {
    
        NSString *urlString = [NSString stringWithFormat:@"https://uri.amap.com/navigation?to=%f,%f%@&src=%@", coordinate.longitude, coordinate.latitude, (!(map_title && map_title.length > 0) ? @"": [NSString stringWithFormat:@",%@", map_title]), mapUrlSrc];        
        [self openWithUrlString:urlString isWeb:YES];
    }
}

/**
 腾讯地图
 */
- (void)qqNaviWithCoordinate:(CLLocationCoordinate2D)coordinate andWithMapTitle:(NSString *)map_title{
    
    //判断是否安装了腾讯地图，如果安装了腾讯地图，则使用腾讯地图导航
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        
        NSString *myLocationScheme = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&fromcoord=CurrentLocation&to=%@&tocoord=%f,%f",map_title, coordinate.latitude,coordinate.longitude];
        
        [self openWithUrlString:myLocationScheme isWeb:NO];
        
    }else {
        NSString *urlString = [NSString stringWithFormat:@"https://apis.map.qq.com/uri/v1/routeplan?type=drive&to=%@&tocoord=%f,%f&policy=0&referer=%@",map_title, coordinate.latitude, coordinate.longitude, mapUrlSrc];
        
        [self openWithUrlString:urlString isWeb:YES];
    }
}

- (void)openWithUrlString:(NSString *)urlString isWeb:(BOOL)isWeb {
//    NSURL *url = [NSURL URLWithString:urlString] ;
    NSURL *url = [NSURL URLWithString:[CYLCommonUtils encodeWithParemsForURLString:urlString]] ;

        [[UIApplication sharedApplication] openURL:url];
//    }
}

+ (NSString *)decodeWithParemsForURLString:(NSString *)URLString {
    NSString *encodeWithParemsString = [URLString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodeWithParemsString;
}

+ (NSString *)encodeWithParemsForURLString:(NSString *)URLString {
    NSString *encodeWithParemsString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return encodeWithParemsString;
}

@end
