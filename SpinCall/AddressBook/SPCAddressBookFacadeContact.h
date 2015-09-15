//
//  SPCAddressBookFacadeContact.h
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This is part of the address book facade API.
 * This class replace the use of the C style ABRecordRef class.
 */
@interface SPCAddressBookFacadeContact : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong, readonly) NSString *displayName;
@property (nonatomic, strong) UIImage *avatar;
@property (nonatomic, strong) NSArray *phoneNumbers;
@property (nonatomic, strong) NSArray *emailAddresses;

- (instancetype)initWithFirstName:(NSString *)firstName lastName:(NSString *)lastName avatar:(UIImage *)avatar phoneNumber:(NSArray *)phoneNumbers emailAddresses:(NSArray *)emailAddresses;
@end