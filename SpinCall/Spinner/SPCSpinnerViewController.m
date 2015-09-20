//
//  SPCSpinnerViewController.m
//  SpinCall
//
//  Created by Matan Lachmish on 9/12/15.
//  Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCSpinnerViewController.h"
#import "SPCAddressBookFacade.h"
#import "SPCContactView.h"
#import "SPCAddressBookFacadeContact.h"
#import "EXTScope.h"
#import "SPCWhatsAppFacade.h"
#import "SPCLog.h"
#import "UIView+Shortcuts.h"

#import <DCPathButton/DCPathButton.h>

typedef NS_ENUM (NSInteger, SPCSpinnerViewControllerContactActions) {
    SPCSpinnerViewControllerContactActionsCall,
    SPCSpinnerViewControllerContactActionsWhatsApp,
    SPCSpinnerViewControllerContactActionsEdit,
    SPCSpinnerViewControllerContactActionsDelete,
    SPCSpinnerViewControllerContactActionsCount

};

@interface SPCSpinnerViewController () <SPCContactViewDelegate, DCPathButtonDelegate>

@property (strong, nonatomic) NSArray *contacts;
@property (strong, nonatomic) SPCAddressBookFacadeContact *currentDisplayedContact;
@property (assign, nonatomic) SPCAddressBookFacadeStatus addressBookAuthorizationStatus;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;
@property (strong, nonatomic) SPCContactView *contactView;

@property (strong, nonatomic) DCPathButton *contactActionsButton;

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
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurEffectView.frame = self.view.bounds;
        _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self.view addSubview:_blurEffectView];
    }

    _contactView = [[SPCContactView alloc] initWithFrame:self.view.frame];
    _contactView.delegate = self;
    [self.view addSubview:_contactView];

    [self configureContactActionsButton];

    self.addressBookAuthorizationStatus = [SPCAddressBookFacade addressBookAuthorizationStatus];
    [self requestAddressBookPermissionIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddressBookChangedNotification:) name:SPCAddressBookFacadeAddressBookChangedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Override

- (NSUInteger) supportedInterfaceOrientations {
     return  UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Custom Accessors

- (NSArray *)contacts {
    if (!_contacts || _isContactListInvalid) {
        _isContactListInvalid = NO;
        _contacts = [SPCAddressBookFacade contactList];
        SPCLogDebug(@"Found %ld contact records", (unsigned long)_contacts.count);
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

- (void)configureContactActionsButton {
    _contactActionsButton = [[DCPathButton alloc]initWithCenterImage:[UIImage imageNamed:@"chooser-button-tab"]
                                                         highlightedImage:[UIImage imageNamed:@"chooser-button-tab-highlighted"]];
    _contactActionsButton.delegate = self;

    // Configure item buttons
    DCPathItemButton *callButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-call"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-call-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];

    DCPathItemButton *whatsappButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-whatsapp"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-whatsapp-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];
    whatsappButton.enabled = [[SPCWhatsAppFacade sharedInstance] isWhatsAppAvailable];;

    DCPathItemButton *editButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-edit"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-edit-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];

    DCPathItemButton *deleteButton = [[DCPathItemButton alloc]initWithImage:[UIImage imageNamed:@"chooser-moment-icon-delete"]
                                                           highlightedImage:[UIImage imageNamed:@"chooser-moment-icon-delete-highlighted"]
                                                            backgroundImage:[UIImage imageNamed:@"chooser-moment-button"]
                                                 backgroundHighlightedImage:[UIImage imageNamed:@"chooser-moment-button-highlighted"]];

    // Add the item button into the center button
    //
    [_contactActionsButton addPathItems:@[callButton, whatsappButton, editButton, deleteButton]];

    _contactActionsButton.bloomRadius = 120.0f;
    _contactActionsButton.allowSounds = YES;
    _contactActionsButton.allowCenterButtonRotation = YES;
    _contactActionsButton.bottomViewColor = [UIColor grayColor];
    _contactActionsButton.bloomDirection = kDCPathButtonBloomDirectionTop;
    _contactActionsButton.dcButtonCenter = CGPointMake(self.view.center.x, self.view.bottom - _contactActionsButton.frame.size.height - 50);

    [self.view addSubview:_contactActionsButton];

}

- (void)requestAddressBookPermissionIfNeeded {
    if ([SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusDenied
            && [SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusAuthorized) {
        SPCLogDebug(@"Requesting contacts access");
        [SPCAddressBookFacade requestAuthorization:^(SPCAddressBookFacadeStatus status) {
            SPCLogDebug(@"Contacts access set to %ld", (long)status);
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
    SPCLogDebug(@"Recieved AddressBook changed notification");
    _isContactListInvalid = YES;
}

- (NSString *)getHelloTextMessage {
    NSDictionary *messagesDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Messages" ofType:@"plist"]];
    NSArray *helloMessagesArray = messagesDictionary[@"HelloMessagesArray"];
    NSString *helloMessage = helloMessagesArray[arc4random_uniform(helloMessagesArray.count)];
    return [helloMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)callNumber:(const NSString *)phoneNumber {
    SPCLogDebug(@"Calling %@", phoneNumber);
    NSString *urlString = [@"tel:" stringByAppendingString:phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)whatsappContact {
    SPCLogDebug(@"WhatsApp to %@", self.currentDisplayedContact.displayName);
    [[SPCWhatsAppFacade sharedInstance] sendTextMessage:[self getHelloTextMessage] toUserID:self.currentDisplayedContact.recordID];
}

- (void)editContact {
    SPCLogDebug(@"Editing %@", self.currentDisplayedContact.displayName);
    //TODO
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Comming Soon!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction*nolAction = [UIAlertAction actionWithTitle:@"I can't wait" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:nolAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)deleteContact {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Delete Contact!", nil) message:NSLocalizedString(@"Are you sure you want to delete this contact from your Address Book?", nil) preferredStyle:UIAlertControllerStyleAlert];

    @weakify(self);
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        @strongify(self);
        SPCLogDebug(@"Deleting contact: %@ %@", self.currentDisplayedContact.firstName, self.currentDisplayedContact.lastName);
        BOOL didDeleted = [SPCAddressBookFacade deleteContactWithFirstName:self.currentDisplayedContact.firstName lastName:self.currentDisplayedContact.lastName];

        if (didDeleted) {
            [self loadRandomContact];
        }
    }];
    [alertController addAction:yesAction];

    UIAlertAction*nolAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:nolAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - SPCContactViewDelegate

- (void)phoneNumberLabelTapped:(NSString *)phoneNumber {
    [self callNumber:phoneNumber];
}

- (void)tappedOutSide {
    [self loadRandomContact];
}

- (void)longTappedOutSide{
    [self deleteContact];

}

#pragma mark - DCPathButton Delegate

- (void)pathButton:(DCPathButton *)dcPathButton clickItemButtonAtIndex:(NSUInteger)itemButtonIndex {
    switch (itemButtonIndex) {
        case SPCSpinnerViewControllerContactActionsCall:
            [self callNumber:self.contactView.primaryPhoneNumber];
            break;
        case SPCSpinnerViewControllerContactActionsWhatsApp:
            [self whatsappContact];
            break;
        case SPCSpinnerViewControllerContactActionsEdit:
            [self editContact];
            break;
        case SPCSpinnerViewControllerContactActionsDelete:
            [self deleteContact];
            break;
        default:
            SPCLogError(@"Unexpected butten tapped");
            break;
    }
}
@end
