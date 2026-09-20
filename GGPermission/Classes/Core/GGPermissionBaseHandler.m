//
//  GGPermissionBaseHandler.m
//  GGPermission
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionBaseHandler.h"
#import "GGPermission.h"
#import "GGPermissionUIHelper.h"
#import "GGPermissionLoggerMacros.h"

@implementation GGPermissionBaseHandler

#pragma mark - 子类必须重写（默认实现触发断言）

- (GGPermissionBaseRequest *)createRequest {
    NSAssert(NO, @"子类必须重写 createRequest");
    return nil;
}

- (NSNumber *)currentSystemStatus {
    NSAssert(NO, @"子类必须重写 currentSystemStatus");
    return nil;
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSAssert(NO, @"子类必须重写 isGrantedForStatus:");
    return NO;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSAssert(NO, @"子类必须重写 isDeniedOrRestrictedForStatus:");
    return NO;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return @"";
}

#pragma mark - 默认入口（同步模板，子类可重写）
- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *status = [self currentSystemStatus];

        if (status.integerValue < 0) {
            GGPermissionLogWarning(@"请求 %ld 返回负错误码：%@", (long)type, status);
            if (callback) callback(NO, status);
            return;
        }

        if ([self isGrantedForStatus:status]) {
            GGPermissionLogInfo(@"请求 %ld 已授权，直接回调", (long)type);
            if (callback) callback(YES, status);
            return;
        }

        if ([self isDeniedOrRestrictedForStatus:status]) {
            GGPermissionLogInfo(@"请求 %ld 已拒绝/受限，引导设置", (long)type);
            [self guideToSettingWithType:type status:status callback:callback];
            return;
        }

        GGPermissionLogInfo(@"请求 %ld 状态未确定，发起请求", (long)type);
        [self startRequestWithType:type callback:callback];
    });
}

#pragma mark - Request 管理
- (void)startRequestWithType:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    if (self.currentRequest) {
        GGPermissionLogInfo(@"取消旧的 Request：%@", NSStringFromClass([self.currentRequest class]));
        [self.currentRequest cancel];
        self.currentRequest = nil;
    }

    GGPermissionBaseRequest *req = [self createRequest];
    if (!req) {
        GGPermissionLogWarning(@"createRequest 返回 nil");
        if (callback) callback(NO, @(GGPermissionErrorUnknown));
        return;
    }
    self.currentRequest = req;

    GGPermissionLogInfo(@"发起新请求：%@", NSStringFromClass([req class]));

    __weak typeof(self) ws = self;
    [req startRequest:type callback:^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) {
            GGPermissionLogDebug(@"Handler 已释放，丢弃回调");
            return;
        }

        if (strongSelf.currentRequest != req) {
            GGPermissionLogDebug(@"旧 Request 回调被忽略");
            return;
        }

        strongSelf.currentRequest = nil;
        if (callback) callback(granted, statusCode);
    }];
}

#pragma mark - 引导设置
- (void)guideToSettingWithType:(GGPermissionType)type
                        status:(NSNumber *)status
                      callback:(GGPermissionCallback)callback {
    GGPermission *main = [GGPermission shareInstance];
    if (!main.autoTipEnable) {
        GGPermissionLogInfo(@"autoTipEnable = NO，直接回调");
        if (callback) callback(NO, status);
        return;
    }

    NSString *tips = [self guideTipsForType:type];
    if (!tips.length) {
        GGPermissionLogWarning(@"guideTipsForType 返回空，直接回调");
        if (callback) callback(NO, status);
        return;
    }

    GGPermissionLogInfo(@"弹出引导设置弹窗，type = %ld, status = %@", (long)type, status);

    __block BOOL hasResponded = NO;

    __weak typeof(self) ws = self;
    [GGPermissionUIHelper showSettingAlertWithTips:tips
                                            cancel:^{
        if (hasResponded) return;
        hasResponded = YES;
        GGPermissionLogInfo(@"用户取消引导设置");
        if (callback) callback(NO, status);
    }
                                         goSetting:^{
        if (hasResponded) return;
        hasResponded = YES;

        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) {
            GGPermissionLogDebug(@"Handler 已释放，丢弃 goSetting 回调");
            return;
        }

        NSNumber *newStatus = [strongSelf currentSystemStatus];

        if (!newStatus) {
            GGPermissionLogWarning(@"从设置返回，但无法读取状态，返回原状态 %@", status);
            if (callback) callback(NO, status);
            return;
        }

        BOOL granted = [strongSelf isGrantedForStatus:newStatus];
        GGPermissionLogInfo(@"从设置返回，新状态 = %@, granted = %@", newStatus, granted ? @"YES" : @"NO");
        if (callback) callback(granted, newStatus);
    }];
}

@end
