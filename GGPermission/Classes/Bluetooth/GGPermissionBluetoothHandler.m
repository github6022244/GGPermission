//
//  GGPermissionBluetoothHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionBluetoothHandler.h"
#import "GGPermissionBluetoothRequest.h"
#import "GGPermission.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation GGPermissionBluetoothHandler

- (GGPermissionBaseRequest *)createRequest {
    return [[GGPermissionBluetoothRequest alloc] init];
}

- (nullable NSNumber *)currentSystemStatus {
    if (@available(iOS 13.1, *)) {
        CBManagerAuthorization auth = [CBCentralManager authorization];
        return @(auth);
    } else if (@available(iOS 13.0, *)) {
        CBCentralManager *tmp = [[CBCentralManager alloc] init];
        return @(tmp.authorization);
    }
    return @(CBManagerAuthorizationNotDetermined);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    if (@available(iOS 13.0, *)) {
        return (CBManagerAuthorization)s == CBManagerAuthorizationAllowedAlways;
    }
    return NO;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    if (@available(iOS 13.0, *)) {
        return (CBManagerAuthorization)s == CBManagerAuthorizationDenied ||
               (CBManagerAuthorization)s == CBManagerAuthorizationRestricted;
    }
    return NO;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return [GGPermission shareInstance].bluetoothPushSettingTips;
}

@end
