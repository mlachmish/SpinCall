//
// Created by Matan Lachmish on 9/13/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Shortcuts)

- (CGFloat)height;

- (CGFloat)width;

- (CGFloat)top;

- (CGFloat)left;

- (CGFloat)right;

- (CGFloat)bottom;

- (void)setBottom:(CGFloat)bottom;

- (void)setRightRelativeToParent:(CGFloat)right;

- (void)setBottomRelativeToParent:(CGFloat)bottom;

- (void)setHeight:(CGFloat)height;

- (void)setWidth:(CGFloat)width;

- (void)setTop:(CGFloat)top;

- (void)setLeft:(CGFloat)left;

- (void)setRight:(CGFloat)right;

- (void)setSize:(CGSize)size;

- (void)setOrigin:(CGPoint)origin;

@end