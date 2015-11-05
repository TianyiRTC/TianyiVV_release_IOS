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
#import "Reachability.h"

#import <PgySDK/PgyManager.h>
#import <PgyUpdate/PgyUpdateManager.h>
#define KEEP_ALIVE_INTERVAL 600

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

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
//#if(SDK_DEBUG_DEMO>0)
    initCWDebugLog();
//#endif
    [self checkNetWorkReachability];

    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"76fa4f8ed0410dbf8d58240c5427cbac"];   // auto update by pgyer
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
    [[PgyManager sharedPgyManager] setEnableFeedback:NO];
    
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
    [application setKeepAliveTimeout:KEEP_ALIVE_INTERVAL handler: ^{
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
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    
    hostReach = [[Reachability reachabilityWithHostname:@"www.apple.com"] retain];
    [hostReach startNotifier];
}

- (void) reachabilityNetWorkStatusChanged: (NSNotification* )note
{
    
    Reachability* curReach = [note object];
    int networkStatus = [curReach currentReachabilityStatus];
    NSLog(@"reachability Changed:%d.",networkStatus);
    BOOL isLogin = [self.viewController accObjIsRegisted];
    if (isLogin)
    {
        if (networkStatus==NotReachable)
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
    }
    
    firstCheckNetwork=NO;
}
@end
