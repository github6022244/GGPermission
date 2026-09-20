//
//  GGPermissionNotificationRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 通知权限请求器：每次请求单独实例，用完销毁
@interface GGPermissionNotificationRequest : GGPermissionBaseRequest
@end

NS_ASSUME_NONNULL_END
