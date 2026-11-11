//
//  CYLInputViewPlugin.m
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

#import "CYLInputViewPlugin.h"

#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif

#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NSMutableDictionary const *CYLInputViewPluginDict = nil;
NSMutableArray const *CYLInputViewPluginArray = nil;

@interface CYLInputViewPlugin ()

@property (nonatomic, readwrite) CYLInputViewPluginType pluginType;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, strong) UIColor *messageInputViewMorePanelTextColor;

@end

@implementation CYLInputViewPlugin
@synthesize delegate = _delegate;
@synthesize inputViewRef = _inputViewRef;
@synthesize pluginContentView = _pluginContentView;
@synthesize pluginType = _pluginType;
@synthesize pluginIconImage = _pluginIconImage;
@synthesize pluginTitle = _pluginTitle;
@synthesize sendCustomMessageHandler = _sendCustomMessageHandler;

- (instancetype)init {
    if (![self conformsToProtocol:@protocol(CYLInputViewPluginSubclassing)]) {
        //TODO: add debug model
        NSLog(@"🔴类名与方法名：%@（在第%@行），描述：%@", @(__PRETTY_FUNCTION__), @(__LINE__), [NSString stringWithFormat:@"%@ %@", @"Class does not conform CYLInputViewPluginSubclassing protocol."]);
        return nil;
    }
    if ((self = [super init])) {
        self.pluginType = [[self class] classPluginType];
    }
    return self;
}

+ (void)registerCustomInputViewPlugin {
    [self registerSubclass];
}

+ (void)registerSubclass {
    if ([self conformsToProtocol:@protocol(CYLInputViewPluginSubclassing)]) {
        Class<CYLInputViewPluginSubclassing> class = self;
        CYLInputViewPluginType type = [class classPluginType];
        [self registerClass:class forMediaType:type];
    }
}

+ (Class)classForMediaType:(CYLInputViewPluginType)type {
    NSNumber *typeKey = [NSNumber numberWithInteger:type];
    Class class = [CYLInputViewPluginDict objectForKey:typeKey];
    if (!class) {
        class = self;
    }
    return class;
}

+ (void)registerClass:(Class)class forMediaType:(CYLInputViewPluginType)type {
    if (!CYLInputViewPluginDict) {
        CYLInputViewPluginDict = [[NSMutableDictionary alloc] init];
    }
    if (!CYLInputViewPluginArray) {
        CYLInputViewPluginArray = [[NSMutableArray alloc] init];
    }
    NSNumber *typeKey = [NSNumber numberWithInteger:type];
    Class c = [CYLInputViewPluginDict objectForKey:typeKey];
    if (!c || [class isSubclassOfClass:c]) {
        [CYLInputViewPluginDict setObject:class forKey:typeKey];
        NSDictionary *dictionary = @{
                                     CYLInputViewPluginTypeKey : typeKey,
                                     CYLInputViewPluginClassKey : class,
                                     };
        [CYLInputViewPluginArray addObject:dictionary];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{
    [self setup];
}

- (void)updateConstraints{
    [super updateConstraints];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(4);
        make.centerX.equalTo(self);
        make.width.equalTo(@50);
        make.height.equalTo(@50);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.button.mas_bottom).with.offset(3);
        make.centerX.equalTo(self.mas_centerX);
    }];
}

#pragma mark - Public Methods

- (void)fillWithPluginTitle:(NSString *)pluginTitle
            pluginIconImage:(UIImage *)pluginIconImage {
    self.titleLabel.text = pluginTitle;
    [self.button setBackgroundImage:pluginIconImage forState:UIControlStateNormal];
}

#pragma mark - Private Methods

- (void)setup {
    [self addSubview:self.button];
    [self addSubview:self.titleLabel];
    [self updateConstraintsIfNeeded];
}

- (void)buttonAction {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.button setHighlighted:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self.button setHighlighted:NO];
}

#pragma mark - Getters
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _titleLabel.textColor = self.messageInputViewMorePanelTextColor;
    }
    return _titleLabel;
}

- (void)pluginDidClicked {
    [self sendCustomMessageHandler];
}

- (CYLConversationViewController *)conversationViewController {
    if ([self.inputViewRef.controllerRef isKindOfClass:[CYLConversationViewController class]]) {
        return (CYLConversationViewController *)self.inputViewRef.controllerRef;
    } else {
        return nil;
    }
}

- (UIColor *)messageInputViewMorePanelTextColor {
    if (_messageInputViewMorePanelTextColor) {
        return _messageInputViewMorePanelTextColor;
    }
    _messageInputViewMorePanelTextColor = [[CYLSettingService sharedInstance] defaultThemeColorForKey:@"MessageInputView-MorePanel-TextColor"];
    return _messageInputViewMorePanelTextColor;
}

@end
