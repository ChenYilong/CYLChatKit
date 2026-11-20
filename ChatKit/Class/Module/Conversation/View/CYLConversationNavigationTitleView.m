//
//  CYLConversationNavigationTitleView.m
//  Pods
//
//  v2.1.1 Created by ElonChan on 16/7/19.
//
//

#import "CYLConversationNavigationTitleView.h"
#import "NSString+CYLExtension.h"
#import "UIImageView+CYLExtension.h"

#if __has_include(<CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>)
#import <CYLDeallocBlockExecutor/CYLDeallocBlockExecutor.h>
#else
#import "CYLDeallocBlockExecutor.h"
#endif
#if __has_include(<CYLChatKit/CYLChatKit.h>)
#import <CYLChatKit/CYLChatKit.h>
#else
#import "CYLChatKit.h"
#endif
static CGFloat const kCYLTitleFontSize = 17.f;

static void * const CYLConversationViewControllerMutedContext = (void*)&CYLConversationViewControllerMutedContext;
static void * const CYLConversationViewControllerNameContext = (void*)&CYLConversationViewControllerNameContext;
static void * const CYLConversationViewControllerMembersCountContext = (void*)&CYLConversationViewControllerMembersCountContext;

@interface CYLConversationNavigationTitleView ()

@property (nonatomic, strong) UILabel *conversationNameView;
@property (nonatomic, strong) UILabel *membersCountView;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) UIStackView *containerView;
@property (nonatomic, strong) UIImageView *remindMuteImageView;
@property (nonatomic, copy) NSString *conversationName;
@property (nonatomic, strong) id<CYLConversationProtocol> conversation;
@end

@implementation CYLConversationNavigationTitleView

- (UIStackView *)containerView {
    if (!_containerView) {
        UIStackView *containerView = [[UIStackView alloc] initWithFrame:CGRectZero];
        containerView.axis = UILayoutConstraintAxisHorizontal;
        containerView.distribution = UIStackViewDistributionFill;
        containerView.alignment = UIStackViewAlignmentCenter;
        
        containerView.frame = ({
            CGRect frame = containerView.frame;
            CGFloat containerViewHeight = self.navigationController.navigationBar.frame.size.height;
            CGFloat containerViewWidth = self.navigationController.navigationBar.frame.size.width - 130;
            frame.size.width = containerViewWidth;
            frame.size.height = containerViewHeight;
            frame;
        });
        [containerView addArrangedSubview:self.conversationNameView];
        [containerView addArrangedSubview:self.membersCountView];
        [containerView addArrangedSubview:self.remindMuteImageView];
        _containerView = containerView;
    }
    return _containerView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    dispatch_async(dispatch_get_main_queue(),^{
        if(context == CYLConversationViewControllerMutedContext) {
            id newKey = change[NSKeyValueChangeNewKey];
            BOOL muted = [newKey boolValue];
            self.remindMuteImageView.hidden = !muted;
            [self.containerView layoutIfNeeded];
        } else if(context == CYLConversationViewControllerNameContext) {
            [self resetConversationNameWithMembersCountChanged:NO];
        } else if (context == CYLConversationViewControllerMembersCountContext) {
            [self resetConversationName];
        }
    });
}

- (instancetype)sharedInitWithConversation:(id<CYLConversationProtocol>)conversation {
    [self addSubview:self.containerView];
    [(NSObject *)conversation addObserver:self forKeyPath:@"muted" options:NSKeyValueObservingOptionNew context:CYLConversationViewControllerMutedContext];
    [(NSObject *)conversation addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:CYLConversationViewControllerNameContext];
    [(NSObject *)conversation addObserver:self forKeyPath:@"members.@count" options:NSKeyValueObservingOptionNew context:CYLConversationViewControllerMembersCountContext];
    [self cyl_willDeallocWithSelfCallback:^(__unsafe_unretained id owner, NSUInteger identifier) {
        [(NSObject *)conversation removeObserver:owner forKeyPath:@"muted"];
        [(NSObject *)conversation removeObserver:owner forKeyPath:@"name"];
        [(NSObject *)conversation removeObserver:owner forKeyPath:@"members.@count"];
    }];
    
    [self.containerView layoutIfNeeded];//fix member count view won't display when conversationNameView is too long
    return self;
}

- (instancetype)initWithConversation:(id<CYLConversationProtocol>)conversation navigationController:(UINavigationController *)navigationController {
    if (self = [super init]) {
        _conversation = conversation;
        [self resetConversationName];
        [self setupWithNavigationController:navigationController];
        self.remindMuteImageView.hidden = !conversation.muted;
    }
    return self;
}

- (void)setupWithNavigationController:(UINavigationController *)navigationController {
    self.navigationController = navigationController;
    [self sharedInitWithConversation:self.conversation];
}

- (UIImageView *)remindMuteImageView {
    if (_remindMuteImageView == nil) {
        UIImageView *remindMuteImageView = [[UIImageView alloc] init];
        NSString *remindMuteImageName = @"Connectkeyboad_banner_mute";
        UIImage *remindMuteImage = [UIImage cyl_imageNamed:remindMuteImageName bundleName:@"Other" bundleForClass:[CYLChatKit class]];
        remindMuteImageView.contentMode = UIViewContentModeScaleAspectFill;
        remindMuteImageView.image = remindMuteImage;
        remindMuteImageView.hidden = YES;
        [remindMuteImageView sizeToFit];
        _remindMuteImageView = remindMuteImageView;
    }
    return _remindMuteImageView;
}

- (UILabel *)conversationNameView {
    if (!_conversationNameView) {
        UILabel *conversationNameView = [[UILabel alloc] initWithFrame:CGRectZero];
        conversationNameView.font = [UIFont boldSystemFontOfSize:kCYLTitleFontSize];
        conversationNameView.textColor = [UIColor blackColor];
        conversationNameView.textAlignment = NSTextAlignmentCenter;
        [conversationNameView sizeToFit];
        conversationNameView.lineBreakMode = NSLineBreakByTruncatingTail;
        _conversationNameView = conversationNameView;
    }
    return _conversationNameView;
}

- (UILabel *)membersCountView {
    if (!_membersCountView) {
        UILabel *membersCountView = [[UILabel alloc] initWithFrame:CGRectZero];
        membersCountView.font = [UIFont boldSystemFontOfSize:kCYLTitleFontSize];
        membersCountView.textColor = [UIColor whiteColor];
        membersCountView.textAlignment = NSTextAlignmentCenter;
        [membersCountView sizeToFit];
        membersCountView.hidden = YES;
        _membersCountView = membersCountView;
    }
    return _membersCountView;
}

#pragma mark -
#pragma mark - Private Methods
//2018-06-20 02:01:09.641036+0800 ChatKit-OC[26054:8518941] *** -[CYLConversationNavigationTitleView conversationNameView]: message sent to deallocated instance 0x7fa90694af80

- (void)resetConversationName {
    [self resetConversationNameWithMembersCountChanged:YES];
}

- (void)resetConversationNameWithMembersCountChanged:(BOOL)membersCountChanged {
    NSString *conversationName;
    if ([self.conversation.cyl_displayName cyl_containsString:@","]) {
        self.membersCountView.hidden = NO;
        conversationName = self.conversation.cyl_displayName;
    } else {
        self.membersCountView.hidden = YES;
        conversationName = self.conversation.cyl_title;
    }
    if (conversationName.length == 0 || !conversationName) {
        conversationName = CYLLocalizedStrings(@"Chat");
    }
    self.conversationNameView.text = conversationName;
    if (membersCountChanged) {
        NSUInteger membersCount = self.conversation.members.count;
        self.membersCountView.text = [NSString stringWithFormat:@"(%@)", @(membersCount)];
    }
}

@end
