//
//  SPCAddressBookFacadeContact.h
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This is part of the address book facade API.
 * This class replace the use of the C style ABRecordRef class.
 */
@interface SPCAddressBookFacadeContact : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSArray *emailAddresses;

- (instancetype)initWithDisplayName:(NSString *)displayName emailAddresses:(NSArray *)emailAddresses;
@end