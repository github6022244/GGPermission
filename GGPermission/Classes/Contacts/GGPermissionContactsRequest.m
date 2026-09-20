//
//  GGPermissionContactsRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionContactsRequest.h"
#import "GGPermissionDefine.h"
#import <Contacts/Contacts.h>

@implementation GGPermissionContactsRequest

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    // 1. 重置状态 + 保存回调
    [self prepareForNewRequest];
    self.callback = callback;

    // 2. 启动超时兜底
    [self startTimeoutIfNeeded];

    // 3. 发起系统请求
    // CNContactStore 是实例方法，必须先创建实例
    // store 作为局部变量即可，系统 API 内部会持有它直到回调完成
    CNContactStore *store = [[CNContactStore alloc] init];

    __weak typeof(self) ws = self;
    [store requestAccessForEntityType:CNEntityTypeContacts
                    completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
            [strongSelf executeCallback:granted statusCode:@(status)];
        });
    }];
}

#pragma mark - 基类 hook

/// 超时兜底：通讯录状态可同步读取
- (nullable NSNumber *)currentSystemStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) return nil;
    return @(status);
}

/// 取消时无需清理平台资源（store 是局部变量，没有长生命周期对象）
- (void)onCancel {
    // no-op
}

@end
