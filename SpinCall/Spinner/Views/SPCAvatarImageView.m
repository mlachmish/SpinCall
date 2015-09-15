//
// Created by Matan Lachmish on 9/14/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCAvatarImageView.h"

static NSString *const kFontHelveticaNeueLight = @"HelveticaNeue-Light";

@implementation SPCAvatarImageView {

    UILabel *_initialsLabel;
    BOOL _showDefaultImage;
    BOOL _isSquared;

}

#pragma mark - Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.borderWidth = 1.0;
        self.backgroundColor = [UIColor whiteColor];
        self.foregroundColor = [UIColor lightGrayColor];
        self.contentMode = UIViewContentModeScaleAspectFit;

        _initialsLabel = [[UILabel alloc] init];
        _initialsLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_initialsLabel];

        _avatarBorderWidth = 1.0f;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (!_initialsFont) {
        CGFloat fontSize = CGRectGetHeight(self.bounds) / 3;
        _initialsLabel.font = [UIFont fontWithName:kFontHelveticaNeueLight size:ceilf(fontSize)];
    }
    else {
        _initialsLabel.font = _initialsFont;
    }

    [_initialsLabel sizeToFit];
    _initialsLabel.frame = CGRectMake(0, (self.frame.size.height - _initialsLabel.frame.size.height) / 2, self.frame.size.width, _initialsLabel.frame.size.height);

    if (!_isSquared) {
        [SPCAvatarImageView roundUIImageView:self];
    } else {
        self.layer.cornerRadius = 0;
    }
}

#pragma mark - Custom Setters

- (void)setShowBorder:(BOOL)showBorder {
    _showBorder = showBorder;

    if (_initialsLabel.hidden) {
        self.layer.borderWidth = _showBorder ? _avatarBorderWidth : 0;
    }
}

- (void)setImage:(UIImage *)image {
    if (!image && _showDefaultImage) {
        image = [UIImage imageNamed:@"EmptyAvatarPlaceHolder"];
    }

    if (image) {
        _initialsLabel.hidden = YES;
        self.layer.borderWidth = self.showBorder ? _avatarBorderWidth : 0;
        self.layer.borderColor = self.avatarBorderColor.CGColor;
    } else {
        _initialsLabel.hidden = NO;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = self.noImageBorderColor.CGColor;
    }

    super.image = image;

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    _avatarBorderColor = _avatarBorderColor ? _avatarBorderColor : foregroundColor;
    _noImageBorderColor = _noImageBorderColor ? _noImageBorderColor : foregroundColor;
    _initialsLabel.textColor = foregroundColor;
}

#pragma mark - Public

- (void)setAvatarName:(NSString*)name {
    _showDefaultImage = NO;
    self.image = nil;
    [self updateInitialsFromUserName:name];

    [self setNeedsLayout];
}

#pragma mark - Private

- (void)updateInitialsFromUserName:(NSString *)username {
    NSArray *splitUserName = [username componentsSeparatedByString:@" "];
    NSMutableString *initials = [[NSMutableString alloc] init];

    for (NSString *partialName in splitUserName) {
        if ([partialName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0) {
            [initials appendString:[partialName substringToIndex:1]];

            if (initials.length == 2) {
                break;
            }
        }
    }

    _initialsLabel.text = initials.length == 0 ? @"!" : initials;
}

#pragma mark - Private Class Methods

+ (void)roundUIImageView:(UIImageView *)imageView {
    imageView.layer.cornerRadius = imageView.bounds.size.width / 2;
    imageView.clipsToBounds = YES;
}

@end