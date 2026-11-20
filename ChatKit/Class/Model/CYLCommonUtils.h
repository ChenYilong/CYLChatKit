//
//  CYLCommonUtils.h
//  CYLChatKit
//
//  Created by chenyilong on 14/6/2018.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CYLCommonUtils : NSObject

+ (void)recognitionWithImage:(UIImage *)image callback:(void(^)(NSDictionary *dict))callback;
+ (void)getLocationFromDataString:(NSString *)dataString
               latitudeFloatValue:(CGFloat *)theLatitudeFloatValue
              longitudeFloatValue:(CGFloat *)theLongitudeFloatValue
                             name:(NSString **)theName;
- (void)jumpMapWithName:(NSString *)mapname coordinate:(CLLocationCoordinate2D)coordinate destinationName:(NSString *)name;
+ (void)getInfoFromAmap:(NSString *)url latitude:(NSString **)outLatitude longitude:(NSString **)outLongitude address:(NSString **)outAddress;
- (void)jusmAMapWithURLString:(NSString *)urlString;

+ (NSString *)decodeWithParemsForURLString:(NSString *)URLString;

+ (NSString *)encodeWithParemsForURLString:(NSString *)URLString;

@end
