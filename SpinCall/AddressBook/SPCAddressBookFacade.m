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

const struct SPCAddressBookFacadePhoneNumbersListDictionaryKeys SPCAddressBookFacadePhoneNumbersListDictionaryKeys = {
        .phoneLabel = @"phoneLabel",
        .phoneNumber = @"phoneNumber"
};

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
                [resultContacts addObject:[[SPCAddressBookFacadeContact alloc] initWithDisplayName:[SPCAddressBookFacade displayNameForABRecordRef:value] avatar:[SPCAddressBookFacade avatarForABRecordRef:value] phoneNumber:[SPCAddressBookFacade phoneNumbersForABRecordRef:value] emailAddresses:[SPCAddressBookFacade emailsForABRecordRef:value]]];
            }
            [contactRefs addObjectsFromArray:resultContacts];
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

+ (NSString *)displayNameForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    CFTypeRef firstNameRef = ABRecordCopyValue(thisContact, kABPersonFirstNameProperty);
    CFTypeRef lastNameRef = ABRecordCopyValue(thisContact, kABPersonLastNameProperty);

    NSString *firstName = (__bridge_transfer NSString *) firstNameRef;
    NSString *lastName  = (__bridge_transfer NSString *) lastNameRef;

    return [NSString stringWithFormat:@"%@ %@", firstName ? :@"", lastName ? :@""];
}

+ (UIImage *)avatarForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(thisContact, kABPersonImageFormatThumbnail);
    return [UIImage imageWithData:imgData];
}

+ (NSArray *)phoneNumbersForABRecordRef:(id)record {
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];

    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    ABMultiValueRef *phones = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);

    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;

        if (phoneNumberRef) {CFRelease(phoneNumberRef);}
        if (locLabel) {CFRelease(locLabel);}
        if (phoneNumberRef && locLabel) {[phoneNumbers addObject:@{SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel : phoneLabel, SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber : phoneNumber}];}
    }
    return phoneNumbers;
}

+ (NSArray *)emailsForABRecordRef:(id)record {
    ABMutableMultiValueRef emails = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonEmailProperty);
    NSArray *emailsArray = [SPCAddressBookFacade arrayFromABMutableMultiValueRef:emails];

    if (emails) {CFRelease(emails); }
    return emailsArray;
}
@end