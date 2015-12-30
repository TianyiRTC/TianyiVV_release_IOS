//
//  AppDelegate.h
//  FaceNow
//
//  Created by administration on 14-9-25.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "tyrtchttpengine.h"
@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    dispatch_queue_t mGCDQueue;
    BOOL  firstCheckNetwork;
    ReachabilityRTC* hostReach;
    UIBackgroundTaskIdentifier bgTask;
}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@property (strong, nonatomic) ViewController *viewController;

@end

