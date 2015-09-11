//
//  SPCAddressBookFacadeContact.m
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCAddressBookFacadeContact.h"


@implementation SPCAddressBookFacadeContact

- (instancetype)initWithDisplayName:(NSString *)displayName emailAddresses:(NSArray *)emailAddresses {
    self = [super init];
    if (self) {
        self.displayName = displayName;
        self.emailAddresses = emailAddresses;
    }
    return self;
}

@end