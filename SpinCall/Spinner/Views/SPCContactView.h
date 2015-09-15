//
// Created by Matan Lachmish on 9/12/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SPCContactViewDelegate

@optional

- (void)tappedOutSide;
- (void)longTappedOutSide;
- (void)phoneNumberLabelTapped:(NSString *)phoneNumber;

@end

@interface SPCContactView : UIView

@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *primaryPhoneLabel;
@property (strong, nonatomic) NSString *primaryPhoneNumber;
@property (strong, nonatomic) NSString *secondaryPhoneLabel;
@property (strong, nonatomic) NSString *secondaryPhoneNumber;

@property (weak, nonatomic) id<SPCContactViewDelegate> delegate;

@end