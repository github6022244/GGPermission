//
//  GGPermissionCalendarRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionCalendarRequest.h"
#import "GGPermissionDefine.h"
#import <EventKit/EventKit.h>

@interface GGPermissionCalendarRequest ()
@property (nonatomic, strong) EKEventStore *store;
@end

@implementation GGPermissionCalendarRequest

- (instancetype)init {
    if (self = [super init]) {
        _calendarType = GGPermissionTypeCalendarFullAccess;
    }
    return self;
}

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    [self prepareForNewRequest];
    self.callback = callback;
    self.calendarType = type;
    [self startTimeoutIfNeeded];

    self.store = [[EKEventStore alloc] init];
    __weak typeof(self) ws = self;

    if (@available(iOS 17.0, *)) {
        if (self.calendarType == GGPermissionTypeCalendarWriteOnly) {
            [self.store requestWriteOnlyAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(ws) strongSelf = ws;
                    if (!strongSelf) return;
                    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
                    [strongSelf executeCallback:granted statusCode:@(status)];
                });
            }];
        } else {
            [self.store requestFullAccessToEventsWithCompletion:^(BOOL granted, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(ws) strongSelf = ws;
                    if (!strongSelf) return;
                    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
                    [strongSelf executeCallback:granted statusCode:@(status)];
                });
            }];
        }
    } else {
        // iOS 17 以下：统一走旧 API
        [self.store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) strongSelf = ws;
                if (!strongSelf) return;
                EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
                [strongSelf executeCallback:granted statusCode:@(status)];
            });
        }];
    }
}

#pragma mark - 基类 hook
- (nullable NSNumber *)currentSystemStatus {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    if (status == EKAuthorizationStatusNotDetermined) return nil;
    return @(status);
}

- (void)onCancel {
    self.store = nil;
}

@end
