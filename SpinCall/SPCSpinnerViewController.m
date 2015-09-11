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

//TODO: refactor logging
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

@interface SPCSpinnerViewController ()

@end

@implementation SPCSpinnerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];

    if ([SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusDenied
            && [SPCAddressBookFacade addressBookAuthorizationStatus] != SPCAddressBookFacadeStatusAuthorized) {
        DDLogDebug(@"Requesting contacts access");
        [SPCAddressBookFacade requestAuthorization:^(SPCAddressBookFacadeStatus status) {
            DDLogDebug(@"Contacts access greanted");
        }];
    }

    NSArray *contacts = [SPCAddressBookFacade contactList];
    DDLogDebug(@"Found %ld contact records", contacts.count);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
