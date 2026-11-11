//
//  CYLDemoProfileNameEditViewController.h
//  ChatKit-OC
//
//  Created by 陈宜龙 on 12/14/16.
//  Copyright © 2016 ElonChan. All rights reserved.
//

#import <FXForms/FXForms.h>

@protocol CYLDemoProfileNameEditViewControllerDelegate <NSObject>

- (void)profileNameDidChanged:(NSString *)name;

@end

@interface CYLDemoProfileNameEditViewController : FXFormViewController

@property (nonatomic, copy) NSString *placeholderName;

@property (nonatomic, weak) id<CYLDemoProfileNameEditViewControllerDelegate> delegate;

@end
