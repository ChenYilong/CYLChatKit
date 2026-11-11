//
//  MLPViewController.h
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 1/23/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPAutoCompleteTextFieldDelegate.h"

@class CYLDemoDataSource;
@class MLPAutoCompleteTextField;

typedef void (^CYLDemoClientIDHandler)(NSString *clientID);

@interface CYLDemoLoginViewController : UIViewController <UITextFieldDelegate, MLPAutoCompleteTextFieldDelegate>

@property (strong, nonatomic) IBOutlet CYLDemoDataSource *autocompleteDataSource;
@property (weak) IBOutlet MLPAutoCompleteTextField *autocompleteTextField;
@property (strong, nonatomic) IBOutlet UILabel *demoTitle;
@property (strong, nonatomic) IBOutlet UILabel *author;
/// When YES, logs in with the last saved client ID on launch (restored; AppDelegate sets it).
@property (nonatomic, assign, getter=isAutoLogin) BOOL autoLogin;

- (void)setClientIDHandler:(CYLDemoClientIDHandler)clientIDHandler;

@end
