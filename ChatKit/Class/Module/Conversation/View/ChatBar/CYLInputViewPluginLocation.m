//
//  CYLInputViewPluginLocation.m
//  Pods
//
//  v2.1.1 Created by ElonChan on 18/6/11.
//
//

#import "CYLInputViewPluginLocation.h"
#import "CYLLocationController.h"

@interface CYLInputViewPluginLocation()<CYLLocationControllerDelegate>

@property (nonatomic, strong) CYLLocationController *locationController;

@end

@implementation CYLInputViewPluginLocation
@synthesize inputViewRef = _inputViewRef;
@synthesize sendCustomMessageHandler = _sendCustomMessageHandler;

#pragma mark -
#pragma mark - CYLInputViewPluginSubclassing Method

+ (CYLInputViewPluginType)classPluginType {
    return CYLInputViewPluginTypeLocation;
}

#pragma mark -
#pragma mark - CYLInputViewPluginDelegate Method

/*!
 * 插件图标
 */
- (UIImage *)pluginIconImage {
    return [self imageInBundlePathForImageName:@"chat_bar_icons_location"];
}

/*!
 * 插件名称
 */
- (NSString *)pluginTitle {
    return @"位置";
}

/*!
 * 插件对应的 view，会被加载到 inputView 上
 */
- (UIView *)pluginContentView {
    return nil;
}

/**
 *  lazy load locationController
 *
 *  @return CYLLocationController
 */
- (CYLLocationController *)locationController {
    if (_locationController == nil) {
        CYLLocationController *locationController = [[CYLLocationController alloc] init];
        locationController.delegate = self;
        _locationController = locationController;
    }
    return _locationController;
}

- (void)pluginDidClicked {
    [super pluginDidClicked];
    //显示地理位置
    UINavigationController *locationNav = [[UINavigationController alloc] initWithRootViewController:self.locationController];
    [self.conversationViewController presentViewController:locationNav animated:YES completion:nil];
}

- (CYLIdResultBlock)sendCustomMessageHandler {
    if (_sendCustomMessageHandler) {
        return _sendCustomMessageHandler;
    }
    CYLIdResultBlock sendCustomMessageHandler = ^(id object, NSError *error) {
        [self.conversationViewController dismissViewControllerAnimated:YES completion:nil];
        if (object) {
            CLPlacemark *placemark = (CLPlacemark *)object;
            [self.conversationViewController sendLocationMessageWithLocationCoordinate:placemark.location.coordinate locatioTitle:placemark.name];
        }
        _sendCustomMessageHandler = nil;
    };
    _sendCustomMessageHandler = sendCustomMessageHandler;
    return sendCustomMessageHandler;
}

#pragma mark -
#pragma mark - Private Methods

- (UIImage *)imageInBundlePathForImageName:(NSString *)imageName {
    UIImage *image = [UIImage cyl_imageNamed:imageName bundleName:@"ChatKeyboard" bundleForClass:[self class]];
    return image;
}

#pragma mark - CYLLocationControllerDelegate

- (void)sendLocation:(CLPlacemark *)placemark {
    !self.sendCustomMessageHandler ?: self.sendCustomMessageHandler(placemark, nil);
}

- (void)cancelLocation {
    NSInteger code = 0;
    NSString *errorReasonText = @"cancel location without result";
    NSDictionary *errorInfo = @{
                                @"code":@(code),
                                NSLocalizedDescriptionKey : errorReasonText,
                                };
    NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                         code:code
                                     userInfo:errorInfo];
    !self.sendCustomMessageHandler ?: self.sendCustomMessageHandler(nil, error);
}

@end
