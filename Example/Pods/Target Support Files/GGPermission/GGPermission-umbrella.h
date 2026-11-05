#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GGPermissionBluetoothHandler.h"
#import "GGPermissionBluetoothRequest.h"
#import "GGPermissionCalendarHandler.h"
#import "GGPermissionCalendarRequest.h"
#import "GGPermissionCameraHandler.h"
#import "GGPermissionCameraRequest.h"
#import "GGPermissionContactsHandler.h"
#import "GGPermissionContactsRequest.h"
#import "GGPermission.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import "GGPermissionLogger.h"
#import "GGPermissionLoggerMacros.h"
#import "GGPermissionProtocol.h"
#import "GGPermissionTask.h"
#import "GGPermissionUIHelper.h"
#import "UIViewController+GGPermission.h"
#import "GGPermissionHealthHandler.h"
#import "GGPermissionHealthRequest.h"
#import "GGPermissionLocationHandler.h"
#import "GGPermissionLocationHelper.h"
#import "GGPermissionLocationRequest.h"
#import "GGPermissionMicrophoneHandler.h"
#import "GGPermissionMicrophoneRequest.h"
#import "GGPermissionNotificationHandler.h"
#import "GGPermissionNotificationRequest.h"
#import "GGPermissionPhotoHandler.h"
#import "GGPermissionPhotoRequest.h"

FOUNDATION_EXPORT double GGPermissionVersionNumber;
FOUNDATION_EXPORT const unsigned char GGPermissionVersionString[];

