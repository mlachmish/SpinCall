//
// Created by Matan Lachmish on 9/18/15.
// Copyright (c) 2015 Matan Lachmish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

extern int SPCLogLevel;

#define SPCLogError(frmt, ...)   LOG_MAYBE(NO,                SPCLogLevel, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)
#define SPCLogWarn(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, SPCLogLevel, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)
#define SPCLogInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, SPCLogLevel, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)
#define SPCLogDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, SPCLogLevel, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)
#define SPCLogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, SPCLogLevel, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ## __VA_ARGS__)


@interface SPCLog : NSObject
@end