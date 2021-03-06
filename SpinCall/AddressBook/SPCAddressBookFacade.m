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

NSString * const SPCAddressBookFacadeAddressBookChangedNotification = @"SPCAddressBookFacadeAddressBookChangedNotification";

@implementation SPCAddressBookFacade

#pragma mark - Lifecycle

+ (void)initialize {
    static SPCAddressBookFacade *sharedAddressBookFacade = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAddressBookFacade = [[self alloc] init];
    });
}

- (id)init {
    if (self = [super init]) {
        ABAddressBookRef notificationAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRegisterExternalChangeCallback(notificationAddressBook, addressBookExternalChangeCallback, (__bridge void *)self);
    }
    return self;
}

#pragma mark - C style callbacks

void addressBookExternalChangeCallback() {
    [[NSNotificationCenter defaultCenter] postNotificationName:SPCAddressBookFacadeAddressBookChangedNotification object:nil];
}

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
                [resultContacts addObject:[[SPCAddressBookFacadeContact alloc] initWithRecordID:[SPCAddressBookFacade recordIDForABRecordRef:value] firstName:[SPCAddressBookFacade firstNameForABRecordRef:value] lastName:[SPCAddressBookFacade lastNameForABRecordRef:value] thumbnailAvatar:[SPCAddressBookFacade thumbnailAvatarForABRecordRef:value] originalSizeAvatar:[SPCAddressBookFacade originalSizeAvatarForABRecordRef:value] phoneNumber:[SPCAddressBookFacade phoneNumbersForABRecordRef:value] emailAddresses:[SPCAddressBookFacade emailsForABRecordRef:value]]];
            }
            [contactRefs addObjectsFromArray:resultContacts];
        }
    }

    if (sourcesArray) {CFRelease(sourcesArray); }
    if (addressBook) {CFRelease(addressBook); }

    return contactRefs;
}

+ (BOOL)deleteContactWithFirstName:(NSString *)firstName lastName:(NSString *)lastName {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *peopleArray = (__bridge NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);

    __block ABRecordRef contactToBeDeleted = ABPersonCreate();

    //Contact matching predicate
    BOOL (^predicate)(id obj, NSUInteger idx, BOOL *stop) = ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *contactFirstName = [SPCAddressBookFacade firstNameForABRecordRef:obj];
        NSString *contactLastName = [SPCAddressBookFacade lastNameForABRecordRef:obj];

        BOOL isFirstNameMatch = (firstName == nil && contactFirstName == nil) || ([contactFirstName localizedCaseInsensitiveCompare:firstName] == NSOrderedSame);
        BOOL isLastNameMatch = (lastName == nil && contactLastName == nil) || ([contactLastName localizedCaseInsensitiveCompare:lastName] == NSOrderedSame);
        BOOL isMatch = isFirstNameMatch && isLastNameMatch;
        if (isMatch) {
            contactToBeDeleted = (__bridge ABRecordRef)obj;
        }

        return isMatch;
    };

    NSIndexSet *matchingContacts = [peopleArray indexesOfObjectsPassingTest:predicate];
    if (matchingContacts.count != 1) {
        if (matchingContacts.count == 0) {
            NSLog(@"Contact deletion failed: no matching contact found");
        }

        if (matchingContacts.count > 1) {
            NSLog(@"Contact deletion failed: conflict due to multiple matches");
        }

        return NO;
    }

    CFErrorRef error = nil;
    BOOL didRemove = ABAddressBookRemoveRecord(addressBook, contactToBeDeleted, &error);
    if (!didRemove) {
        NSLog(@"Failed to remove address book record, %@", error);
        return NO;
    }

    BOOL didSave = ABAddressBookSave(addressBook, &error);
    if (!didSave) {
        NSLog(@"Failed to save address book, %@", error);
        return NO;
    }

    return YES;
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

+ (NSNumber *)recordIDForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    return @(ABRecordGetRecordID(thisContact));
}

+ (NSString *)firstNameForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    CFTypeRef firstNameRef = ABRecordCopyValue(thisContact, kABPersonFirstNameProperty);

    return (__bridge_transfer NSString *) firstNameRef;
}

+ (NSString *)lastNameForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    CFTypeRef lastNameRef = ABRecordCopyValue(thisContact, kABPersonLastNameProperty);

    return (__bridge_transfer NSString *) lastNameRef;
}

+ (UIImage *)thumbnailAvatarForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(thisContact, kABPersonImageFormatThumbnail);
    return [UIImage imageWithData:imgData];
}

+ (UIImage *)originalSizeAvatarForABRecordRef:(id)record {
    ABRecordRef thisContact = (__bridge ABRecordRef) record;
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(thisContact, kABPersonImageFormatOriginalSize);
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