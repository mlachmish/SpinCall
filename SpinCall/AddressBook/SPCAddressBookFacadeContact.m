//
//  SPCAddressBookFacadeContact.m
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCAddressBookFacadeContact.h"


@implementation SPCAddressBookFacadeContact

#pragma mark - Lifecycle

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName thumbnailAvatar:(UIImage *)thumbnailAvatar originalSizeAvatar:(UIImage *)originalSizeAvatar phoneNumber:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses {
    self = [super init];
    if (self) {
        self.firstName = firstName;
        self.lastName = lastName;
        self.thumbnailAvatar = thumbnailAvatar;
        self.originalSizeAvatar = originalSizeAvatar;
        self.phoneNumbers = phoneNumbers;
        self.emailAddresses = emailAddresses;
    }
    return self;
}

#pragma mark - Private

- (NSString *)displayName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName ? :@"", self.lastName ? :@""];
}

@end