//
//  MLPViewController.m
//  MLPAutoCompleteDemo
//
//  Created by Eddy Borja on 1/23/13.
//  Copyright (c) 2013 Mainloop. All rights reserved.
//

#import "LCCKLoginViewController.h"
#import "MLPAutoCompleteTextField.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#if __has_include(<ChatKit/LCChatKit.h>)
#import <ChatKit/LCChatKit.h>
#else
#import "LCChatKit.h"
#endif

@interface LCCKLoginViewController ()

@property (nonatomic, copy) LCCKClientIDHandler clientIDHandler;

@end

@implementation LCCKLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [self.view setAlpha:0];
    [UIView animateWithDuration:0.2
                          delay:0.25
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.view setAlpha:1.0];
                     }completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.autocompleteTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [self.autocompleteTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self.autocompleteTextField];
    self.autocompleteTextField.autoCompleteTableViewHidden = NO;
}

- (void)setClientIDHandler:(LCCKClientIDHandler)clientIDHandler {
    _clientIDHandler = clientIDHandler;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    !_clientIDHandler ?: _clientIDHandler(textField.text);
    return YES;
}

#pragma mark - MLPAutoCompleteTextField Delegate


- (BOOL)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
          shouldConfigureCell:(UITableViewCell *)cell
       withAutoCompleteString:(NSString *)autocompleteString
         withAttributedString:(NSAttributedString *)boldedString
        forAutoCompleteObject:(id<MLPAutoCompletionObject>)autocompleteObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
    //This is your chance to customize an autocomplete tableview cell before it appears in the autocomplete tableview
    NSURL *avatorURL;
    for (NSDictionary *user in LCCKContactProfiles) {
        if ([autocompleteString isEqualToString:user[LCCKProfileKeyPeerId]]) {
            avatorURL = [NSURL URLWithString:user[LCCKProfileKeyAvatarURL]];
        }
    }
    UIImage *image = [UIImage imageNamed:@"image_placeholder"];
    [cell.imageView sd_setImageWithURL:avatorURL placeholderImage:image];
    return YES;
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
  didSelectAutoCompleteString:(NSString *)selectedString
       withAutoCompleteObject:(id<MLPAutoCompletionObject>)selectedObject
            forRowAtIndexPath:(NSIndexPath *)indexPath {
        !_clientIDHandler ?: _clientIDHandler(selectedString);
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be removed from the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField willShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view will be added to the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didHideAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view ws removed from the view hierarchy");
}

- (void)autoCompleteTextField:(MLPAutoCompleteTextField *)textField didShowAutoCompleteTableView:(UITableView *)autoCompleteTableView {
    NSLog(@"Autocomplete table view was added to the view hierarchy");
}

@end
