//
//  GGPermissionHealthRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 健康权限请求器：按数据类型发起请求
@interface GGPermissionHealthRequest : GGPermissionBaseRequest
/// 请求类型（决定请求哪些 HKObjectType）
@property (nonatomic, assign) GGPermissionType healthType;
@end

NS_ASSUME_NONNULL_END
