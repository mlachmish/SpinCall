//
// Created by Matan Lachmish on 9/16/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import "SPCWhatsAppFacade.h"

static NSString *const kWhatsAppFacadeWhatsAppScheme = @"whatsapp://";
static NSString *const kWhatsAppFacadeWhatsAppURI = @"whatsapp://send?text=%@&abid=%@";

@implementation SPCWhatsAppFacade

#pragma mark - Lifecycle

+ (id)sharedInstance {
    static SPCWhatsAppFacade *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Public

- (BOOL)isWhatsAppAvailable {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kWhatsAppFacadeWhatsAppScheme]];
}

- (void)sendTextMessage:(NSString *)text {
    [self sendTextMessage:text toUserID:nil];
}

- (void)sendTextMessage:(NSString *)text toUserID:(NSNumber *)userID {
    NSString *urlString = [NSString stringWithFormat:kWhatsAppFacadeWhatsAppURI, text, userID];
    NSURL *whatsappURL = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
}

@end