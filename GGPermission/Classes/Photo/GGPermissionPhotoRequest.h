//
//  GGPermissionPhotoRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 相册权限请求器：支持读写 / 只写两种级别
/// accessLevel 由 Handler 在 createRequest 时设置
@interface GGPermissionPhotoRequest : GGPermissionBaseRequest

/// 访问级别：
/// - GGPermissionTypePhoto        → 读写
/// - GGPermissionTypePhotoAddOnly → 只写
@property (nonatomic, assign) GGPermissionType accessType;

@end

NS_ASSUME_NONNULL_END
