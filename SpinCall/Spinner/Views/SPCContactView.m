//
// Created by Matan Lachmish on 9/12/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCContactView.h"
#import "UIView+Shortcuts.h"
#import "SPCAvatarImageView.h"

static CGFloat const kAvatarGutter = 70.0;
static CGFloat const kAvatarDiameter = 230.0;
static CGFloat const kNameGutter = 30.0;
static CGFloat const kPhonesGutter = 10.0;
static CGFloat const kPhonesMargin = 15.0;

typedef NS_ENUM (NSInteger, SPCContactViewPhoneLabelTags) {
    SPCContactViewPhoneLabelTagPrimary,
    SPCContactViewPhoneLabelTagSecondary,
    SPCContactViewPhoneLabelTagsCount
};

@interface SPCContactView ()

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *primaryPhoneLabelLabel;
@property (strong, nonatomic) UILabel *primaryPhoneNumberLabel;
@property (strong, nonatomic) UILabel *secondaryPhoneLabelLabel;
@property (strong, nonatomic) UILabel *secondaryPhoneNumberLabel;
@property (strong, nonatomic) SPCAvatarImageView *avatarView;
@property (strong, nonatomic) UIButton *whatsappButton;

@end

@implementation SPCContactView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _avatarView = [[SPCAvatarImageView alloc] init];
        _avatarView.foregroundColor = [UIColor lightGrayColor];
        [self addSubview:_avatarView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:24.0];
        [self addSubview:_nameLabel];

        _primaryPhoneLabelLabel = [[UILabel alloc] init];
        [self addSubview:_primaryPhoneLabelLabel];

        _primaryPhoneNumberLabel = [[UILabel alloc] init];
        _primaryPhoneNumberLabel.tag = SPCContactViewPhoneLabelTagPrimary;
        UITapGestureRecognizer *primaryPhoneNumberTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneNumberLabelTapped:)];
        [_primaryPhoneNumberLabel addGestureRecognizer:primaryPhoneNumberTapGesture];
        _primaryPhoneNumberLabel.userInteractionEnabled = YES;
        [self addSubview:_primaryPhoneNumberLabel];

        _secondaryPhoneLabelLabel = [[UILabel alloc] init];
        [self addSubview:_secondaryPhoneLabelLabel];

        _secondaryPhoneNumberLabel = [[UILabel alloc] init];
        _secondaryPhoneNumberLabel.tag = SPCContactViewPhoneLabelTagSecondary;
        UITapGestureRecognizer *secondaryPhoneNumberTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(phoneNumberLabelTapped:)];
        [_secondaryPhoneNumberLabel addGestureRecognizer:secondaryPhoneNumberTapGesture];
        _secondaryPhoneNumberLabel.userInteractionEnabled = YES;
        [self addSubview:_secondaryPhoneNumberLabel];

        _whatsappButton = [[UIButton alloc] init];
        [_whatsappButton setTitle:@"Whatsapp" forState:UIControlStateNormal];
        [_whatsappButton setTitleColor:[UIColor colorWithRed:0.33 green:0.81 blue:0.21 alpha:0.9] forState:UIControlStateNormal];
        [_whatsappButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_whatsappButton addTarget:self
                   action:@selector(didTapWhatsappButton:)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_whatsappButton];

        UITapGestureRecognizer *tappedOutSideGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOutSide:)];
        [self addGestureRecognizer:tappedOutSideGesture];

        UILongPressGestureRecognizer *longTappedOutSideGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTapOutSide:)];
        longTappedOutSideGesture.minimumPressDuration = 1;
        [self addGestureRecognizer:longTappedOutSideGesture];
    }
    return self;
}

- (void)layoutSubviews {
    self.avatarView.frame = CGRectMake(self.center.x - self.avatarView.width/2, kAvatarGutter, kAvatarDiameter, kAvatarDiameter);

    self.nameLabel.frame = CGRectMake(self.center.x - self.nameLabel.width/2, self.avatarView.bottom + kNameGutter, 0, 0);
    [self.nameLabel sizeToFit];

    self.primaryPhoneLabelLabel.frame = CGRectMake(self.center.x - (self.primaryPhoneLabelLabel.width+self.primaryPhoneNumberLabel.width + kPhonesMargin)/2, self.nameLabel.bottom + kPhonesGutter, 0, 0);
    [self.primaryPhoneLabelLabel sizeToFit];

    self.primaryPhoneNumberLabel.frame = CGRectMake(self.primaryPhoneLabelLabel.right + kPhonesMargin, self.primaryPhoneLabelLabel.top, 0, 0);
    [self.primaryPhoneNumberLabel sizeToFit];

    self.secondaryPhoneLabelLabel.frame = CGRectMake(self.center.x - (self.secondaryPhoneLabelLabel.width+self.secondaryPhoneNumberLabel.width + kPhonesMargin)/2, self.primaryPhoneLabelLabel.bottom + kPhonesMargin, 0, 0);
    [self.secondaryPhoneLabelLabel sizeToFit];

    self.secondaryPhoneNumberLabel.frame = CGRectMake(self.secondaryPhoneLabelLabel.right + kPhonesMargin, self.secondaryPhoneLabelLabel.top, 0, 0);
    [self.secondaryPhoneNumberLabel sizeToFit];

    self.whatsappButton.frame = CGRectMake(self.center.x - self.whatsappButton.width/2, self.secondaryPhoneLabelLabel.bottom + kPhonesMargin, 0, 0);
    [self.whatsappButton sizeToFit];
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

- (void)setPrimaryPhoneLabel:(NSString *)primaryPhoneLabel {
    _primaryPhoneLabel = primaryPhoneLabel;
    self.primaryPhoneLabelLabel.text = primaryPhoneLabel;
    [self layoutSubviews];
}

- (void)setPrimaryPhoneNumber:(NSString *)primaryPhoneNumber {
    _primaryPhoneNumber = primaryPhoneNumber;
    self.primaryPhoneNumberLabel.text = primaryPhoneNumber;
    [self layoutSubviews];
}

- (void)setSecondaryPhoneLabel:(NSString *)secondaryPhoneLabel {
    _secondaryPhoneLabel = secondaryPhoneLabel;
    self.secondaryPhoneLabelLabel.text = secondaryPhoneLabel;
    [self layoutSubviews];
}

- (void)setSecondaryPhoneNumber:(NSString *)secondaryPhoneNumber {
    _secondaryPhoneNumber = secondaryPhoneNumber;
    self.secondaryPhoneNumberLabel.text = secondaryPhoneNumber;
    [self layoutSubviews];
}

- (void)setIsWhatsappAvailable:(BOOL)isWhatsappAvailable {
    _isWhatsappAvailable = isWhatsappAvailable;
    self.whatsappButton.enabled = isWhatsappAvailable;
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

#pragma mark - Private

- (void)handleTapOutSide:(UITapGestureRecognizer *)recognizer {
    [self.delegate tappedOutSide];
}

- (void)handleLongTapOutSide:(UITapGestureRecognizer *)recognizer {
    [self.delegate longTappedOutSide];
}

- (void)phoneNumberLabelTapped:(UITapGestureRecognizer *)recognizer {
    if (recognizer.view.tag == SPCContactViewPhoneLabelTagPrimary) {
        [self.delegate phoneNumberLabelTapped:self.primaryPhoneNumberLabel.text];
    } else if (recognizer.view.tag == SPCContactViewPhoneLabelTagSecondary) {
        [self.delegate phoneNumberLabelTapped:self.secondaryPhoneNumberLabel.text];
    }
}

- (void)didTapWhatsappButton:(id)didTapWhatsappButton {
    [self.delegate didTapWhatsappButton];
}

@end