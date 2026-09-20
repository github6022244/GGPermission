//
//  GGPermissionPhotoHandler.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseHandler.h"

NS_ASSUME_NONNULL_BEGIN

/// 相册权限 Handler，支持 GGPermissionTypePhoto（读写）
/// 和 GGPermissionTypePhotoAddOnly（只写）
@interface GGPermissionPhotoHandler : GGPermissionBaseHandler

@end

NS_ASSUME_NONNULL_END
