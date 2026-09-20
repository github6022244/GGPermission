//
//  GGPermissionCalendarRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 日历权限请求器，支持完整访问 / 只写访问
@interface GGPermissionCalendarRequest : GGPermissionBaseRequest
/// 请求类型：CalendarFullAccess / CalendarWriteOnly
@property (nonatomic, assign) GGPermissionType calendarType;
@end

NS_ASSUME_NONNULL_END
