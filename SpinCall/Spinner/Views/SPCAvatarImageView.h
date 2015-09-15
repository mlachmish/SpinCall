//
// Created by Matan Lachmish on 9/14/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SPCAvatarImageView : UIImageView

@property(strong, nonatomic) UIColor *foregroundColor;
@property(strong, nonatomic) UIFont* initialsFont;

@property(strong, nonatomic) UIColor *avatarBorderColor;
@property(assign, nonatomic) CGFloat avatarBorderWidth;

@property(strong, nonatomic) UIColor *noImageBorderColor;
@property(assign, nonatomic) BOOL showBorder;

- (void)setAvatarName:(NSString*)name;

@end