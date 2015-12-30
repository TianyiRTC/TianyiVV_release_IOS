//
//  AppDelegate.m
//  FaceNow
//
//  Created by administration on 14-9-25.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#import "ContactListTableViewController.h"
#import "MyInfoTableViewController.h"
#import "RecentCallTableViewController.h"

#import "sdkobj.h"
#import "ReachabilityRTC.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

//此应用各界面的层级关系：应用启动时创建navController和viewController，window下挂navController，作为根节点。navController下挂viewController，viewController里管理所有的RTC回调和通话相关事件监听。应用启动时进入viewController，并在viewDidLoad中显示登录界面，同时创建tabBarController，tabBarController下挂三个naviController，分别管理好友、群组和设置。登录成功后present tabBarController。callingview管理来电和通话界面，与tabBarController属于平级关系，来电时present callingview，同时dismiss tabBarController。通话结束后dismiss callingview，同时present tabBarController。不同ViewController之间的消息通过postNotificationName来传递。
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[ViewController alloc]init];
    self.viewController.title = @"登录";
        
    self.navController = [[UINavigationController alloc] init];
    [self.navController pushViewController:self.viewController animated:NO];
    //[self.window addSubview:self.navController.view];
    [self.window setRootViewController:self.navController];

    [self.window makeKeyAndVisible];
    initCWDebugLog();
    [self checkNetWorkReachability];
    
    //注册本地推送
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]&&[[[UIDevice currentDevice]systemVersion]floatValue]>=8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        CWLogDebug(@"registerUserNotificationSettings");
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    CWLogDebug(@"%s",__FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    [application setKeepAliveTimeout:600 handler: ^{
        [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    }];

}

- (void)keepAlive
{
    [self.viewController onAppEnterBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self.viewController onApplicationWillEnterForeground:application];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication  sharedApplication] cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    CWLogDebug(@"%s",__FUNCTION__);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    //CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
}

#pragma mark - NetWorkReachability

-(void)checkNetWorkReachability
{
    firstCheckNetwork=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityNetWorkStatusChanged:)
                                                 name: kReachabilityChangedNotificationRTC
                                               object: nil];
    
    hostReach = [[ReachabilityRTC reachabilityWithHostname:@"www.apple.com"] retain];
    [hostReach startNotifier];
}

- (void) reachabilityNetWorkStatusChanged: (NSNotification* )note
{
    
    ReachabilityRTC* curReach = [note object];
    int networkStatus = [curReach currentReachabilityStatus];
    NSLog(@"reachability Changed:%d.",networkStatus);
//    BOOL isLogin = [self.viewController accObjIsRegisted];
//    if (isLogin)
//    {
        if (networkStatus==NotReachableRTC)
        {
            NSLog(@"网络中断");
            [self.viewController onNetworkChanged:NO];
        }
        else
        {
            if (firstCheckNetwork)
            {
                firstCheckNetwork=NO;
                return;
            }
            NSLog(@"网络恢复");
            //进行重连
            [self.viewController onNetworkChanged:YES];
        }
//    }
    
    firstCheckNetwork=NO;
}
@end
