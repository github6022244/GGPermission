//
//  GGPermissionContactsHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionContactsHandler.h"
#import "GGPermissionContactsRequest.h"
#import "GGPermission.h"
#import <Contacts/Contacts.h>

@implementation GGPermissionContactsHandler

#pragma mark - 基类 hook
- (GGPermissionBaseRequest *)createRequest {
    return [[GGPermissionContactsRequest alloc] init];
}

/// 同步读取通讯录授权状态
- (nullable NSNumber *)currentSystemStatus {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    return @(status);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    CNAuthorizationStatus status = (CNAuthorizationStatus)s;

    if (@available(iOS 18.0, *)) {
        return status == CNAuthorizationStatusAuthorized ||
               status == CNAuthorizationStatusLimited;   
    }
    return status == CNAuthorizationStatusAuthorized;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    CNAuthorizationStatus status = (CNAuthorizationStatus)s;
    return status == CNAuthorizationStatusDenied ||
           status == CNAuthorizationStatusRestricted;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return [GGPermission shareInstance].contactsPushSettingTips;
}

@end
