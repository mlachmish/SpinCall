//
// Created by Matan Lachmish on 9/12/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCContactView.h"
#import "UIView+Shortcuts.h"
#import "SPCAvatarImageView.h"

static CGFloat const kAvatarGutter = 70.0;
static CGFloat const kAvatarDiameter = 230.0;
static CGFloat const kMargin = 15.0;

@interface SPCContactView ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *phoneLabelLabel;
@property (strong, nonatomic) UILabel *phoneNumberLabel;
@property (strong, nonatomic) SPCAvatarImageView *avatarView;

@end

@implementation SPCContactView {

}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[SPCAvatarImageView alloc] init];
        [self addSubview:_avatarView];

        _nameLabel = [[UILabel alloc] init];
        [self addSubview:_nameLabel];

        _phoneLabelLabel = [[UILabel alloc] init];
        [self addSubview:_phoneLabelLabel];

        _phoneNumberLabel = [[UILabel alloc] init];
        [self addSubview:_phoneNumberLabel];
    }
    return self;
}

- (void)layoutSubviews {
    self.avatarView.frame = CGRectMake(self.center.x - self.avatarView.width/2, kAvatarGutter, kAvatarDiameter, kAvatarDiameter);

    self.nameLabel.frame = CGRectMake(self.center.x - self.nameLabel.width/2, self.avatarView.bottom + kMargin, 0, 0);
    [self.nameLabel sizeToFit];

    self.phoneLabelLabel.frame = CGRectMake(self.center.x - (self.phoneLabelLabel.width+self.phoneNumberLabel.width + kMargin)/2, self.nameLabel.bottom + kMargin, 0, 0);
    [self.phoneLabelLabel sizeToFit];

    self.phoneNumberLabel.frame = CGRectMake(self.phoneLabelLabel.right + kMargin, self.phoneLabelLabel.top, 0, 0);
    [self.phoneNumberLabel sizeToFit];
}

#pragma mark - Custom Setters

-(void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;

    if (!self.avatar) {
        [self.avatarView setAvatarName:self.name];
    }

    [self layoutSubviews];
}

- (void)setPhoneLabel:(NSString *)phoneLabel {
    _phoneLabel = phoneLabel;
    self.phoneLabelLabel.text = phoneLabel;
    [self layoutSubviews];
}

- (void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    self.phoneNumberLabel.text = phoneNumber;
    [self layoutSubviews];
}

- (void)setAvatar:(UIImage *)avatar {
    _avatar = avatar;

    if (avatar) {
        self.avatarView.image = avatar;
    } else {
        [self.avatarView setAvatarName:self.name];
    }

    [self layoutSubviews];
}

@end