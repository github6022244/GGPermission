//
//  GGPermissionBluetoothRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionBluetoothRequest.h"
#import "GGPermissionDefine.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface GGPermissionBluetoothRequest () <CBCentralManagerDelegate>
@property (nonatomic, strong) CBCentralManager *manager;
@end

@implementation GGPermissionBluetoothRequest

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    [self prepareForNewRequest];
    self.callback = callback;

    [self startTimeoutIfNeeded];

    // 创建 CBCentralManager 会触发系统弹窗
    // 注意：必须强持有 manager，否则不弹窗
    self.manager = [[CBCentralManager alloc] initWithDelegate:self
                                                        queue:dispatch_get_main_queue()
                                                      options:@{CBCentralManagerOptionShowPowerAlertKey: @NO}];
}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    CBManagerState state = central.state;
    BOOL granted = NO;
    NSNumber *statusCode;

    switch (state) {
        case CBManagerStatePoweredOn:
        case CBManagerStatePoweredOff:
            granted = YES;
            statusCode = @(CBManagerAuthorizationAllowedAlways);
            break;

        case CBManagerStateUnauthorized:
            granted = NO;
            statusCode = @(CBManagerAuthorizationDenied);
            break;

        case CBManagerStateUnsupported:
            // 设备不支持蓝牙 → 立即回调
            granted = NO;
            statusCode = @(GGPermissionErrorServiceDisabled);
            break;

        case CBManagerStateUnknown:
        default:
            // 状态未定，等下次回调
            return;
    }
    [self executeCallback:granted statusCode:statusCode];
}

#pragma mark - 基类 hook
- (nullable NSNumber *)currentSystemStatus {
    if (@available(iOS 13.1, *)) {
        // iOS 13.1+：可以用类属性，无需创建实例
        CBManagerAuthorization auth = [CBCentralManager authorization];
        return @(auth);
    } else if (@available(iOS 13.0, *)) {
        // iOS 13.0：只能通过实例属性获取（会触发权限弹窗，超时兜底场景可接受）
        CBCentralManager *tmp = [[CBCentralManager alloc] init];
        CBManagerAuthorization auth = tmp.authorization;
        return @(auth);
    }
    return nil;
}

- (void)onCancel {
    if (self.manager) {
        self.manager.delegate = nil;
        self.manager = nil;
    }
}

@end
