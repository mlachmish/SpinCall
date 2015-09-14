//
//  SPCSpinnerViewController.m
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCSpinnerViewController.h"
#import "CocoaLumberjack.h"
#import "SPCAddressBookFacade.h"
#import "SPCContactView.h"
#import "SPCAddressBookFacadeContact.h"

//TODO: refactor logging
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface SPCSpinnerViewController ()

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) SPCContactView *contactView;

@end

@implementation SPCSpinnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    _contactView = [[SPCContactView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_contactView];

    [self requestAddressBookPermissionIfNeeded];

    SPCAddressBookFacadeContact *randomContact = [self getRandomContact];
    _contactView.name = randomContact.displayName;
    _contactView.avatar = randomContact.avatar;
    _contactView.phoneLabel = randomContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel];
    _contactView.phoneNumber = randomContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber];
}

#pragma mark - Custom Accessors

- (NSArray *)contacts {
    if (!_contacts) {
        _contacts = [SPCAddressBookFacade contactList];
        DDLogDebug(@"Found %ld contact records", _contacts.count);
    }
    return _contacts;
}

#pragma mark - Private

- (void)requestAddressBookPermissionIfNeeded {
    if ([SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusDenied
            && [SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusAuthorized) {
        DDLogDebug(@"Requesting contacts access");
        [SPCAddressBookFacade requestAuthorization:^(SPCAddressBookFacadeStatus status) {
            DDLogDebug(@"Contacts access greanted");
        }];
    }
}

- (SPCAddressBookFacadeContact *)getRandomContact {
    u_int32_t randomContactIndex = arc4random_uniform(self.contacts.count);
    return self.contacts[randomContactIndex];
}

@end
