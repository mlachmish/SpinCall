//
// Created by Matan Lachmish on 9/13/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "UIView+Shortcuts.h"


@implementation UIView (Shortcuts)

#pragma mark - Custom Getters

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

#pragma mark - Custom Setters

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (void)setBottomRelativeToParent:(CGFloat)bottom {
    CGRect rect = self.frame;
    rect.origin.y = CGRectGetHeight(self.superview.bounds) - bottom - CGRectGetHeight(rect);
    self.frame = rect;
}

- (void)setRightRelativeToParent:(CGFloat)right {
    CGRect rect = self.frame;
    rect.origin.x = CGRectGetWidth(self.superview.bounds) - right - CGRectGetWidth(rect);
    self.frame = rect;
}

- (void)setHeight:(CGFloat)height {
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (void)setWidth:(CGFloat)width {
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (void)setTop:(CGFloat)top {
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (void)setLeft:(CGFloat)left {
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (void)setRight:(CGFloat)right {
    CGRect rect = self.frame;
    rect.origin.x = right - rect.size.width;
    self.frame = rect;
}

- (void)setSize:(CGSize)size {
    CGRect rect = self.frame;
    rect.size = size;
    self.frame = rect;

}

- (void)setOrigin:(CGPoint)origin {
    CGRect rect = self.frame;
    rect.origin = origin;
    self.frame = rect;

}

@end