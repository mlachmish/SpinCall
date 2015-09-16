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
#import "EXTScope.h"
#import "SPCWhatsAppFacade.h"

static NSString *const kSPCSpinnerViewControllerWhatsappScheme = @"whatsapp://";

//TODO: refactor logging
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface SPCSpinnerViewController () <SPCContactViewDelegate>

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) SPCAddressBookFacadeContact *currentDisplayedContact;
@property (assign, nonatomic) SPCAddressBookFacadeStatus addressBookAuthorizationStatus;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) SPCContactView *contactView;

@end

@implementation SPCSpinnerViewController {
    BOOL _isContactListInvalid;
}

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
    _contactView.isWhatsappAvailable = [[SPCWhatsAppFacade sharedInstance] isWhatsAppAvailable];
    [self.view addSubview:_contactView];

    self.addressBookAuthorizationStatus = [SPCAddressBookFacade addressBookAuthorizationStatus];
    [self requestAddressBookPermissionIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddressBookChangedNotification:) name:SPCAddressBookFacadeAddressBookChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Custom Accessors

- (NSArray *)contacts {
    if (!_contacts || _isContactListInvalid) {
        _isContactListInvalid = NO;
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
    self.currentDisplayedContact = [self getRandomContact];

    self.backgroundImageView.image = self.currentDisplayedContact.originalSizeAvatar;
    self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundImageView.frame = self.view.frame;

    self.contactView.name = self.currentDisplayedContact.displayName;
    self.contactView.avatar = self.currentDisplayedContact.thumbnailAvatar;
    self.contactView.primaryPhoneLabel = self.currentDisplayedContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel];
    self.contactView.primaryPhoneNumber = self.currentDisplayedContact.phoneNumbers.firstObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber];

    if (self.currentDisplayedContact.phoneNumbers.count > 1) {
        self.contactView.secondaryPhoneLabel = self.currentDisplayedContact.phoneNumbers.lastObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneLabel];
        self.contactView.secondaryPhoneNumber = self.currentDisplayedContact.phoneNumbers.lastObject[SPCAddressBookFacadePhoneNumbersListDictionaryKeys.phoneNumber];
    } else {
        self.contactView.secondaryPhoneLabel = nil;
        self.contactView.secondaryPhoneNumber = nil;
    }
}

- (void)handleAddressBookChangedNotification:(NSNotification *)notification {
    DDLogDebug(@"Recieved AddressBook changed notification");
    _isContactListInvalid = YES;
}

- (NSString *)getTextMessgae {
    NSString *message = @"מה המצב אחי?";
    return [message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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

- (void)longTappedOutSide{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Delete Contact!" message:@"Are you sure you want to delete this contact from your Address Book?" preferredStyle:UIAlertControllerStyleAlert];

    @weakify(self);
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        @strongify(self);
        DDLogDebug(@"Deleting contact: %@ %@", self.currentDisplayedContact.firstName, self.currentDisplayedContact.lastName);
        BOOL didDeleted = [SPCAddressBookFacade deleteContactWithFirstName:self.currentDisplayedContact.firstName lastName:self.currentDisplayedContact.lastName];

        if (didDeleted) {
            [self loadRandomContact];
        }
    }];
    [alertController addAction:yesAction];

    UIAlertAction*nolAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:nolAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didTapWhatsappButton {
    DDLogDebug(@"Whatsapp to %@", self.currentDisplayedContact.displayName);
    [[SPCWhatsAppFacade sharedInstance] sendTextMessage:[self getTextMessgae] toUserID:self.currentDisplayedContact.recordID];
}

@end
