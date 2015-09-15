//
//  SPCAddressBookFacade.h
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SPCAddressBookFacadeStatus) {
    SPCAddressBookFacadeStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    SPCAddressBookFacadeStatusRestricted,        // This application is not authorized to access address book.
    SPCAddressBookFacadeStatusDenied,            // User has explicitly denied this application access to address book.
    SPCAddressBookFacadeStatusAuthorized         // User has authorized this application to access address book.
};

extern const struct SPCAddressBookFacadePhoneNumbersListDictionaryKeys {
    __unsafe_unretained NSString *phoneLabel;
    __unsafe_unretained NSString *phoneNumber;
} SPCAddressBookFacadePhoneNumbersListDictionaryKeys;

/**
 * This is a facade for the AddressBook API.
 * The AddressBook API is very old and it is written in C, this facade should somehow ease the pain.
 * The AddressBook API was announced deprecated in iOS 9.0 and will be replaced with Contacts.framework and ContactsUI.framework
 *
 * (https://developer.apple.com/library/prerelease/ios/documentation/Contacts/Reference/Contacts_Framework/index.html#//apple_ref/doc/uid/TP40015328)
 *
 * Replacing the API will be an easy task with this facade.
 */
@interface SPCAddressBookFacade : NSObject

+ (SPCAddressBookFacadeStatus)addressBookAuthorizationStatus;
+ (void)requestAuthorization:(void (^)(SPCAddressBookFacadeStatus status))handler;

/**
 *  Retrieve the entire contact list sorted by first name.
 *
 *  @return an array populated with all your contacts.
 */
+ (NSArray *)contactList;

/**
 *  Delete the first contact matching the parameters
 *
 *  @return a BOOL indicating if succeed deleting the contact
 */
+ (BOOL)deleteContactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName;

@end