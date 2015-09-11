//
//  SPCAddressBookFacade.m
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCAddressBookFacade.h"
#import "SPCAddressBookFacadeContact.h"

#import <AddressBook/AddressBook.h>

@implementation SPCAddressBookFacade

#pragma mark - Public

+ (SPCAddressBookFacadeStatus)addressBookAuthorizationStatus {
    switch (ABAddressBookGetAuthorizationStatus()) {
        case  kABAuthorizationStatusAuthorized:
            return SPCAddressBookFacadeStatusAuthorized;
            break;
        case  kABAuthorizationStatusNotDetermined:
            return SPCAddressBookFacadeStatusNotDetermined;
            break;
        case  kABAuthorizationStatusDenied:
            return SPCAddressBookFacadeStatusDenied;
            break;
        case  kABAuthorizationStatusRestricted:
            return SPCAddressBookFacadeStatusRestricted;
            break;
        default:
            return SPCAddressBookFacadeStatusNotDetermined;
            break;
    }
}

+ (void)requestAuthorization:(void (^)(SPCAddressBookFacadeStatus status))handler {
    ABAddressBookRef __block addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler([self addressBookAuthorizationStatus]);
            if (addressBook) {CFRelease(addressBook); }
        });
    });
}


+ (NSArray *)contactList {
    NSMutableArray *contactRefs = [NSMutableArray array];
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef sourcesArray = ABAddressBookCopyArrayOfAllSources(addressBook);
    for (CFIndex i = 0; i < CFArrayGetCount(sourcesArray); i++) {
        ABRecordRef source = (ABRecordRef)CFArrayGetValueAtIndex(sourcesArray, i);
        NSArray * contactsFromSource = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName));
        if (contactsFromSource) {
            NSMutableArray *resultContacts = [[NSMutableArray alloc] init];
            for (id value in contactsFromSource) {
                [resultContacts addObject:[[SPCAddressBookFacadeContact alloc] initWithDisplayName:[SPCAddressBookFacade displayNameForABRecordRef:value] emailAddresses:[SPCAddressBookFacade emailsForABRecordRef:value]]];
            }
            [contactRefs addObjectsFromArray:contactsFromSource];
        }
    }

    if (sourcesArray) {CFRelease(sourcesArray); }
    if (addressBook) {CFRelease(addressBook); }

    return contactRefs;
}

+ (NSArray *)emailsForRecord:(id)record {
    if ([record isKindOfClass:[SPCAddressBookFacadeContact class]]) {
        return ((SPCAddressBookFacadeContact *)record).emailAddresses;
    }
    return @[];
}

+ (NSString *)displayNameForRecord:(id)record {
    if ([record isKindOfClass:[SPCAddressBookFacadeContact class]]) {
        return ((SPCAddressBookFacadeContact *)record).displayName;
    }
    return @"";
}

#pragma mark - Private

+ (NSArray *)arrayFromABMutableMultiValueRef:(ABMutableMultiValueRef)mutableMultiValueRef {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:(NSUInteger) ABMultiValueGetCount(mutableMultiValueRef)];
    NSString * value;
    for (CFIndex i = 0; i < ABMultiValueGetCount(mutableMultiValueRef); i++) {
        value = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(mutableMultiValueRef, i);
        [array addObject:value];
    }
    return array;
}

+ (NSArray *)emailsForABRecordRef:(id)record {
    ABMutableMultiValueRef emails = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonEmailProperty);
    NSArray *emailsArray = [SPCAddressBookFacade arrayFromABMutableMultiValueRef:emails];

    if (emails) {CFRelease(emails); }
    return emailsArray;
}

+ (NSString *)displayNameForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    CFTypeRef firstNameRef = ABRecordCopyValue(thisContact, kABPersonFirstNameProperty);
    CFTypeRef lastNameRef = ABRecordCopyValue(thisContact, kABPersonLastNameProperty);

    NSString *firstName = (__bridge_transfer NSString *) firstNameRef;
    NSString *lastName  = (__bridge_transfer NSString *) lastNameRef;

    return [NSString stringWithFormat:@"%@ %@", firstName ? :@"", lastName ? :@""];
}

@end