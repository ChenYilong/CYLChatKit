//
//  CYLDemoDataSource.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 5/28/14.
//  Copyright (c) 2014 Mainloop. All rights reserved.
//
@import UIKit;
@import Foundation;

///-----------------------------------------------------------------------------------
///---------------------用以产生Demo中的联系人数据的宏定义-------------------------------
///-----------------------------------------------------------------------------------

#define CYLDemoDSProfileKeyPeerId        @"peerId"
#define CYLDemoDSProfileKeyName          @"username"
#define CYLDemoDSProfileKeyAvatarURL     @"avatarURL"
#define CYLDemoDSDeveloperPeerId @"571dae7375c4cd3379024b2f"

//TODO:add more friends
#define CYLDemoDSContactProfiles \
@[ \
    @{ CYLDemoDSProfileKeyPeerId:CYLDemoDSDeveloperPeerId, CYLDemoDSProfileKeyName:@"CYLChatKit小秘书", CYLDemoDSProfileKeyAvatarURL:@"http://image17-c.poco.cn/mypoco/myphoto/20151211/16/17338872420151211164742047.png" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Tom", CYLDemoDSProfileKeyName:@"Tom", CYLDemoDSProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/tom_and_jerry2.jpg" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Jerry", CYLDemoDSProfileKeyName:@"Jerry", CYLDemoDSProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/jerry.jpg" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Harry", CYLDemoDSProfileKeyName:@"Harry", CYLDemoDSProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/young_harry.jpg" },\
    @{ CYLDemoDSProfileKeyPeerId:@"William", CYLDemoDSProfileKeyName:@"William", CYLDemoDSProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/william_shakespeare.jpg" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Bob", CYLDemoDSProfileKeyName:@"Bob", CYLDemoDSProfileKeyAvatarURL:@"http://www.avatarsdb.com/avatars/bath_bob.jpg" },\
]

#define CYLDemoDSContactPeerIds \
    [CYLDemoDSContactProfiles valueForKeyPath:CYLDemoDSProfileKeyPeerId]

#define CYLDemoDSTestPersonProfiles \
@[ \
    @{ CYLDemoDSProfileKeyPeerId:@"Tom" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Jerry" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Harry" },\
    @{ CYLDemoDSProfileKeyPeerId:@"William" },\
    @{ CYLDemoDSProfileKeyPeerId:@"Bob" },\
]

#define CYLDemoDSTestPeerIds \
    [CYLDemoDSTestPersonProfiles valueForKeyPath:CYLDemoDSProfileKeyPeerId]


#import "CYLDemoDataSource.h"
#import "CYLDemoCustomAutoCompleteObject.h"

@interface CYLDemoDataSource ()

@property (strong, nonatomic) NSArray *countryObjects;

@end


@implementation CYLDemoDataSource


#pragma mark - MLPAutoCompleteTextField DataSource


//example of asynchronous fetch:
- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
            completionHandler:(void (^)(NSArray *))handler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(queue, ^{
        if(self.simulateLatency){
            CGFloat seconds = arc4random_uniform(4)+arc4random_uniform(4); //normal distribution
            NSLog(@"sleeping fetch of completions for %f", seconds);
            sleep(seconds);
        }
        
        NSArray *completions;
        if(self.testWithAutoCompleteObjectsInsteadOfStrings){
            completions = [self allCountryObjects];
        } else {
            completions = [self allCountries];
        }
        
        handler(completions);
    });
}

/*
 - (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
 possibleCompletionsForString:(NSString *)string
 {
 
 if(self.simulateLatency){
 CGFloat seconds = arc4random_uniform(4)+arc4random_uniform(4); //normal distribution
 NSLog(@"sleeping fetch of completions for %f", seconds);
 sleep(seconds);
 }
 
 NSArray *completions;
 if(self.testWithAutoCompleteObjectsInsteadOfStrings){
 completions = [self allCountryObjects];
 } else {
 completions = [self allCountries];
 }
 
 return completions;
 }
 */

- (NSArray *)allCountryObjects
{
    if(!self.countryObjects){
        NSArray *countryNames = [self allCountries];
        NSMutableArray *mutableCountries = [NSMutableArray new];
        for(NSString *countryName in countryNames){
            CYLDemoCustomAutoCompleteObject *country = [[CYLDemoCustomAutoCompleteObject alloc] initWithCountry:countryName];
            [mutableCountries addObject:country];
        }
        
        [self setCountryObjects:[NSArray arrayWithArray:mutableCountries]];
    }
    
    return self.countryObjects;
}


- (NSArray *)allCountries
{
    NSArray *countries = CYLDemoDSTestPeerIds;
    
    return countries;
}





@end
