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

@interface SPCSpinnerViewController () <SPCContactViewDelegate>

@property (strong, nonatomic) NSArray *contacts;
@property (assign, nonatomic) SPCAddressBookFacadeStatus addressBookAuthorizationStatus;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) SPCContactView *contactView;

@end

@implementation SPCSpinnerViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];

    _backgroundImageView = [[UIImageView alloc] init];
    [self.view addSubview:_backgroundImageView];

    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:blurEffectView];
    }

    _contactView = [[SPCContactView alloc] initWithFrame:self.view.frame];
    _contactView.delegate = self;
    [self.view addSubview:_contactView];

    self.addressBookAuthorizationStatus = [SPCAddressBookFacade addressBookAuthorizationStatus];
    [self requestAddressBookPermissionIfNeeded];
}

#pragma mark - Custom Accessors

- (NSArray *)contacts {
    if (!_contacts) {
        _contacts = [SPCAddressBookFacade contactList];
        DDLogDebug(@"Found %ld contact records", _contacts.count);
    }
    return _contacts;
}

#pragma mark - Custom Setters

- (void)setAddressBookAuthorizationStatus:(SPCAddressBookFacadeStatus)addressBookAuthorizationStatus {
    _addressBookAuthorizationStatus = addressBookAuthorizationStatus;

    if (addressBookAuthorizationStatus == SPCAddressBookFacadeStatusAuthorized) {
        self.view.userInteractionEnabled = YES;
        [self loadRandomContact];
    } else {
        //display 'please update permissions' screen
        self.view.userInteractionEnabled = NO;
    }
}

#pragma mark - Private

- (void)requestAddressBookPermissionIfNeeded {
    if ([SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusDenied
            && [SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusAuthorized) {
        DDLogDebug(@"Requesting contacts access");
        [SPCAddressBookFacade requestAuthorization:^(SPCAddressBookFacadeStatus status) {
            DDLogDebug(@"Contacts access set to %d", status);
            self.addressBookAuthorizationStatus = [SPCAddressBookFacade addressBookAuthorizationStatus];
        }];
    }
}

- (SPCAddressBookFacadeContact *)getRandomContact {
    u_int32_t randomContactIndex = arc4random_uniform(self.contacts.count);
    return self.contacts[randomContactIndex];
}

- (void)loadRandomContact {
    SPCAddressBookFacadeContact *randomContact = [self getRandomContact];

    self.backgroundImageView.image = randomContact.avatar;
    self.backgroundImageView.frame = CGRectMake(self.view.center.x,0,0,0);
    [self.backgroundImageView sizeToFit];

    self.contactView.name = randomContact.displayName;
    self.contactView.avatar = randomContact.avatar;
    self.contactView.primaryPhoneLabel = randomContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel];
    self.contactView.primaryPhoneNumber = randomContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber];

    if (randomContact.phoneNumbers.count > 1) {
        self.contactView.secondaryPhoneLabel = randomContact.phoneNumbers.lastObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel];
        self.contactView.secondaryPhoneNumber = randomContact.phoneNumbers.lastObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber];
    } else {
        self.contactView.secondaryPhoneLabel = nil;
        self.contactView.secondaryPhoneNumber = nil;
    }
}

#pragma mark - SPCContactViewDelegate

- (void)phoneNumberLabelTapped:(NSString *)phoneNumber {
    DDLogDebug(@"Calling %@", phoneNumber);
    NSString *urlString = [@"tel:" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)tappedOutSide {
    [self loadRandomContact];
}

@end
