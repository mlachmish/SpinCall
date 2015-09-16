//
// Created by Matan Lachmish on 9/16/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This is a facade for the WhatsApp app API.
 * This class is a singleton.
 */

@interface SPCWhatsAppFacade : NSObject

+ (id)sharedInstance;

/**
 * Return YES if WhatsApp is installed on the device.
 */
- (BOOL)isWhatsAppAvailable;

/**
 * Open WhatsApp with a preset text message.
 * WhatsApp will be opened on the roster, not inside a conversation.
 */
- (void)sendTextMessage:(NSString *)text;

/**
 * Open WhatsApp with a preset text message.
 * WhatsApp inside a conversation with the matching userID.
 * If there is a conflict with the userID, WhatsApp will be opened on the roster.
 */
- (void)sendTextMessage:(NSString *)text toUserID:(NSNumber *)userID;

@end