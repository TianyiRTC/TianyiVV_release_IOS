//
//  ViewController.h
//  FaceNow
//
//  Created by administration on 14-9-25.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecentCallTableViewController.h"
#import "ContactListTableViewController.h"
#import "MyInfoTableViewController.h"
#import "GroupTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVCaptureSession.h>
#import "sdkobj.h"
#import "RBDMuteSwitch.h"

@interface ViewController : UIViewController<SdkObjCallBackProtocol,AccObjCallBackProtocol,CallObjCallBackProtocol,UIActionSheetDelegate,RBDMuteSwitchDelegate>

@property (nonatomic, retain) IBOutlet UITextField*           mUsrID;
@property (nonatomic, retain) IBOutlet UITextField*           mUsrPWD;
@property (nonatomic, retain) IBOutlet UITextField* mNaviAddress;//导航服务器地址
@property (nonatomic, retain) IBOutlet UITextField*           mAppID;
@property (nonatomic, retain) IBOutlet UITextField*           mAppKey;
@property (nonatomic, retain) IBOutlet UITextField*           mStatus;

@property (nonatomic, retain) NSString*   loginID;
@property (nonatomic, retain) NSArray*   remotePhoneNum;
@property (nonatomic, retain) NSString*   groupName;
@property (nonatomic, retain) NSString*   terminalType;
@property (nonatomic, retain) NSString*   remoteTerminalType;
@property (nonatomic, retain) NSString*   videoCodecName;
@property (nonatomic, retain) NSString*   audioCodecName;
@property (nonatomic, retain) NSString*   autoAccept;

@property (strong, retain) UINavigationController *navContactsListNaviController;
@property (strong, retain) UINavigationController *navMyInfoNaviController;
@property (strong, retain) UINavigationController *navRecentCallNaviController;
@property (strong, retain) UINavigationController *navGroupNaviController;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) RecentCallTableViewController *recentcallViewController;
@property (strong, nonatomic) ContactListTableViewController *contactlistViewController;
@property(strong,nonatomic) MyInfoTableViewController *myinfoViewController;
@property(strong,nonatomic) GroupTableViewController *groupViewController;
@property(strong,nonatomic) UIActivityIndicatorView *loginActivityIndicator;
@property(strong,nonatomic) UIButton* btnItemLogin;

@property (nonatomic, retain) NSString *myInfoListPath;
@property (nonatomic, retain) NSMutableDictionary *myInfoListData;
@property (nonatomic, retain) NSArray *myInfoListSections;
@property (nonatomic, retain) AVAudioPlayer *thePlayer;
@property (nonatomic, retain) NSString *myLoginListPath;
//@property (nonatomic, retain) NSString *pushToken;
//@property (nonatomic, retain) NSString *pushInfo;

-(void)setLog:(NSString*)log;
-(CGRect)calcBtnRect:(CGPoint)start index:(int)index size:(CGSize)size linSep:(int)lineSep colSep:(int)colSep;
-(BOOL)addGridBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect;
- (void)onApplicationWillEnterForeground:(UIApplication *)application;
-(void)onAppEnterBackground;
-(void)onNetworkChanged:(BOOL)netstatus;
-(BOOL)accObjIsRegisted;

@end

