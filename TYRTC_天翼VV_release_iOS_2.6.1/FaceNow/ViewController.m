//
//  ViewController.m
//  FaceNow
//
//  Created by administration on 14-9-25.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "ViewController.h"
#import "sdkobj.h"
#import "sdkkey.h"
#import "sdkerrorcode.h"
#import "MBProgressHUD.h"
#import "CCallingViewController.h"
#import "JSONKitRTC.h"

#define APP_USER_AGENT      @"vvdemo"
#define APP_VERSION         @"V2.6.1_B20151230"

#define APPID @"70038"
#define APPKEY @"MTQxMDkyMzU1NTI4Ng=="
#define DEFAULT_ADDRESS     @"cloud2-70038"
static int cameraIndex = 1;//切换摄像头索引,1为前置
UIButton* btnItemType;
UIButton* btnItemAddress;
NSString* micOwner=nil;
#if(SDK_HAS_GROUP>0)
extern int isGroupCreator;
extern SDK_GROUP_TYPE grpType;
extern int isGroup;
extern UITextField *textfield;
NSString*   joinCallID = nil;
extern BOOL micResponse;
extern BOOL mGroupMic;//YES 未静音;NO 已静音
extern UIButton* btnGroupMic;
extern NSString *micName;
extern int changeVersion;
extern BOOL callingviewMic;
extern BOOL callingviewNoMic;
#endif

@interface ViewController()
{
    SdkObj* mSDKObj;
    AccObj* mAccObj;
    CallObj*  mCallObj;

    SDK_ACCTYPE         accType;
    SDK_ACCTYPE         remoteAccType;

#if (SDK_HAS_GROUP>0)
    NSString*   callID;
#endif

    NSCondition*        _signalAccStatusQueryResponse;
    NSMutableArray* _queueAccStatusQueryResponse;

    MBProgressHUD *HUD;

    CGSize  mVideoSize;

    int     mLogIndex;

    IOSDisplay *remoteVideoView;
    UIView *localVideoView;
    CCallingViewController* callingView;
    BOOL isAutoRotationVideo;
    NSString *mToken;
    NSString *mAccountID;
    BOOL  isGettingToken;//正在获取token时不能重复获取
    BOOL  isFirstpage;
}
@end

//private
@interface ViewController(private)
-(void)makeAudioCall:(NSArray *) phoneNum;
-(void)makeVideoCall:(NSArray *) phoneNum;
-(void)makeGroupAudioCall:(NSArray *) phoneNum;
-(void)makeGroupVideoCall:(NSArray *) phoneNum;
@end

@interface ViewController ()

@end

@implementation ViewController

@synthesize mUsrID;
@synthesize mUsrPWD;
@synthesize mStatus;
@synthesize mNaviAddress;
@synthesize mAppID;
@synthesize mAppKey;
@synthesize loginID;
@synthesize remotePhoneNum;
@synthesize groupName;
@synthesize terminalType;
@synthesize remoteTerminalType;
@synthesize videoCodecName;
@synthesize audioCodecName;
@synthesize autoAccept;
@synthesize navRecentCallNaviController;
@synthesize navContactsListNaviController;
@synthesize navMyInfoNaviController;
@synthesize tabBarController = _tabBarController;
@synthesize recentcallViewController = _recentcallViewController;
@synthesize contactlistViewController = _contactlistViewController;
@synthesize myinfoViewController = _myinfoViewController;
@synthesize loginActivityIndicator;
@synthesize myInfoListData;
@synthesize myInfoListSections;
@synthesize myInfoListPath;
@synthesize thePlayer;
@synthesize btnItemLogin;
/**********************************文件管理*************************************/
-(void) write
{
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //获取路径
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];//去处需要的路径
    
    //更改到待操作的目录下
    [fileManager changeCurrentDirectoryPath:[documentsDirectory stringByExpandingTildeInPath]];
    
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"config"];//获取文件路径
    //判断文件是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {//如果文件不存在则创建
        //创建文件fileName文件名称，contents文件的内容，如果开始没有内容可以设置为nil，attributes文件的属性，初始为nil
        
        NSData *d_data=[[NSMutableDictionary alloc] init];
        
        [d_data setValue:@"" forKey:@"userid"];//手机号
        [d_data setValue:@"" forKey:@"pwd"];//密码
        [d_data setValue:@"0" forKey:@"backup"];//备份类型
        
        [fileManager createFileAtPath:path contents:d_data attributes:nil];
        
        NSString *str = @"a test file name";
        BOOL succeed = [str writeToFile: [documentsDirectory stringByAppendingPathComponent:@"test.xml"]
                             atomically: YES
                               encoding: NSUTF8StringEncoding
                                  error: nil];
        NSLog( @"succeed is %d", succeed );        // yes -> 写成功       no->写失败
        
        [d_data release];
    }
}

- (void)read
{
    //读取数据
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:  @"test.xml"];
    NSData *data = [file readDataToEndOfFile];//得到xml文件                               //读取到NSDate中
    
    NSString* aStr;
    aStr = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];         //转换为NSString
    NSLog( @"aStr is %@", aStr );
    
    [file closeFile];
}

//音频呼叫
- (void)makeAudioCall:(NSArray *) phoneNum
{
#if (SDK_HAS_GROUP>0)
    isGroup = 0;
#endif
    CCallingViewController* view1 = [[CCallingViewController alloc]init];
    view1.isVideo = NO;
    view1.isCallOut = YES;
    view1.view.frame = self.view.frame;
    callingView = view1;
    callingView.mCallingNum.text=[phoneNum componentsJoinedByString:@""];
    callingView.mCallingInfo.text=@"语音呼叫中...";
    
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:view1 animated:NO completion:nil];
    
    [view1 release];
}

//视频呼叫
- (void)makeVideoCall:(NSArray *) phoneNum
{
#if (SDK_HAS_GROUP>0)
    isGroup = 0;
#endif
    CCallingViewController* view1 = [[CCallingViewController alloc]init];
    view1.isVideo = YES;
    view1.isCallOut = YES;
    view1.isAutoRotate = isAutoRotationVideo;
    view1.view.frame = self.view.frame;
    callingView = view1;
    callingView.mCallingNum.text=[phoneNum componentsJoinedByString:@""];
    callingView.mCallingInfo.text=@"视频呼叫中...";

    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:view1 animated:NO completion:nil];

    [view1 release];
}

#if(SDK_HAS_GROUP>0)
//多人呼叫
- (void)makeGroupCall:(NSString *) phoneNum
{
    isGroupCreator=1;
    isGroup = 1;
    CCallingViewController* view1 = [[CCallingViewController alloc]init];
    view1.isCallOut = YES;
    if(grpType>=20)
    {
        view1.isVideo = YES;
        view1.isAutoRotate = isAutoRotationVideo;
    }
    else
        view1.isVideo = NO;
    view1.view.frame = self.view.frame;
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:view1 animated:NO completion:nil];
    callingView = view1;
    callingView.mCallingNum.text=phoneNum;
    callingView.mCallingInfo.text=@"群组呼叫中...";
    [view1 release];
}

//加入会议
- (void)makeGroupJoin:(NSString *) phoneNum
{
    isGroup = 2;
    CCallingViewController* view1 = [[CCallingViewController alloc]init];
    view1.isCallOut = YES;
    if(grpType>=20)
    {
        view1.isVideo = YES;
        view1.isAutoRotate = isAutoRotationVideo;
    }
    else
        view1.isVideo = NO;
    view1.view.frame = self.view.frame;
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    [self presentViewController:view1 animated:NO completion:nil];
    callingView = view1;
    callingView.mCallingNum.text=phoneNum;
    callingView.mCallingInfo.text=@"群组加入中...";
    [view1 release];
}
#endif

- (id) initCallNotification
{
    self = [super init];
    if (!self) return nil;
    
//    NSNotificationCenter在post消息后，会一直调用函数中会一直等待被调用函数执行完全，
//    然后返回控制权到主函数中，再接着执行后面的功能。即：这是一个同步阻塞的操作。
//    如果要想不等待，直接返回控制权，可以采用NSNotificationQueue。
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAudioCallNotification:)
                                                 name:@"AudioCallNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveVideoCallNotification:)
                                                 name:@"VideoCallNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGroupCallNotification:)
                                                 name:@"GroupCallNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGroupJoinNotification:)
                                                 name:@"GroupJoinNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRecvMyInfoEvent:)
                                                 name:@"MYINFO_EVENT"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onRecvEvent:)
                                                 name:@"NOTIFY_EVENT"
                                               object:nil];

    return self;
}

/**********************************通知管理*************************************/
-(void)performDismiss:(NSTimer *)timer
{
    UIAlertView *alter = [timer userInfo];
    if(alter)
    {
        if(![alter isHidden])
            [alter dismissWithClickedButtonIndex:0 animated:NO];
        [alter release];
    }
}

-(void)myAlertView:(NSString*)title msg:(NSString*)msg
{
    UIAlertView *myAlter;
    myAlter = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(performDismiss:) userInfo:myAlter repeats:NO];
    [myAlter show];
}

- (void) receiveAudioCallNotification:(NSNotification *) notification
{
    NSArray *nums = [notification object];
    self.remotePhoneNum = [NSArray arrayWithArray:nums];

    if ([[notification name] isEqualToString:@"AudioCallNotification"]) {
        [self makeAudioCall:self.remotePhoneNum];
    }
}

- (void) receiveVideoCallNotification:(NSNotification *) notification
{
    NSArray *nums = [notification object];
    self.remotePhoneNum = [NSArray arrayWithArray:nums];

    if ([[notification name] isEqualToString:@"VideoCallNotification"]) {
        [self makeVideoCall:self.remotePhoneNum];
    }
}

#if(SDK_HAS_GROUP>0)
- (void) receiveGroupCallNotification:(NSNotification *) notification
{
    NSDictionary *nums = [notification object];
    NSArray* invitee = [nums objectForKey:KEY_GRP_INVITEELIST];
    self.groupName = [nums objectForKey:KEY_GRP_NAME];
    self.remotePhoneNum = [NSArray arrayWithArray:invitee];
    
    if ([[notification name] isEqualToString:@"GroupCallNotification"]) {
        if(changeVersion==1)
            [self makeGroupCall:self.groupName];
        else if(changeVersion==2)
            [self myAlertView:@"请在设置里切换至多人终端版" msg:@""];
    }
}

- (void) receiveGroupJoinNotification:(NSNotification *) notification
{
    NSDictionary *nums = [notification object];
    NSArray* invitee = [nums objectForKey:KEY_GRP_INVITEELIST];
    self.groupName = [nums objectForKey:KEY_GRP_NAME];
    self.remotePhoneNum = [NSArray arrayWithArray:invitee];
    
    if ([[notification name] isEqualToString:@"GroupJoinNotification"]) {
        [self makeGroupJoin:self.groupName];
    }
}
#endif

- (void) writeCurrentInfoToFile
{
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.myInfoListPath = [documentsPath stringByAppendingPathComponent:@"MyInfoList.plist"];
    
    NSMutableDictionary *dict;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.myInfoListPath])
    {
        [[NSFileManager defaultManager]  createFileAtPath:self.myInfoListPath contents:nil attributes:nil];
        
        //创建词典对象，初始化长度为10
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
        
    }
    else
    {
        //Load the file in a dictionnary
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.myInfoListPath];
        if (dict == nil) {
            dict = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    
    self.myInfoListData = dict;
    
    NSArray *dicoArray = [[self.myInfoListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.myInfoListSections = dicoArray;
    
    NSString *reso = nil;
    int w = mVideoSize.width > mVideoSize.height? mVideoSize.width:mVideoSize.height;

    switch (w) {
        case 176:
            reso = @"流畅";
            break;
//        case 320:
//            reso = @"QVGA(320*240)";
//            break;
        case 352:
            reso = @"标清";
            break;
//        case 640:
//            reso = @"VGA(640*480)";
//            break;
        case 704:
            reso = @"高清";
            break;
//        case 720:
//            reso = @"D1(720*576)";
//            break;
//        case 1280:
//            reso = @"D4(1280*720";
//            break;
        default:
            break;
    }
    
    [self.myInfoListData setObject:mAppID.text forKey:KEY_MYINFO_APP_ID];
//    [self.myInfoListData setObject:mAppKey.text forKey:KEY_MYINFO_APP_KEY];
//    
//    [self.myInfoListData setObject:mStatus.text forKey:KEY_MYINFO_STATUS];
//    
//    [self.myInfoListData setObject:self.loginID forKey:KEY_MYINFO_LOGIN_ID];
//    [self.myInfoListData setObject:mNaviAddress.text forKey:KEY_MYINFO_NAVI_ADDRES];
    NSString *codec = self.videoCodecName;//[self.videoCodecName stringByAppendingString:@"@"];
    //codec = [codec stringByAppendingString:reso];

    [self.myInfoListData setObject:codec forKey:KEY_MYINFO_VIDEO_CODEC];
    [self.myInfoListData setObject:self.audioCodecName forKey:KEY_MYINFO_AUDIO_CODEC];
    [self.myInfoListData setObject:self.autoAccept forKey:KEY_MYINFO_AUTOACCEPT];
    [self.myInfoListData setObject:APP_VERSION forKey:KEY_MYINFO_VERSION];
    
    [self.myInfoListData writeToFile:self.myInfoListPath atomically:YES];
    self.myInfoListSections = [[self.myInfoListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
}

- (void) readCurrentInfoFromFile
{
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.myInfoListPath = [documentsPath stringByAppendingPathComponent:@"MyInfoList.plist"];
    
    NSMutableDictionary *dict;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.myInfoListPath])
    {
        self.audioCodecName = [NSString stringWithFormat:@"iLBC"];
        self.videoCodecName = [NSString stringWithFormat:@"VP8"];
        self.autoAccept = [NSString stringWithFormat:@"NO"];
        mVideoSize = CGSizeMake(288,352);
        [mAppID setText:APPID];
        [mAppKey setText:APPKEY];
        [mNaviAddress setText:DEFAULT_ADDRESS];
        return;
    }
    else
    {
        //Load the file in a dictionnary
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.myInfoListPath];
        if (dict == nil) {
            dict = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    self.myInfoListData = dict;
    
    if([self.myInfoListData objectForKey:@"版本号"])
       [self.myInfoListData removeObjectForKey:@"版本号"];
    NSArray *dicoArray = [[self.myInfoListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.myInfoListSections = dicoArray;
    
    mAppID.text = APPID;
    mAppKey.text = APPKEY;
//
//    //[self.myInfoListData setObject:mStatus.text forKey:KEY_MYINFO_STATUS];
//    
//    self.loginID = [self.myInfoListData objectForKey:KEY_MYINFO_LOGIN_ID];
    mNaviAddress.text = DEFAULT_ADDRESS;
    //[btnItemAddress setTitle:[self.myInfoListData objectForKey:KEY_MYINFO_NAVI_ADDRES] forState:UIControlStateNormal];
    NSString *codec = [self.myInfoListData objectForKey:KEY_MYINFO_VIDEO_CODEC];
    if([self.myInfoListData objectForKey:KEY_MYINFO_AUTOACCEPT])
        self.autoAccept = [self.myInfoListData objectForKey:KEY_MYINFO_AUTOACCEPT];
    else
        self.autoAccept = @"NO";
    
    //NSRange range = [string rangeOfString:@"@"];
    //NSString *codec = nil;
    NSString *reso = nil;
//    if (range.length > 0) {
//        NSArray *array = [string componentsSeparatedByString:@"@"]; //从字符A中分隔成2个元素的数组
//        codec = [array objectAtIndex:0];
//        reso = [array objectAtIndex:1];
//    }
    self.videoCodecName = codec;
    if ([reso isEqualToString:@"流畅"]) {
        mVideoSize =  CGSizeMake(144,176) ;
    }
//    else if ([reso isEqualToString:@"QVGA(320*240)"]) {
//        mVideoSize =  CGSizeMake(240,320)  ;
//    }
    else if ([reso isEqualToString:@"标清"]) {
        mVideoSize =  CGSizeMake(288,352)  ;
    }
//    else if ([reso isEqualToString:@"VGA(640*480)"]) {
//        mVideoSize =  CGSizeMake(480,640)  ;
//    }
    else if ([reso isEqualToString:@"高清"]) {
        mVideoSize =  CGSizeMake(576,704)  ;
    }
//    else if ([reso isEqualToString:@"D1(720*576)"]) {
//        mVideoSize =  CGSizeMake(576,720)  ;
//    }else if ([reso isEqualToSt`ring:@"D4(1280*720"]) {
//        mVideoSize =  CGSizeMake(720,1280) ;
//    }
    else
        mVideoSize =  CGSizeMake(288,352)  ;
    
    self.audioCodecName = [self.myInfoListData objectForKey:KEY_MYINFO_AUDIO_CODEC];
    
}

/**********************************界面部分*************************************/
-(int)getLineIndex:(int) cntIndex
{
    return cntIndex/4;
}

-(int)getColIndex:(int) cntIndex
{
    return cntIndex%4;
}

-(CGRect)calcBtnRect:(CGPoint)start index:(int)index size:(CGSize)size linSep:(int)lineSep colSep:(int)colSep
{
    int lineIdx = 0;
    int colIdx = 0;
    lineIdx = [self getLineIndex:index];
    colIdx = [self getColIndex:index];
    CGFloat x = start.x + colIdx*(size.width+colSep);
    CGFloat y = start.y + lineIdx*(size.height+lineSep);
    return CGRectMake(x, y, size.width, size.height);
}

-(BOOL)addGridBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    btnItemLogin = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItemLogin.frame = rect;
    [btnItemLogin addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItemLogin setTitle:title forState:UIControlStateNormal];
    [btnItemLogin setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    [btnItemLogin setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:214.0/255.0 blue:0.0/255.0 alpha:1]];
    [btnItemLogin.layer setMasksToBounds:YES];
    [btnItemLogin.layer setCornerRadius:10.0];
    [self.view addSubview:btnItemLogin];
    
    return YES;
}

-(UIButton*)addImageBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:title];
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
    [btnItem setShowsTouchWhenHighlighted:YES];
    [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItem setBackgroundImage:image forState:UIControlStateNormal];
    [btnItem setTitle:@"登录" forState:UIControlStateNormal];
    [btnItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.view addSubview:btnItem];
    
    return btnItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initCallNotification];

    _signalAccStatusQueryResponse = [[NSCondition alloc] init];
    _queueAccStatusQueryResponse = [[NSMutableArray alloc] init];

    //Create a string representing the file pathNSString *plistPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"LoginList.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        //创建文件fileName文件名称，contents文件的内容，如果开始没有内容可以设置为nil，attributes文件的属性，初始为nil
        NSData *d_data = [[NSMutableDictionary alloc] init];
        [d_data setValue:@"" forKey:@"LoginID"];//手机号
        [[NSFileManager defaultManager]  createFileAtPath:plistPath contents:d_data attributes:nil];
        [d_data release];
    }
    
    //Load the file in a dictionnary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    self.loginID = [dict objectForKey:@"LoginID"];
    
    if (self.loginID == nil) {
        self.loginID = @"";
    }

    thePlayer = nil;
    mSDKObj = nil;
    mAccObj = nil;
    accType = ACCTYPE_APP;
    remoteAccType = ACCTYPE_APP;
 
    self.terminalType = TERMINAL_TYPE_PHONE;
    self.remoteTerminalType = TERMINAL_TYPE_ANY;

    mLogIndex = 0;
    isAutoRotationVideo = YES;
    isGettingToken = NO;
    isFirstpage = YES;

    self.view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.view.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:227.0/255.0 blue:169.0/255.0 alpha:1];
    UITextField* tfItem = nil;//tf : text field
    CGRect tfItemFrame;
    CGRect lblItemFrame;//lbl : label
    
    CGFloat sep = 6;
    CGFloat height = 30;
    CGFloat lblWidth = 40;
    CGFloat lblSep = 10;
    CGFloat x = 10;
    CGFloat y = 100;
    CGFloat borderwidth = 20;
    UILabel* lblItem;
    
    UIImageView* loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 30, y, 60, 60)];
    NSString* imageName =   [NSString stringWithFormat:@"login_logo.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    loginImageView.layer.contents = (id) image.CGImage;
    [self.view addSubview:loginImageView];
    
    lblItemFrame = CGRectMake(SCREEN_WIDTH/2-2*height, y+60, 4*height, height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [lblItem setText:@" VV 中国好视听"];
    [self.view addSubview:lblItem];
    [lblItem release];
    
    lblItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2, y+100+sep+height, lblWidth, height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [lblItem setText:@"账号:"];
    [self.view addSubview:lblItem];
    [lblItem release];
    
    tfItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2 + lblWidth+lblSep, y+100+sep+height, 320-x-lblWidth-lblSep-borderwidth, height);
    tfItem = [[UITextField alloc]initWithFrame:tfItemFrame];
    tfItem.placeholder = @"ID";
    tfItem.textAlignment = NSTextAlignmentCenter;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    tfItem.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:tfItem];
    mUsrID = tfItem;
    [tfItem release];
    
    lblItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2, y+100+2*(sep+height), lblWidth, height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [lblItem setText:@"类型:"];
    [self.view addSubview:lblItem];
    [lblItem release];
    
    tfItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2 + lblWidth+lblSep, y+100+2*(sep+height), 320-x-lblWidth-lblSep-borderwidth, height);
    btnItemType = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItemType.frame = tfItemFrame;
    [btnItemType addTarget:self action:@selector(onSetTerminalType:) forControlEvents:UIControlEventTouchDown];
    [btnItemType setTitle:terminalType forState:UIControlStateNormal];
    btnItemType.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [btnItemType.layer setMasksToBounds:YES];
    [btnItemType.layer setCornerRadius:10.0];
    [self.view addSubview:btnItemType];

    tfItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2, y+100+3*(sep+height), 320-x-lblWidth-lblSep, height);
    tfItem = [[UITextField alloc]initWithFrame:tfItemFrame];
    tfItem.placeholder = @"导航服务器地址";
    tfItem.textAlignment = NSTextAlignmentCenter;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    tfItem.hidden = YES;
    [self.view addSubview:tfItem];
    mNaviAddress = tfItem;
    [tfItem release];
    
    lblItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2, y+100+3*(sep+height), lblWidth, height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [lblItem setText:@"地址:"];
    [self.view addSubview:lblItem];
    [lblItem release];
    
    tfItemFrame = CGRectMake(SCREEN_WIDTH/2-(320-x-lblSep-borderwidth)/2 + lblWidth+lblSep, y+100+3*(sep+height), 320-x-lblWidth-lblSep-borderwidth, height);
    btnItemAddress = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItemAddress.frame = tfItemFrame;
    [btnItemAddress addTarget:self action:@selector(onSetAddress:) forControlEvents:UIControlEventTouchDown];
    [btnItemAddress setTitle:DEFAULT_ADDRESS forState:UIControlStateNormal];
    btnItemAddress.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    [btnItemAddress.layer setMasksToBounds:YES];
    [btnItemAddress.layer setCornerRadius:10.0];
    [self.view addSubview:btnItemAddress];
    
    tfItemFrame.origin.y += sep + height;
    tfItemFrame = CGRectMake(x + lblWidth+lblSep, tfItemFrame.origin.y, 320-x-lblWidth-lblSep, height);
    tfItem = [[UITextField alloc]initWithFrame:tfItemFrame];
    tfItem.placeholder = @"APPID";
    tfItem.textAlignment = NSTextAlignmentCenter;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    tfItem.hidden = YES;
    [self.view addSubview:tfItem];
    mAppID = tfItem;
    [tfItem release];
    
    tfItemFrame.origin.y += sep + height;
    tfItemFrame = CGRectMake(x + lblWidth+lblSep, tfItemFrame.origin.y, 320-x-lblWidth-lblSep, height);
    tfItem = [[UITextField alloc]initWithFrame:tfItemFrame];
    tfItem.placeholder = @"APPKEY";
    tfItem.textAlignment = NSTextAlignmentCenter;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    tfItem.hidden = YES;
    [self.view addSubview:tfItem];
    mAppKey = tfItem;
    [tfItem release];
    
    [self readCurrentInfoFromFile];
    
    tfItem = [[UITextField alloc]initWithFrame:CGRectMake(20+height+10, y, 300-height-10, 30)];
    tfItem.placeholder = @"操作日志";
    tfItem.textAlignment = NSTextAlignmentCenter;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    tfItem.keyboardType = UIKeyboardTypeNumberPad;
    tfItem.hidden = YES;
    [self.view addSubview:tfItem];
    mStatus = tfItem;
    [tfItem release];

#if(SDK_HAS_GROUP>0)
    callID = @"";
    [callID retain];
#endif

    [mUsrID setText:self.loginID];
    
    CGRect btnItemRect;//btn : button
    
    btnItemRect = CGRectMake(x, y, height, height);
    CGFloat xSep = x + lblWidth+lblSep;
    CGFloat width = 100;
    
    btnItemRect = lblItemFrame;
    btnItemRect.origin.y += sep + height;
    btnItemRect.size.width = width;
    btnItemRect.size.height = height;
    btnItemRect.origin.x = 0;
    
    int totalIndex = 0;
    CGRect rect;
    CGPoint start = CGPointMake(SCREEN_WIDTH/2-width/2, y+100+5*(sep+height));
    CGSize size = CGSizeMake(width, height+5);
    
    rect = [self calcBtnRect:start index:totalIndex size:size linSep:0 colSep:0];
    totalIndex++;
    [self addGridBtn:@"登录"   func:@selector(onLogin:)    rect:rect];
    
    loginActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    [loginActivityIndicator setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    loginActivityIndicator.frame = CGRectMake(rect.size.width/2,rect.size.height/2, 0, 0);
    [self.view addSubview:loginActivityIndicator];
    loginActivityIndicator.color = [UIColor greenColor]; // 改变圈圈的颜色； iOS5引入
    [loginActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    
    // instantiate the view controllers:
    self.recentcallViewController = [[RecentCallTableViewController alloc] initWithNibName:nil bundle:nil];
    self.contactlistViewController = [[ContactListTableViewController alloc] initWithNibName:nil bundle:nil];
    self.myinfoViewController = [[MyInfoTableViewController alloc] initWithNibName:nil bundle:nil];
    self.groupViewController = [[GroupTableViewController alloc] initWithNibName:nil bundle:nil];
    
    self.navRecentCallNaviController = [[UINavigationController alloc]initWithRootViewController:self.recentcallViewController];
    self.navContactsListNaviController = [[UINavigationController alloc]initWithRootViewController:self.contactlistViewController];
    self.navMyInfoNaviController = [[UINavigationController alloc]initWithRootViewController:self.myinfoViewController];
    self.navGroupNaviController = [[UINavigationController alloc]initWithRootViewController:self.groupViewController];

 
    [self.recentcallViewController  commonInit];//初始化
    self.myinfoViewController.loginID = self.loginID;

    // set the titles for the view controllers:
    self.recentcallViewController.title = @"会话";
    self.contactlistViewController.title = @"联系人";
    self.groupViewController.title = @"群组";
    self.myinfoViewController.title = @"设置";
    [self.recentcallViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIColor colorWithRed:0.0 green:210.0 blue:0.0 alpha:1],NSForegroundColorAttributeName,
                                                                  nil]
                                                        forState:UIControlStateSelected];
    [self.contactlistViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIColor colorWithRed:0.0 green:210.0 blue:0.0 alpha:1],NSForegroundColorAttributeName,
                                                                  nil]
                                                        forState:UIControlStateSelected];
    [self.groupViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIColor colorWithRed:0.0 green:210.0 blue:0.0 alpha:1],NSForegroundColorAttributeName,
                                                                  nil]
                                                        forState:UIControlStateSelected];
    [self.myinfoViewController.tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                  [UIColor colorWithRed:0.0 green:210.0 blue:0.0 alpha:1],NSForegroundColorAttributeName,
                                                                  nil]
                                                        forState:UIControlStateSelected];
    // set the images to appear in the tab bar:
    NSString *systemVer=[[UIDevice currentDevice] systemVersion];
    if([systemVer hasPrefix:@"8."])
    {
        UIImage *selImage1=[[UIImage imageNamed:@"tab_main_p.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selImage2=[[UIImage imageNamed:@"tab_contact_p.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selImage3=[[UIImage imageNamed:@"tab_group_p.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *selImage4=[[UIImage imageNamed:@"tab_setting_p.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *unselImage1=[[UIImage imageNamed:@"tab_main_n.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *unselImage2=[[UIImage imageNamed:@"tab_contact_n.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *unselImage3=[[UIImage imageNamed:@"tab_group_n.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *unselImage4=[[UIImage imageNamed:@"tab_setting_n.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        [self.recentcallViewController.tabBarItem setImage:unselImage1];
        [self.recentcallViewController.tabBarItem setSelectedImage:selImage1];
        [self.contactlistViewController.tabBarItem setImage:unselImage2];
        [self.contactlistViewController.tabBarItem setSelectedImage:selImage2];
        [self.groupViewController.tabBarItem setImage:unselImage3];
        [self.groupViewController.tabBarItem setSelectedImage:selImage3];
        [self.myinfoViewController.tabBarItem setImage:unselImage4];
        [self.myinfoViewController.tabBarItem setSelectedImage:selImage4];
    }
    else
    {
        [self.recentcallViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_main_p.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_main_n.png"]];
        [self.contactlistViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_contact_p.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_contact_n.png"]];
        [self.groupViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_group_p.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_group_n.png"]];
        [self.myinfoViewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tab_setting_p.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"tab_setting_n.png"]];
    }
    
    // instantiate the tab bar controller:
    self.tabBarController = [[UITabBarController alloc] init];
    
    // set the tab bar’s view controllers array:
#if (SDK_HAS_GROUP>0)
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             self.navRecentCallNaviController,
                                             //self.navContactsListNaviController,
                                             self.navGroupNaviController,
                                             self.navMyInfoNaviController,
                                             nil];
#else
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             self.navRecentCallNaviController,
                                             //self.navContactsListNaviController,
                                             self.navMyInfoNaviController,
                                             nil];
#endif
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onKeyboard:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    [tapGr release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.groupViewController
                                             selector:@selector(addAndRefreshTableView:)
                                                 name:@"SaveToGroupCallNotification"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_signalAccStatusQueryResponse release];
    _signalAccStatusQueryResponse = nil;
    [_queueAccStatusQueryResponse release];
    _queueAccStatusQueryResponse = nil;
    
    [terminalType release];
    [remoteTerminalType release];
#if (SDK_HAS_GROUP>0)
    [callID release];
#endif
    [remoteVideoView release];
    remoteVideoView = nil;
    [localVideoView release];
    localVideoView = nil;
    
    [loginActivityIndicator release];
    [super dealloc];
}

-(void)setLog:(NSString*)log
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
//    [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    [dateFormat setLocale:usLocale];
//    [usLocale release];
    NSString* datestr = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    CWLogDebug(@"SDKTEST:%@:%@",datestr,log);
    NSString* str = [NSString stringWithFormat:@"%@:%@",datestr,log];
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"ViewLog%d",mLogIndex]];
    mLogIndex++;
}

/**********************************初始化登录*************************************/
- (void)autoLogin
{
    [loginActivityIndicator startAnimating]; // 开始旋转
    [btnItemLogin setEnabled:NO];
    
    CWLogDebug(@"isGettingToken:%d",isGettingToken);
    if(!isGettingToken)
    {
        isGettingToken = YES;
        CWLogDebug(@"初始化rtc");
        [self onSDKInit];//打开应用则登录rtc
    }
}

- (IBAction)onLogin:(id)sender
{
    // 获取文本输入框内容，并存储到变量中
    NSString *nameString = mUsrID.text;
    
    // 检查输入的名字是否为空，如果为空，弹出提示信息
    if (nameString.length == 0) {
        if ([mUsrID.text isEqual: @""]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"账号不能为空" message:@"请输入账号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
            [alertView show];
            [alertView release];
        
            return;
        } else {
            nameString = self.loginID;
        }
    }
    else if (nameString.length != 11) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"账号格式有误" message:@"请输入11位手机号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alertView show];
        [alertView release];
        
        return;
    }
    else {
        self.loginID = mUsrID.text;
        self.myinfoViewController.loginID = mUsrID.text;
    }
    
    //Create a string representing the file pathNSString *plistPath;
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"LoginList.plist"];
    
    //Load the file in a dictionnary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    [dict setObject:nameString forKey:@"LoginID"];
    
    [dict writeToFile:plistPath atomically:YES];

    [loginActivityIndicator startAnimating]; // 开始旋转
    [btnItemLogin setEnabled:NO];
    
    CWLogDebug(@"isGettingToken:%d",isGettingToken);
    if(!isGettingToken)
    {
        isGettingToken = YES;
        CWLogDebug(@"初始化rtc");
        [self onSDKInit];//打开应用则登录rtc
    }
}

-(void)onSDKInit
{
    if (mSDKObj && [mSDKObj isInitOk])
    {
        //若sdk已成功初始化，请不要重复创建，更不要频繁重复向RTC平台发送请求
        CWLogDebug(@"已初始化成功");
        [self onRegister];
        return;
    }
    
    signal(SIGPIPE, SIG_IGN);
    mLogIndex = 0;
    mSDKObj = [[SdkObj alloc]init];
    [mSDKObj setSdkAgent:APP_USER_AGENT terminalType:self.terminalType UDID:[OpenUDIDRTC value] appID:mAppID.text appKey:mAppKey.text];

    [mSDKObj setDelegate:self];
    [mSDKObj doNavigation:@"default"];
}

-(void)onRegister
{
    if(!mSDKObj)
    {
        [self setLog:@"请先初始化"];
        CWLogDebug(@"isGettingToken:%d",isGettingToken);
        if(!isGettingToken)
        {
            isGettingToken = YES;
            CWLogDebug(@"初始化rtc");
            [self doUnRegister];
            [self onSDKInit];
        }
        [loginActivityIndicator stopAnimating]; // 结束旋转
        return;
    }
    if (!mAccObj)
    {
        [loginActivityIndicator startAnimating]; // 开始旋转
        [btnItemLogin setEnabled:NO];
        [self setLog:@"登录中..."];
        mAccObj = [[AccObj alloc]init];
        [mAccObj bindSdkObj:mSDKObj];
        [mAccObj setDelegate:self];
        //此句getToken代码为临时做法，开发者需通过第三方应用平台获取token，无需通过此接口获取
        //获取到返回结果后，请调用doAccRegister接口进行注册，传入参数为服务器返回的结构
        //不要重复获取token，除非token失效才需重新获取
        if(!mToken)
            [mAccObj getToken:self.loginID andType:accType andGrant:@"100<200<301<302<303<304<400" andAuthType:ACC_AUTH_TO_APPALL];
        else
        {
            isGettingToken = NO;
            NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
            [newResult setObject:mToken forKey:KEY_CAPABILITYTOKEN];
            [newResult setObject:mAccountID forKey:KEY_RTCACCOUNTID];
            [mAccObj doAccRegister:newResult];
        }
    }
    else if ([mAccObj isRegisted])
    {
        isGettingToken = NO;
        [self setLog:@"登录刷新"];
        [mAccObj doRegisterRefresh];
    }
    else
    {
        [self setLog:@"重新发起登录动作"];
        [mAccObj getToken:self.loginID andType:accType andGrant:@"100<200<301<302<303<304<400" andAuthType:ACC_AUTH_TO_APPALL];
    }
}

- (void)doUnRegister
{
    if (mAccObj)
    {
        [mAccObj doUnRegister];
        [mAccObj release];
        mAccObj = nil;
        mToken = nil;
        mAccountID = nil;
        CWLogDebug(@"注销完毕");
    }
    if(mSDKObj)
    {
        [mSDKObj release];
        mSDKObj = nil;
        mLogIndex = 0;
        CWLogDebug(@"release完毕");
    }
}

-(void)closeCallingView
{
    @synchronized(self) {
        if(callingView&&callingView.contactlistViewController)
        {
            [callingView.contactlistViewController dismissViewControllerAnimated:NO completion:nil];
        }
        if (callingView)
        {
            [callingView dismissViewControllerAnimated:NO completion:nil];
            [self presentViewController:self.tabBarController animated:NO completion:nil];
        }
        else
        {
            for(UIView * v in self.view.subviews)
            {
                if (v.tag == CALLINGVIEW_TAG)
                {
                    [v removeFromSuperview];
                }
            }
        }
        callingView = nil;
    }
}

- (IBAction)onKeyboard:(id)sender
{
    [mUsrID resignFirstResponder];
}

- (void)checkUserStatus:(NSString*)accIds
{
    [self setLog:@"检查用户状态..."];
    if (nil == mAccObj)
    {
        [self setLog:@"请先登录"];
        return;
    }
    [mAccObj doAccStatusQuery:accIds andSearchFlag:ACC_SEARCH_ALL];
}

-(void)updateMyInfoTableView
{
    [self.myinfoViewController getCurrentInfo];
    [self.myinfoViewController.labelView setText:self.loginID];
    self.myinfoViewController.infoImageName =   [NSString stringWithFormat:@"currentInfoImage.png"];
    self.myinfoViewController.infoImagePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.myinfoViewController.infoImageName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.myinfoViewController.infoImagePath])
    {
        [self.myinfoViewController.infoPhotoImageView setImage:[UIImage imageWithContentsOfFile:self.myinfoViewController.infoImagePath]];
    }
    [self.myinfoViewController.tableView reloadData];
}

-(void)getAccStatus:(id)userInfor
{
    NSAutoreleasePool*pool = [[NSAutoreleasePool alloc] init];
    [_signalAccStatusQueryResponse lock];
    NSLog(@"wait for AccStatusQueryResponse");
    [_signalAccStatusQueryResponse waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    if ([_queueAccStatusQueryResponse count] > 0) {
        [_queueAccStatusQueryResponse removeObjectAtIndex:0];
    }
    NSLog(@"comsume a AccStatusQueryResponse");
    [_signalAccStatusQueryResponse unlock];

    [self writeCurrentInfoToFile];

    [self performSelectorOnMainThread:@selector(updateMyInfoTableView) withObject:nil waitUntilDone:NO];

    [pool release];
}

/**********************************设置响应*************************************/
- (IBAction)onSetTerminalType:(id)sender
{
    UIActionSheet* act = [[UIActionSheet alloc]initWithTitle:@"终端类型选择"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:
                          TERMINAL_TYPE_ANY,
                          TERMINAL_TYPE_TV,
                          TERMINAL_TYPE_PAD,
                          TERMINAL_TYPE_PHONE,
                          TERMINAL_TYPE_BROWSER,
                          TERMINAL_TYPE_OTHER,
                          nil];
    act.tag = TAG_TERMINAL_TYPE_SELECT;
    [act showInView:self.view];
    [act release];
}

- (IBAction)onSetAddress:(id)sender
{
    UIActionSheet* act = [[UIActionSheet alloc]initWithTitle:@"导航地址选择"
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:@"cloud2-123",@"cloud2-70038",
                          nil];
    act.tag = TAG_ADDRESS_SELECT;
    [act showInView:self.view];
    [act release];
}

#pragma mark - MBProgressHUDDelegate

-(BOOL)isDeviceMuted
{
    CFStringRef originRoute;
    UInt32 originRouteSize=sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &originRouteSize, &originRoute);
    return (CFStringGetLength(originRoute) > 0 ? NO : YES);
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == TAG_TERMINAL_TYPE_SELECT)
    {
        
        int idx = buttonIndex - actionSheet.firstOtherButtonIndex;
        if (idx >= 0 && idx <= 5)
        {
            [terminalType release];
            terminalType = [NSString stringWithString:[actionSheet buttonTitleAtIndex:buttonIndex]];
            [terminalType retain];
        }
        else
        {
            [terminalType release];
            terminalType = TERMINAL_TYPE_PHONE;
            [terminalType retain];
        }
        [btnItemType setTitle:terminalType forState:UIControlStateNormal];
        return;
        
    }
    if (actionSheet.tag == TAG_ADDRESS_SELECT)
    {
        int idx = buttonIndex - actionSheet.firstOtherButtonIndex;
        if (idx >= 0 && idx <= 5)
        {
            switch (idx)
            {
                case 0:
                    [mNaviAddress setText:@"cloud2-123"];
                    [mAppID setText:@"123"];
                    [mAppKey setText:@"123456"];
                    break;
                case 1:
                    [mNaviAddress setText:@"cloud2-70038"];
                    [mAppID setText:APPID];
                    [mAppKey setText:APPKEY];
                    break;
            }
        }
        [btnItemAddress setTitle:mNaviAddress.text forState:UIControlStateNormal];
        return;
    }
}

-(void)onRecvMyInfoEvent:(NSNotification *)notification
{
    if (nil == notification)
    {
        CWLogDebug(@"wrong notification");
        return;
    }
    if (nil == [notification userInfo])
    {
        CWLogDebug(@"wrong notification param");
        return;
    }
    NSDictionary *data=[notification userInfo];
    int msgid = [[data objectForKey:@"msgid"]intValue];
    int arg  = [[data objectForKey:@"arg"]intValue];
    
    if (MSG_UPDATE_STATUS == msgid)
    {
//        [self checkUserStatus:self.loginID];
//        HUD = [[MBProgressHUD alloc] initWithView:self.navMyInfoNaviController.view];
//        [self.navMyInfoNaviController.view addSubview:HUD];
//        HUD.delegate = self;
//        HUD.labelText = @"Loading";
//        HUD.detailsLabelText = @"updating data";
//        HUD.square = YES;
//        [HUD showWhileExecuting:@selector(getAccStatus:) onTarget:self withObject:nil animated:YES];
        [self performSelectorOnMainThread:@selector(updateMyInfoTableView) withObject:nil waitUntilDone:NO];
    }
    else if (MSG_UPDATE_VIDEO_CODEC == msgid)
    {
        self.videoCodecName  = [data objectForKey:@"videoCodec"];
        NSString* reso = [data objectForKey:@"videoResolution"];
        
        if ([reso isEqualToString:@"流畅"]) {
            mVideoSize =  CGSizeMake(144,176) ;
        }
//        else if ([reso isEqualToString:@"QVGA(320*240)"]) {
//            mVideoSize =  CGSizeMake(240,320)  ;
//        }
        else if ([reso isEqualToString:@"标清"]) {
            mVideoSize =  CGSizeMake(288,352)  ;
        }
//        else if ([reso isEqualToString:@"VGA(640*480)"]) {
//            mVideoSize =  CGSizeMake(480,640)  ;
//        }
        else if ([reso isEqualToString:@"高清"]) {
            mVideoSize =  CGSizeMake(576,704)  ;
        }
//        else if ([reso isEqualToString:@"D1(720*576)"]) {
//            mVideoSize =  CGSizeMake(576,720)  ;
//        }else if ([reso isEqualToString:@"D4(1280*720"]) {
//            mVideoSize =  CGSizeMake(720,1280) ;
//        }
        [self writeCurrentInfoToFile];
        [self setAVCodec];
    }
    else if (MSG_UPDATE_AUDIO_CODEC == msgid)
    {
        self.audioCodecName  = [data objectForKey:@"audioCodec"];
        
        [self writeCurrentInfoToFile];
        [self setAVCodec];
        
    }
    else if (MSG_UPDATE_AUTOACCEPT == msgid)
    {
        self.autoAccept  = [data objectForKey:@"autoaccept"];
        
        [self writeCurrentInfoToFile];
        
    }
    else if (MSG_UPDATE_UNREG == msgid)
    {
        if (mAccObj)
        {
            [mAccObj doUnRegister];
            [mAccObj release];
            mAccObj = nil;
            mToken = nil;
            mAccountID = nil;
            [self setLog:@"注销完毕"];
            
            if(mSDKObj)
            {
                [mSDKObj release];
                mSDKObj = nil;
                mLogIndex = 0;
                [self setLog:@"release完毕"];
            }
            [self.myinfoViewController.loginActivityIndicator stopAnimating];
            [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
            self.view.hidden = NO;
            isFirstpage = YES;
        }
        else
        {
            [self setLog:@"请先登录"];
        }
    }
    else if (MSG_CHANGE_UNREG == msgid)
    {
        if (mAccObj)
        {
            [mAccObj doUnRegister];
            [mAccObj release];
            mAccObj = nil;
            mToken = nil;
            mAccountID = nil;
            [self setLog:@"注销完毕"];
            
            if(mSDKObj)
            {
                [mSDKObj release];
                mSDKObj = nil;
                mLogIndex = 0;
                [self setLog:@"release完毕"];
            }
            [self.myinfoViewController.loginActivityIndicator stopAnimating];
            [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
            self.view.hidden = NO;
            isFirstpage = YES;
            
            if(arg==1)//当前由多人切换到浏览器
                changeVersion=2;
            else if(arg==2)
                changeVersion=1;
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"ChangeVersionNotification" object:nil];
            [self autoLogin];
        }
        else
        {
            [self setLog:@"请先登录"];
        }
    }
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    NSLog(@"%@",videoPath);
    NSLog(@"%@",error);
}

/**********************************事件响应*************************************/
-(void)onRecvEvent:(NSNotification *)notification
{
    if (nil == notification)
    {
        CWLogDebug(@"wrong notification");
        return;
    }
    if (nil == [notification userInfo])
    {
        CWLogDebug(@"wrong notification param");
        return;
    }
    NSDictionary *data=[notification userInfo];
    int msgid = [[data objectForKey:@"msgid"]intValue];
    int arg  = [[data objectForKey:@"arg"]intValue];

    if (MSG_NEED_VIDEO == msgid)//创建呼叫
    {
        long long  localV = [[data objectForKey:@"lvideo"]longLongValue];
        long long  remoteV = [[data objectForKey:@"rvideo"]longLongValue];
        remoteVideoView = (IOSDisplay*)remoteV;
        localVideoView = (UIView*)localV;
        CWLogDebug(@"VideoWindow:[L:%d][R:%d]",localV,remoteV);
        
        BOOL isCallOut = [[data objectForKey:@"iscallout"]boolValue];
        
        if (nil == mCallObj && isCallOut)
        {
                mCallObj = [[CallObj alloc]init];
                [mCallObj setDelegate:self];
                [mCallObj bindAcc:mAccObj];
                int ret = -1;
                SDK_CALLTYPE callType = (remoteV != 0)? AUDIO_VIDEO:AUDIO;
                mCallObj.CallMedia = (remoteV != 0)? MEDIA_TYPE_VIDEO:MEDIA_TYPE_AUDIO;
                NSString* numberString = [self.remotePhoneNum componentsJoinedByString:@""];//数组切成字符串

                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                     numberString,KEY_CALLED,
                                     [NSNumber numberWithInt:callType],KEY_CALL_TYPE,
                                     [NSNumber numberWithInt:remoteAccType],KEY_CALL_REMOTE_ACC_TYPE,
                                     self.remoteTerminalType,KEY_CALL_REMOTE_TERMINAL_TYPE,
                                     @"yewuxinxi",KEY_CALL_INFO,
                                     nil];
                CWLogDebug(@"doMakeCall Param:%@",dic);
                ret = [mCallObj doMakeCall:dic];
                if (EC_OK > ret)
                {
                    if([thePlayer isPlaying])
                    {
                        [thePlayer stop];
                        AudioSessionSetActive (false);
                        [thePlayer release];
                        thePlayer = nil;
                    }
                    if (mCallObj)
                    {
                        //[mCallObj doHangupCall];
                        [mCallObj release];
                        mCallObj = nil;
                    }
                    
                    [self closeCallingView];
                    [self setLog:[NSString stringWithFormat:@"创建呼叫失败:%@",[SdkObj ECodeToStr:ret]]];
                    
                }
            
                //在这里增加去电振铃音
                [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
                NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"ring180" ofType:@"mp3"];      //创建音乐文件路径
                NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
                thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
                //创建播放器
                [musicURL release];
                [thePlayer setVolume:1.0];   //设置音量大小
                thePlayer.numberOfLoops = -1;//设置音乐播放次数  -1为一直循环
                if([thePlayer prepareToPlay]&&![self isDeviceMuted])
                {
                    [thePlayer play];
                }
        }
        return;
    }
#if (SDK_HAS_GROUP>0)
    if (MSG_GROUP_CREATE == msgid)//创建多人
    {
        long long localV = [[data objectForKey:@"lvideo"]longLongValue];
        long long remoteV = [[data objectForKey:@"rvideo"]longLongValue];
        remoteVideoView = (IOSDisplay*)remoteV;
        localVideoView = (UIView*)localV;
        CWLogDebug(@"VideoWindow:[L:%d][R:%d]",localV,remoteV);
        
        BOOL isCallOut = [[data objectForKey:@"iscallout"]boolValue];
        
        if (nil == mCallObj && isCallOut )
        {
            mCallObj = [[CallObj alloc]init];
            [mCallObj setDelegate:self];
            [mCallObj bindAcc:mAccObj];
            
            NSString* remoteUri = self.loginID;
            NSString* numberString = [self.remotePhoneNum componentsJoinedByString:@","];
            NSString* remoteUri2 = nil;
            if([self.remotePhoneNum count]!=0)
                remoteUri2 = [NSString stringWithFormat:@"%@,%@",self.loginID,numberString];//账号之间用逗号隔开
            else
                remoteUri2 = self.loginID;
            NSArray* remoteAccArr = [remoteUri2 componentsSeparatedByString:@","];
            NSUInteger countMem=[remoteAccArr count];
            NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                             [NSNumber numberWithInt:accType],
                                             nil];
            for(int i = 1; i<countMem; i++)
            {
                [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
            }
            
            int codec = 0;
            if ([self.videoCodecName isEqualToString:@"VP8"]) {
                codec = 1;
            } else {
                codec = 0;
            }
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 remoteUri,KEY_GRP_CREATER,
                                 terminalType,KEY_GRP_CREATERTYPE,
                                 [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                                 remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                                 [NSNumber numberWithInt:grpType],KEY_GRP_TYPE,
                                 self.groupName,KEY_GRP_NAME,
                                 remoteUri2,KEY_GRP_INVITEELIST,
                                 @"kong",KEY_GRP_PASSWORD,
                                 [NSNumber numberWithInt:codec],KEY_GRP_CODEC,//微直播codec，不传则默认h264，codec格式必须与setVideoCodec设置格式一致
                                 nil];
            int ret = [mCallObj groupCall:SDK_GROUP_CREATE param:dic];
            if (EC_OK > ret)
            {
                if([thePlayer isPlaying])
                {
                    [thePlayer stop];
                    AudioSessionSetActive (false);
                    [thePlayer release];
                    thePlayer = nil;
                }
                if (mCallObj)
                {
                    //[mCallObj doHangupCall];
                    [mCallObj release];
                    mCallObj = nil;
                }
                
                [self closeCallingView];
                [self setLog:[NSString stringWithFormat:@"创建呼叫失败:%@",[SdkObj ECodeToStr:ret]]];
                
            }
            
            //在这里增加去电振铃音
            [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
            NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"ring180" ofType:@"mp3"];      //创建音乐文件路径
            NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
            thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
            //创建播放器
            [musicURL release];
            [thePlayer setVolume:1.0];   //设置音量大小
            thePlayer.numberOfLoops = -1;//设置音乐播放次数  -1为一直循环
            if([thePlayer prepareToPlay]&&![self isDeviceMuted])
            {
                [thePlayer play];
            }
        }
        return;
    }
    if (MSG_GROUP_ACCEPT == msgid)//自动接听
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        long long localV = [[data objectForKey:@"lvideo"]longLongValue];
        long long remoteV = [[data objectForKey:@"rvideo"]longLongValue];
        remoteVideoView = (IOSDisplay*)remoteV;
        localVideoView = (UIView*)localV;
        [mCallObj performSelector:@selector(doAcceptCall:) withObject:[NSNumber numberWithInt:AUDIO_VIDEO] afterDelay:0.1];
        [callingView onCallOk:YES];
        return;
    }
    if (MSG_GROUP_LIST == msgid)//获取列表
    {
        NSString* remoteUri = self.loginID;
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:isGroupCreator],KEY_GRP_ISCREATOR,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_GETMEMLIST param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"获取成员列表失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_INVITE == msgid)//邀请成员
    {
        NSString* memberList = [data objectForKey:KEY_GRP_INVITEDMBLIST];
        NSString* remoteUri = self.loginID;
        NSArray* remoteAccArr = [memberList componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
        }
        int mode=SDK_GROUP_AUDIO_SENDRECV;//语音群聊
        if(grpType == 21 || grpType == 22 || grpType == 29)//视频对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY_VIDEO_RECVONLY;
        else if(grpType == 1 || grpType == 2 || grpType == 9)//语音对讲或两方或直播
            mode = SDK_GROUP_AUDIO_RECVONLY;
        else if(grpType == 20 )//视频群聊
            mode = -1;
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:isGroupCreator],KEY_GRP_ISCREATOR,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             memberList,KEY_GRP_INVITEDMBLIST,
                             [NSNumber numberWithInt:mode],KEY_GRP_MODE,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_INVITEMEMLIST param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"邀请成员失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_JOIN == msgid)//加入会议
    {
        long long localV = [[data objectForKey:@"lvideo"]longLongValue];
        long long remoteV = [[data objectForKey:@"rvideo"]longLongValue];
        remoteVideoView = (IOSDisplay*)remoteV;
        localVideoView = (UIView*)localV;
        
        BOOL isCallOut = [[data objectForKey:@"iscallout"]boolValue];
        
        if (nil == mCallObj && isCallOut )
        {
            mCallObj = [[CallObj alloc]init];
            [mCallObj setDelegate:self];
            [mCallObj bindAcc:mAccObj];
            
            NSString* remoteUri = self.loginID;
            NSString* remoteUri2 = joinCallID;//此处填入callID
            
//            int mode;
//            if(grpType >= 20)
//                mode = SDK_GROUP_AUDIO_SENDRECV_VIDEO_RECVONLY;
//            else
//                mode = SDK_GROUP_AUDIO_SENDRECV;
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 remoteUri,KEY_GRP_CREATER,
                                 terminalType,KEY_GRP_CREATERTYPE,
                                 [NSNumber numberWithInt:1],KEY_GRP_JOINONLY,
                                 [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                                 remoteUri2,KEY_GRP_CALLID,
                                 remoteUri,KEY_GRP_INVITEDMBLIST,
                                 /*[NSNumber numberWithInt:mode],KEY_GRP_MODE,
                                 @"",KEY_GRP_PASSWORD,*/
                                 nil];
            int ret = [mCallObj groupCall:SDK_GROUP_JOIN param:dic];
            if (EC_OK > ret)
            {
                [self setLog:[NSString stringWithFormat:@"加入会议失败:%@",[SdkObj ECodeToStr:ret]]];
            }
            [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
        }
        return;
    }
    if (MSG_GROUP_KICK == msgid)//踢出成员
    {
        NSString* memberList = [data objectForKey:KEY_GRP_KICKEDMBLIST];
        NSString* remoteUri = self.loginID;
        NSArray* remoteAccArr = [memberList componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:isGroupCreator],KEY_GRP_ISCREATOR,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             memberList,KEY_GRP_KICKEDMBLIST,
                             isGroupCreator==1?@"1112":@"",KEY_GRP_REPLACERMEMBER,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_KICKMEMLIST param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"踢出成员失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_CLOSE == msgid)//关闭会议
    {
        NSString* remoteUri = self.loginID;
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_CLOSE param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"关闭会话失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_UNMUTE == msgid)//给麦
    {
        NSString* member = [data objectForKey:KEY_GRP_MEMBER];
        if(grpType == 1||grpType == 21)
            member = self.loginID;
        int modeUp,modeDown;
        if(grpType >= 20)
        {
            modeUp = SDK_GROUP_UNMUTE_AUDIO_VIDEO;
            modeDown = SDK_GROUP_UNMUTE_AUDIO_VIDEO;
        }
        else
        {
            modeUp = SDK_GROUP_UNMUTE_AUDIO;
            modeDown = SDK_GROUP_UNMUTE_AUDIO;
        }
        NSMutableArray* mbOperationList = [NSMutableArray arrayWithObjects:
                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                            member,KEY_GRP_MEMBER,
                                            [NSNumber numberWithInt:modeUp],KEY_GRP_UPOPERATIONTYPE,
                                            [NSNumber numberWithInt:modeDown],KEY_GRP_DWOPERATIONTYPE,
                                            nil],
                                           nil];
        NSString* remoteUri = self.loginID;
        NSArray* remoteAccArr = [member componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:isGroupCreator],KEY_GRP_ISCREATOR,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             mbOperationList,KEY_GRP_MBOPERATIONLIST,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_MIC param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"给麦失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_MUTE == msgid)//收麦
    {
        NSString* member = [data objectForKey:KEY_GRP_MEMBER];
        if(grpType == 1||grpType == 21)
            member = self.loginID;
        int modeUp,modeDown;
        if(grpType >= 20)
        {
            modeUp = SDK_GROUP_MUTE_AUDIO_VIDEO;
            modeDown = SDK_GROUP_UNMUTE_AUDIO_VIDEO;
        }
        else
        {
            modeUp = SDK_GROUP_MUTE_AUDIO;
            modeDown = SDK_GROUP_UNMUTE_AUDIO;
        }
        NSMutableArray* mbOperationList = [NSMutableArray arrayWithObjects:
                                           [NSDictionary dictionaryWithObjectsAndKeys:
                                            member,KEY_GRP_MEMBER,
                                            [NSNumber numberWithInt:modeUp],KEY_GRP_UPOPERATIONTYPE,
                                            [NSNumber numberWithInt:modeDown],KEY_GRP_DWOPERATIONTYPE,
                                            nil],
                                           nil];
        NSString* remoteUri = self.loginID;
        NSArray* remoteAccArr = [member componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         nil];
        for(int i = 0; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:isGroupCreator],KEY_GRP_ISCREATOR,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             mbOperationList,KEY_GRP_MBOPERATIONLIST,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_MIC param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"收麦失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
    if (MSG_GROUP_DISPLAY == msgid)//分屏
    {
        NSString* memberList = [data objectForKey:KEY_GRP_MEMBER];
        NSString* remoteUri = self.loginID;
        //SDK_GROUP_DISPLAYMODE dismode = SDK_GROUP_EQUALDIS;
        NSArray* remoteAccArr = [memberList componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        NSMutableArray* remoteTypeArr = [NSMutableArray arrayWithObjects:
                                         [NSNumber numberWithInt:accType],
                                         nil];
        for(int i = 1; i<countMem; i++)
        {
            [remoteTypeArr addObject:[NSNumber numberWithInt:remoteAccType]];
        }
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             remoteUri,KEY_GRP_CREATER,
                             terminalType,KEY_GRP_CREATERTYPE,
                             [NSNumber numberWithInt:accType],KEY_CALL_ACC_TYPE,
                             remoteTypeArr,KEY_CALL_REMOTE_ACC_TYPE,
                             callID,KEY_GRP_CALLID,
                             memberList,KEY_GRP_MEMBERLIST,
                             nil];
        int ret = [mCallObj groupCall:SDK_GROUP_VIDEO param:dic];
        if (EC_OK > ret)
        {
            [self setLog:[NSString stringWithFormat:@"分屏失败:%@",[SdkObj ECodeToStr:ret]]];
        }
    }
#endif
    if (MSG_SET_AUDIO_DEVICE == msgid)//切换麦克
    {
        if (!mCallObj)
        {
            [self setLog:@"切换放音设备前请先呼叫"];
            return;
        }
        //SDK_AUDIO_OUTPUT_DEVICE ad = [mCallObj getAudioOutputDeviceType];
        if (arg == 1/*SDK_AUDIO_OUTPUT_DEFAULT == ad || SDK_AUDIO_OUTPUT_HEADSET == ad*/)
        {
            [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_SPEAKER];
            [callingView setCallStatus:@"放音设备切换到外放"];
        }
        else
        {
            [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
            [callingView setCallStatus:@"放音设备切换到听筒/耳机"];
            
        }
        
        return;
    }
    if (MSG_SET_VIDEO_DEVICE == msgid)//切换摄像头
    {
        if (!mCallObj)
        {
            [self setLog:@"切换摄像头前请先呼叫"];
            return;
        }
        cameraIndex++;
        if (cameraIndex > 1)
        {
            cameraIndex = 0;
        }
        [mCallObj doSwitchCamera:cameraIndex];
        [callingView setCallStatus:[NSString stringWithFormat:@"摄像头切换到:%d",cameraIndex]];
        return;
    }
    if (MSG_HIDE_LOCAL_VIDEO == msgid)//隐藏摄像头
    {
        if (!mCallObj || mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
        {
            [self setLog:@"隐藏摄像头前请先呼叫"];
            return;
        }
        [mCallObj doHideLocalVideo:(SDK_HIDE_LOCAL_VIDEO)arg];
        return;
    }
    if (MSG_START_RECORDING == msgid)//开始录像
    {
        if (!mCallObj || mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
        {
            [self setLog:@"录制视频前请先呼叫"];
            return;
        }
        [mCallObj doStartRecording];
        return;
    }
    if (MSG_STOP_RECORDING == msgid)//停止录像
    {
        if (!mCallObj || mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
        {
            [self setLog:@"停止录制视频前请先呼叫"];
            return;
        }
        [mCallObj doStopRecording];
        
        return;
    }
    if (MSG_ROTATE_REMOTE_VIDEO == msgid)//旋转摄像头
    {
        if (!mCallObj || mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
        {
            [self setLog:@"请先呼叫"];
            return;
        }
        [mCallObj doRotateRemoteVideo:arg];
        return;
    }
    if (MSG_SNAP == msgid)//截图
    {
        if (!mCallObj || mCallObj.CallMedia!= MEDIA_TYPE_VIDEO)
        {
            [self setLog:@"请先呼叫"];
            return;
        }
        [mCallObj doSnapImage];
        return;
    }
    if (MSG_HANGUP == msgid)//挂断
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        if (mCallObj)
        {
            [mCallObj doHangupCall];
            [mCallObj release];
            mCallObj = nil;
        }
        
        cameraIndex = 1;
#if (SDK_HAS_GROUP>0)
        [callID release];
        callID = @"";
        [callID retain];
#endif
        [callingView onCallOk:NO];
        [self closeCallingView];
        [self setLog:@"呼叫挂断"];
        return;
    }
    if (MSG_ACCEPT == msgid)//接听
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        if (mCallObj.CallMedia == MEDIA_TYPE_AUDIO)
             [mCallObj performSelector:@selector(doAcceptCall:) withObject:[NSNumber numberWithInt:AUDIO] afterDelay:0.1];
        else
        {
            long long localV = [[data objectForKey:@"lvideo"]longLongValue];
            long long remoteV = [[data objectForKey:@"rvideo"]longLongValue];
            remoteVideoView = (IOSDisplay*)remoteV;
            localVideoView = (UIView*)localV;
            CWLogDebug(@"AcceptCall_VideoWindow:[L:%d][R:%d]",localV,remoteV);
            [mCallObj performSelector:@selector(doAcceptCall:) withObject:[NSNumber numberWithInt:AUDIO_VIDEO] afterDelay:0.1];
        }
        [mCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
        [callingView onCallOk:YES];
                
        return;
    }
    if (MSG_REJECT == msgid)//拒接
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        [self closeCallingView];
        if (mCallObj)
        {
            [mCallObj doRejectCall];
            [mCallObj release];
            mCallObj = nil;
        }
        
        return;
        
    }
    if (MSG_MUTE == msgid)//静音
    {
        if (!mCallObj)
        {
            [self setLog:@"静音前请先呼叫"];
            return;
        }
        if ([mCallObj MuteStatus] == NO)
        {
            [mCallObj doMuteMic:MUTE_DOMUTE];
        }
        else
        {
            [mCallObj doMuteMic:MUTE_DOUNMUTE];
        }
        return;
    }
    if (MSG_UPDATE_CALLDURATION == msgid)
    {
        if (!mCallObj)
        {
            [self setLog:@"呼叫尚未开始"];
            if([thePlayer isPlaying])
            {
                [thePlayer stop];
                AudioSessionSetActive (false);
                [thePlayer release];
                thePlayer = nil;
            }
            [self closeCallingView];
            return;
        }
        unsigned int cd = mCallObj.CallDuration;
        if (cd == 0)
            return;
        
        [callingView setCallDuration:cd
                             withCPU:[[UIDevice currentDevice]cpuUseage]
                             withMem:[[UIDevice currentDevice]usedMemory]];
        return;
    }

}

//设置音视频编码
-(void)setAVCodec
{
    if ([self.videoCodecName isEqualToString:@"VP8"]) {
        [mSDKObj setVideoCodec:[NSNumber numberWithInt:1]];
    } else {
        [mSDKObj setVideoCodec:[NSNumber numberWithInt:2]];
    }
    
    if ([self.audioCodecName isEqualToString:@"iLBC"]) {
        [mSDKObj setAudioCodec:[NSNumber numberWithInt:1]];
    } if ([self.audioCodecName isEqualToString:@"OPUS"]) {
        [mSDKObj setAudioCodec:[NSNumber numberWithInt:2]];
    }
//    else {
//        [mSDKObj setAudioCodec:[NSNumber numberWithInt:2]];
//    }
    
    int priority = 0;
    if(mVideoSize.width == 144 && mVideoSize.height == 176)
        priority = 1;
    else if(mVideoSize.width == 240 && mVideoSize.height == 320)
        priority = 2;
    else if(mVideoSize.width == 288 && mVideoSize.height == 352)
        priority = 3;
    else if(mVideoSize.width == 480 && mVideoSize.height == 640)
        priority = 4;
    else if(mVideoSize.width == 576 && mVideoSize.height == 704)
        priority = 5;
    else if(mVideoSize.width == 576 && mVideoSize.height == 720)
        priority = 6;
    else if(mVideoSize.width == 720 && mVideoSize.height == 1280)
        priority = 7;
    
    [mSDKObj setVideoAttr:[NSNumber numberWithInt:1]];
}

/////////////////////////////////回调函数：导航结果回调///////////////////////////////////////
-(void)onNavigationResp:(int)code error:(NSString*)error
{
    [loginActivityIndicator stopAnimating]; // 结束旋转
    [btnItemLogin setEnabled:YES];

    if (0 == code)
    {
        [self setLog:[NSString stringWithFormat:@"初始化成功"]];
        [self setAVCodec];
        [self onRegister];
    }
    else
    {
        [self setLog:[NSString stringWithFormat:@"初始化失败:%d,%@",code,error]];
        NSString * msg=[NSString stringWithFormat:@"%d", code];
        [self myAlertView:@"初始化失败" msg:msg];
        
        if (mSDKObj)
        {
            [mSDKObj release];
            mSDKObj = nil;
            mLogIndex = 0;
        }
        isGettingToken = NO;
    }
}

-(void)onLog:(SDK_LOG_LEVEL)level data:(const char*)data len:(int)len
{
    if (SDK_LOG_DEBUG == level)
    {
        CWLogDebug(@"%s",data);
    }
    else if (SDK_LOG_ERROR == level)
    {
        CWLogError(@"%s",data);
    }
    else if (SDK_LOG_WARNING == level)
    {
        CWLogWarn(@"%s",data);
    }
    else
    {
        CWLogInfo(@"%s",data);
    }
}

/////////////////////////////////回调函数：呼叫到达通知///////////////////////////////////////
-(int)onCallIncoming:(NSDictionary*)param withNewCallObj:(CallObj*)newCallObj accObj:(AccObj*)accObj
{
    CWLogDebug(@"result is %@onCall:%@",param,accObj);
    //在这里增加来电后台通知或前台弹呼叫接听页面
    [newCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_SPEAKER];
    
    NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"mlbq" ofType:@"mp3"];      //创建音乐文件路径
    NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
    thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
    //创建播放器
    [musicURL release];
    [thePlayer setVolume:1.0];   //设置音量大小
    thePlayer.numberOfLoops = -1;//设置音乐播放次数  -1为一直循环
    //BOOL playSuccess=YES;
    //playSuccess=[thePlayer prepareToPlay];
    //sleep(1);
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    AudioSessionSetActive(true);
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if([thePlayer prepareToPlay]&&![self isDeviceMuted])
    {
//        [thePlayer prepareToPlay];
        [thePlayer play];
    }
    
    
    mCallObj = newCallObj;
    [mCallObj setDelegate:self];
    int callType = [[param objectForKey:KEY_CALL_TYPE]intValue];
    NSString* uri = [param objectForKey:KEY_CALLER];
    
    const char* cacc = [uri UTF8String];
    int strindex1=0,strindex2=0;
    int l = (int)strlen(cacc);
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='-')
        {
            strindex1=i;
            break;
        }
    }
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='~')
        {
            strindex2=i;
            break;
        }
    }
    NSString* accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
    
    NSArray *num = [NSArray arrayWithObjects:accNum,nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToRecentCallNotification"
     object:num];
    
    if ([self isBackground])
    {
        [self setCallIncomingFlag:YES];
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:callType] forKey:KEY_CALL_TYPE];
        [[NSUserDefaults standardUserDefaults]setObject:uri     forKey:KEY_CALLER];
        [[NSUserDefaults standardUserDefaults]setObject:@""     forKey:KEY_GRP_NAME];
        
        NSString *callTypeStr;
        if((callType == AUDIO || callType == AUDIO_RECV || callType == AUDIO_SEND))
            callTypeStr = @"语音来电";
        else
            callTypeStr = @"视频来电";
        makeNotification(@"接听",[NSString stringWithFormat:@"%@:%@",callTypeStr,accNum],UILocalNotificationDefaultSoundName,YES);
        return 0;
    }
    
    CCallingViewController* view1 = [[CCallingViewController alloc]init];
    view1.isVideo = !(callType == AUDIO || callType == AUDIO_RECV || callType == AUDIO_SEND);
    view1.isCallOut = NO;
#if(SDK_HAS_GROUP>0)
    isGroup = 0;
#endif
    if (view1.isVideo)
    {
        view1.isAutoRotate = isAutoRotationVideo;
    }
    
    view1.view.frame = self.view.frame;
    [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
    callingView = view1;
    callingView.mCallingNum.text=accNum;
    if (view1.isVideo)
        callingView.mCallingInfo.text=@"视频来电中...";
    else
        callingView.mCallingInfo.text=@"语音来电中...";
    [self presentViewController:view1 animated:NO completion:nil];
    [view1 release];
    
    if([self.autoAccept isEqualToString:@"YES"])//自动应答
    {
        [callingView.btnHangup setHidden:NO];
        [callingView.btnAccept setHidden:YES];
        [callingView.btnReject setHidden:YES];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_ACCEPT],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                [NSNumber numberWithLongLong:(long long)(remoteVideoView)],@"rvideo",
                                [NSNumber numberWithLongLong:(long long)(localVideoView)],@"lvideo",
                                nil];
        
        CWLogDebug(@"param is %@",params);
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    }
    
    return 0;
}

/////////////////////////////////回调函数：消息到达通知///////////////////////////////////////
-(int)onReceiveIM:(NSDictionary*)param withAccObj:(AccObj*)accObj
{
    CWLogDebug(@"result is %@onCall:%@",param,accObj);
    
    NSString* mime = [param objectForKey:KEY_CALL_TYPE];
    NSString* uri = [param objectForKey:KEY_CALLER];
    NSString* content = [param objectForKey:KEY_CALL_INFO];
    
    
    const char* cacc = [uri UTF8String];
    int strindex1=0,strindex2=0;
    int l = (int)strlen(cacc);
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='-')
        {
            strindex1=i;
            break;
        }
    }
    for(int i = 0;i<l;i++)
    {
        if(cacc[i]=='~')
        {
            strindex2=i;
            break;
        }
    }
    NSString* accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
    
    return 0;
}

/////////////////////////////////回调函数：消息发送通知///////////////////////////////////////
-(int)onSendIM:(int)status
{
    [self setLog:[NSString stringWithFormat:@"发送消息:%d",status]];
    
    return 0;
}

/////////////////////////////////回调函数：多人来电/////////////////////////////////////////
#if (SDK_HAS_GROUP>0)
-(int)onGroupCreate:(NSDictionary*)param withNewCallObj:(CallObj*)newCallObj accObj:(AccObj*)accObj
{
    CWLogDebug(@"%s result is %@onCall:%@",__FUNCTION__,param,accObj);
    //在这里增加来电后台通知或前台弹呼叫接听页面
    
    mCallObj = newCallObj;
    [mCallObj setDelegate:self];
    NSString* uri = [param objectForKey:KEY_GRP_CALLID];
    isGroupCreator = [[param objectForKey:KEY_GRP_ISCREATOR]intValue];
    grpType = [[param objectForKey:KEY_GRP_TYPE]intValue];
    self.groupName = [param objectForKey:KEY_GRP_NAME];
    
    if([param objectForKey:KEY_GRP_CALLID]!=nil&&[param objectForKey:KEY_GRP_CALLID]!=[NSNull null])
    {
        [callID release];
        callID = uri;
        [callID retain];
    }
    NSArray *num = [NSArray arrayWithObjects:
                    self.groupName,
                    nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToGroupCallNotification"
     object:num];
    
    if (isGroupCreator==0)
    {
        [newCallObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_SPEAKER];
        NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"mlbq" ofType:@"mp3"];      //创建音乐文件路径
        NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
        thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        //创建播放器
        [musicURL release];
        [thePlayer setVolume:1.0];   //设置音量大小
        thePlayer.numberOfLoops = -1;//设置音乐播放次数  -1为一直循环
        if([thePlayer prepareToPlay]&&![self isDeviceMuted])
        {
            [thePlayer play];
        }
        
        if ([self isBackground])
        {
            [self setCallIncomingFlag:YES];
            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:0] forKey:KEY_CALL_TYPE];
            [[NSUserDefaults standardUserDefaults]setObject:uri     forKey:KEY_CALLER];
            [[NSUserDefaults standardUserDefaults]setObject:self.groupName     forKey:KEY_GRP_NAME];
            makeNotification(@"接听",[NSString stringWithFormat:@"群组来电:%@",uri],UILocalNotificationDefaultSoundName,
                             YES);
            return EC_OK;
        }
        CCallingViewController* view1 = [[CCallingViewController alloc]init];
        view1.isCallOut = NO;

        if(grpType < 20)
            view1.isVideo = NO;
        else
            view1.isVideo = YES;
        isGroup = 1;//1 or 2

        if (view1.isVideo)
        {
            view1.isAutoRotate = isAutoRotationVideo;
        }
        
        view1.view.frame = self.view.frame;
        [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
        [self presentViewController:view1 animated:NO completion:nil];
        callingView = view1;
        callingView.mCallingNum.text=self.groupName;
        callingView.mCallingInfo.text=@"群组来电中...";
        [view1 release];
    }
    else
    {
        [self setLog:@"已接听"];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_GROUP_ACCEPT],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                [NSNumber numberWithLongLong:(long long)(remoteVideoView)],@"rvideo",
                                [NSNumber numberWithLongLong:(long long)(localVideoView)],@"lvideo",
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    }
    
    return EC_OK;
}
#endif

///////////////////////////////回调函数：用户在线状态查询结果//////////////////////////////////
-(int)onAccStatusQueryResponse:(NSDictionary*)result accObj:(AccObj*)accObj
{
    [_signalAccStatusQueryResponse lock];
    NSString* str = nil;
    CWLogDebug(@"result is %@onCall:%@",result,accObj);
    if (nil == result || nil == accObj)
    {
        [self setLog:@"查询请求失败-未知原因"];
        str = [NSString stringWithFormat:@"查询请求失败-未知原因"];
        NSDictionary* dic = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                               str, @"Response",
                               nil ];
        [_queueAccStatusQueryResponse addObject:dic];
        [_signalAccStatusQueryResponse signal];
        [_signalAccStatusQueryResponse unlock];
        return EC_PARAM_WRONG;
    }
    id obj = [result objectForKey:KEY_RESULT];
    if (nil == obj)
    {
        [self setLog:@"查询请求失败-丢失字段KEY_RESULT"];
        str = [NSString stringWithFormat:@"查询请求失败-丢失字段KEY_RESULT"];
        NSDictionary* dic = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                             str, @"Response",
                             nil ];
        [_queueAccStatusQueryResponse addObject:dic];
        [_signalAccStatusQueryResponse signal];
        [_signalAccStatusQueryResponse unlock];
        return EC_PARAM_WRONG;
    }
    int code = [obj intValue];
    if (0 == code)
    {
        int i = 0;
        while (TRUE)
        {
            int online = 0;
            NSString* sAccId = [mAccObj getUserStatus:result online:&online atIndex:i];
            if (nil != sAccId)
            {
                [self setLog:[NSString stringWithFormat:@"%@_%@",online?@"在线":@"离线",sAccId]];
                str = [NSString stringWithFormat:@"%@_%@",online?@"在线":@"离线",sAccId];
                i++;
            }
            else
            {
                break;
            }
            
        }
    }
    else
    {
        NSString* reason = [result objectForKey:KEY_REASON];
        [self setLog:[NSString stringWithFormat:@"查询失败:%d:%@",code,reason]];
        str = [NSString stringWithFormat:@"查询失败:%d:%@",code,reason];
    }
    NSDictionary* dic = [ [ NSDictionary alloc ] initWithObjectsAndKeys:
                         str, @"Response",
                         nil ];
    [_queueAccStatusQueryResponse addObject:dic];
    [_signalAccStatusQueryResponse signal];
    [_signalAccStatusQueryResponse unlock];
    return EC_OK;
    
}

/////////////////////////////////回调函数：注册结果回馈/////////////////////////////////////
-(int)onRegisterResponse:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    CWLogDebug(@"result is %@onCall:%@",result,accObj);
    [loginActivityIndicator stopAnimating]; // 结束旋转
    [btnItemLogin setEnabled:YES];
    mToken = [result objectForKey:KEY_CAPABILITYTOKEN];
    mAccountID = [result objectForKey:KEY_RTCACCOUNTID];
    isGettingToken = NO;
    if(mToken)
    {
        if ([mUsrID.text  isEqual: @""]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"名字不能为空" message:@"请输入名字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            
            [alertView show];
            [alertView release];
            
            return EC_PARAM_WRONG;
        }
        else
        {
            NSMutableDictionary *newResult = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
            [newResult setObject:mToken forKey:KEY_CAPABILITYTOKEN];
            [newResult setObject:mAccountID forKey:KEY_RTCACCOUNTID];
            if(changeVersion==2)
                [newResult setValue:[NSNumber numberWithDouble:2] forKey:KEY_ACC_SRTP];//若与浏览器互通则打开,should be double in arm64 
            [mAccObj doAccRegister:newResult];
        }
        return EC_OK;
    }
    if (nil == result || nil == accObj)
    {
        [self setLog:@"注册请求失败-未知原因"];
        return EC_PARAM_WRONG;
    }
    id obj = [result objectForKey:KEY_REG_EXPIRES];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_EXPIRES"];
        return EC_PARAM_WRONG;
    }
    int nExpire = [obj intValue];
    
    obj = [result objectForKey:KEY_REG_RSP_CODE];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_RSP_CODE"];
        return EC_PARAM_WRONG;
    }
    int nRspCode = [obj intValue];
    
    obj = [result objectForKey:KEY_REG_RSP_REASON];
    if (nil == obj)
    {
        [self setLog:@"注册请求失败-丢失字段KEY_REG_RSP_REASON"];
        return EC_PARAM_WRONG;
    }
    NSString* sReason = obj;
    
    if (nRspCode == 200)
    {
        [self setLog:[NSString stringWithFormat:@"登录成功,距下次注册%d秒",nExpire]];
        if(isFirstpage)
        {
            [self presentViewController:self.tabBarController animated:NO completion:nil];
            self.view.hidden = YES;
            isFirstpage = NO;
        }
        [self writeCurrentInfoToFile];
    }
    else
    {
        [self setLog:[NSString stringWithFormat:@"登录失败:%d:%@",nRspCode,sReason]];

            NSString * msg=[NSString stringWithFormat:@"%d", nRspCode];
            [self myAlertView:@"登录失败" msg:msg];
            
//            if (mAccObj)
//            {
//                [mAccObj doUnRegister];
//                [mAccObj release];
//                mAccObj = nil;
//                mToken = nil;
//                mAccountID = nil;
//                [self setLog:@"注销完毕"];
//                
//                if(mSDKObj)
//                {
//                    [mSDKObj release];
//                    mSDKObj = nil;
//                    mLogIndex = 0;
//                    [self setLog:@"release完毕"];
//                }
//            }
    }
    
    return EC_OK;
}

-(NSString*)getMemberStatus:(int)status
{
    NSString *str = @"";
    switch(status)
    {
        case 1:
        str =@"准备状态";//1:代表准备状态（主席正在振铃）
        break;
        case 2:
        str =@"已加入";//2
        break;
        case 3:
        str =@"未加入或已退出";//3:代表未加入或已退出
        break;
        case 4:
        str =@"被踢出";//4:代表被删除出
        break;
        case 5:
        str =@"振铃中";//5:代表振铃状态（成员振铃）
        break;
        default:
        str =@"未知";
        break;
    }
    return str;
}
/////////////////////////////////回调函数：反馈消息上报//////////////////////////////////////
-(int)onNotifyMessage:(NSDictionary*)result  accObj:(AccObj*)accObj
{
    CWLogDebug(@"%s result is %@onNotify:%@",__FUNCTION__,result,accObj);
    NSString* changeInfo = [result objectForKey:@"ChangedInfo"];//成员状态变化，@"callID"表示会话id,@"memberlist"表示成员列表
    NSString* connection = [result objectForKey:@"CheckConnection"];//成员异常掉线,@"ConfID"表示会话id
    NSString* kickedBy = [result objectForKey:@"kickedBy"];//同一账号不同设备登录被踢出
    NSString* multiLogin = [result objectForKey:@"multiLogin"];//多终端登录
    
    if(changeInfo)
    {
        NSArray *memberlist = [[result objectForKey:@"ChangedInfo"] objectForKey:@"memberlist"];
        //解析账号
        NSString *accID = [memberlist[0] objectForKey:KEY_GRP_ACCID];
        const char* cacc = [accID UTF8String];
        int strindex1=0,strindex2=0;
        int l = (int)strlen(cacc);
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='-')
            {
                strindex1=i;
                break;
            }
        }
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='~')
            {
                strindex2=i;
                break;
            }
        }
        accID = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
        
        int memberstatus = [[memberlist[0] objectForKey:KEY_GRP_MBSTATUS] intValue];
        NSString *micInfo = @"";
        
        if([memberlist[0] objectForKey:KEY_GRP_MBSTATUS])
        {
            [self myAlertView:[NSString stringWithFormat:@"账号%@:%@",accID,[self getMemberStatus:memberstatus]] msg:@""];
            
            if((memberstatus==3||memberstatus==4)&&(grpType==2)&&[accID isEqualToString:micOwner])
            {
                [btnGroupMic setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",@"call_video_nomic"]] forState:UIControlStateNormal];
                callingviewMic = YES;
                callingviewNoMic = NO;
                mGroupMic = NO;
            }
        }
        else if(grpType==1&&[memberlist[0] objectForKey:@"upAudioState"])
        {
            micInfo = [[memberlist[0] objectForKey:@"upAudioState"] intValue]==1?@"抢麦成功":@"释放了麦克";
            [self myAlertView:[NSString stringWithFormat:@"账号%@:%@",accID,micInfo] msg:@""];
        }
        else if(grpType==2&&[memberlist[0] objectForKey:@"upAudioState"])
        {
            micInfo = [[memberlist[0] objectForKey:@"upAudioState"] intValue]==1?@"获得发言权":@"发言权被收回";
            [self myAlertView:[NSString stringWithFormat:@"账号%@:%@",accID,micInfo] msg:@""];
            [micOwner release];
            micOwner=accID;
            [micOwner retain];
        }
    }
    else if(connection)
    {
        [self myAlertView:@"CheckConnection" msg:@""];
    }
    else if(kickedBy)
    {
        [self myAlertView:@"此账号已在其他设备登录" msg:@"您被踢下线，请重新登录"];
        [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
        self.view.hidden = NO;
        isFirstpage = YES;
    }
    else if(multiLogin)
    {
        [self myAlertView:@"此账号已在其他终端登录" msg:@""];
    }
    
    return EC_OK;
}

/////////////////////////////////回调函数：呼叫事件通知///////////////////////////////////////
-(int)onCallBack:(SDK_CALLBACK_TYPE)type code:(int)code callObj:(CallObj*)callObj
{
    [self setLog:[NSString stringWithFormat:@"呼叫事件:%d code:%d...",type,code]];
    if(type == SDK_CALLBACK_RING)
    {
        [self setLog:[NSString stringWithFormat:@"呼叫中%d...",code]];
    }
    else if (type == SDK_CALLBACK_ACCEPTED)
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        [callingView onCallOk:YES];
        [self setLog:[NSString stringWithFormat:@"呼叫被接听"]];
        [self setCallIncomingFlag:NO];
    }
    else if(type == SDK_CALLBACK_CLOSED)
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        [self setLog:[NSString stringWithFormat:@"通话被挂断"]];
        [callingView onCallOk:NO];
        [self closeCallingView];
        if (mCallObj)
        {
            //[mCallObj doHangupCall];
            [mCallObj release];
            mCallObj = nil;
        }
        
        cameraIndex = 1;
#if (SDK_HAS_GROUP>0)
        [callID release];
        callID = @"";
        [callID retain];
#endif
        [self setCallIncomingFlag:NO];
    }
    else if(type == SDK_CALLBACK_CANCELED)
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        NSString * msg=[NSString stringWithFormat:@"%d", code];
        [self myAlertView:@"来电已在其他设备接听" msg:msg];
        
        [self setLog:[NSString stringWithFormat:@"来电已在其他设备接听:%d",code]];
        [self closeCallingView];
        if (mCallObj)
        {
            //[mCallObj doHangupCall];
            [mCallObj release];
            mCallObj = nil;
        }
        
        [self setCallIncomingFlag:NO];
    }
    else if(type == SDK_CALLBACK_FAILED)
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        if(code!=487)
        {
            [callObj doSwitchAudioDevice:SDK_AUDIO_OUTPUT_DEFAULT];
            NSString * musicFilePath = [[NSBundle mainBundle] pathForResource:@"ringfailed" ofType:@"wav"];      //创建音乐文件路径
            NSURL * musicURL= [[NSURL alloc] initFileURLWithPath:musicFilePath];
            thePlayer  = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
            //创建播放器
            [musicURL release];
            [thePlayer setVolume:1.0];   //设置音量大小
            thePlayer.numberOfLoops = 0;//设置音乐播放次数  -1为一直循环  1为两次
            if([thePlayer prepareToPlay]&&![self isDeviceMuted])
            {
                [thePlayer play];
            }
        }
        
        NSString * msg=[NSString stringWithFormat:@"%d", code];
        [self myAlertView:@"连接失败" msg:msg];
        
        [self setLog:[NSString stringWithFormat:@"连接失败:%d",code]];
        [self closeCallingView];
        if (mCallObj)
        {
            //[mCallObj doHangupCall];
            [mCallObj release];
            mCallObj = nil;
        }
        
        [self setCallIncomingFlag:NO];
    }
    return 0;
}

/////////////////////////////////回调函数：呼叫媒体建立事件通知//////////////////////////////////
-(int)onCallMediaCreated:(int)mediaType callObj:(CallObj *)callObj
{
#if(SDK_HAS_GROUP>0)
    if(isGroup != 0 && grpType<20)//多人语音
    {
        [self setCallIncomingFlag:NO];
        return 0;
    }
#endif
    if (mediaType == MEDIA_TYPE_VIDEO)
    {
        int ret = [callObj doSetCallVideoWindow:remoteVideoView localVideoWindow:localVideoView];
        CWLogDebug(@"ret is %d",ret);
    }
    [self setCallIncomingFlag:NO];
    return 0;
}

/////////////////////////////////回调函数：呼叫网络状态事件通知//////////////////////////////////
-(int)onNetworkStatus:(NSString*)desc callObj:(CallObj*)callObj
{
    if (desc && callingView)
    {
        NSDictionary* dic = [desc objectFromJSONString];
        //int msg = [[dic objectForKey:@"msg"]intValue];
        //int codec = [[dic objectForKey:@"codec"]intValue];
        int w = [[dic objectForKey:@"w"]intValue];
        int h = [[dic objectForKey:@"h"]intValue];
//        int recvFrameRate = [[dic objectForKey:@"rf"]intValue];
//        int sendFrameRate = [[dic objectForKey:@"sf"]intValue];
        int sendBitrate = [[dic objectForKey:@"sb"]intValue];
        int recvBitrate = [[dic objectForKey:@"rb"]intValue];
        int rtt = [[dic objectForKey:@"lost"]intValue];
        
        if (w == 0 || h == 0 || sendBitrate == 0 || recvBitrate == 0 || rtt == 0)
            return 0;
        
        CWLogDebug(@"sb=%dkbps, rb=%dkbps, rtt=%dms,onCall:%@",sendBitrate/1000,recvBitrate/1000,rtt,callObj);
        int SB_LEVEL_1 = 99360;
        int SB_LEVEL_2 = 40360;
        int RTT_LEVEL_1 = 500;
        int RTT_LEVEL_2 = 1000;
        //显示5秒
        if(sendBitrate>SB_LEVEL_1 && rtt<RTT_LEVEL_1 && recvBitrate>SB_LEVEL_1)
        {
            [callingView setVideoStatus:[NSString stringWithFormat:@"发送速率:%dkbps, 接收速率:%dkbps, \nrtt:%dms",sendBitrate/1000,recvBitrate/1000,rtt] txtColor:[UIColor colorWithRed:0.0 green:240.0/255.0 blue:0.0 alpha:1]];
        }
        else if (sendBitrate>SB_LEVEL_2 && rtt<RTT_LEVEL_2 && recvBitrate>SB_LEVEL_2)
        {
            [callingView setVideoStatus:[NSString stringWithFormat:@"网络不稳定\n发送速率:%dkbps, 接收速率:%dkbps,\nrtt:%dms",sendBitrate/1000,recvBitrate/1000,rtt] txtColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:0.0 alpha:1]];
        }
        else if(recvBitrate<SB_LEVEL_2 && sendBitrate>SB_LEVEL_2)
        {
             [callingView setVideoStatus:[NSString stringWithFormat:@"对方网络很差，无法保证正常视频\n发送速率:%dkbps, 接收速率:%dkbps,\nrtt:%dms",sendBitrate/1000,recvBitrate/1000,rtt] txtColor:[UIColor colorWithRed:240.0/255.0 green:0.0 blue:0.0 alpha:1]];
        }
        else
        {
             [callingView setVideoStatus:[NSString stringWithFormat:@"网络很差，无法保证正常视频\n发送速率:%dkbps, 接收速率:%dkbps,\nrtt:%dms",sendBitrate/1000,recvBitrate/1000,rtt] txtColor:[UIColor colorWithRed:240.0/255.0 green:0.0 blue:0.0 alpha:1]];
        }
    }
    
    return 0;
}

///////////////////////////////////多人请求回调/////////////////////////////////
#if (SDK_HAS_GROUP>0)
-(int)onGroupResponse:(NSDictionary*)result grpObj:(CallObj*)grpObj
{
    CWLogDebug(@"%s result is %@onCall:%@",__FUNCTION__,result,grpObj);
    
    int code = [[result objectForKey:KEY_RESULT] intValue];
    if(micResponse&&code == 3011)
    {
        [self myAlertView:@"抢麦失败" msg:@"有人正在发言"];
    }
    else if(code == 3012)
    {
        if([thePlayer isPlaying])
        {
            [thePlayer stop];
            AudioSessionSetActive (false);
            [thePlayer release];
            thePlayer = nil;
        }
        
        [self myAlertView:@"会话创建失败" msg:@"成员已在其他会议中"];
        [self closeCallingView];
    }
    if(micResponse&&[[result objectForKey:KEY_REASON] isEqual:@"success"])
    {
        if(mGroupMic)//释麦操作2:设置图片为无麦状态
            [btnGroupMic setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",@"call_video_nomic"]] forState:UIControlStateNormal];
        else//抢麦操作2:设置图片为以拿到麦状态
        {
            [btnGroupMic setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",@"call_video_mic"]] forState:UIControlStateNormal];
        }
        mGroupMic = !mGroupMic;
        micResponse = NO;
    }
    if([result objectForKey:KEY_GRP_CALLID]!=nil&&[result objectForKey:KEY_GRP_CALLID]!=[NSNull null])
    {
        [callID release];
        callID = [result objectForKey:KEY_GRP_CALLID];
        [callID retain];
        CWLogDebug(@"callID in onGroupResponse is %@",callID);
    }
    
    NSArray *num = [result objectForKey:@"memberInfoList"];
    if(num)//查询列表触发
    {
        NSString *accID = nil,*accNum = nil,*list = nil;
        NSMutableArray* numArr = [NSMutableArray arrayWithObjects:self.groupName,nil];
        int first = 1;
        for(int i = 0; i < [num count]; i++)
        {
            accID = [num[i] objectForKey:KEY_GRP_ACCID];
            const char* cacc = [accID UTF8String];
            int strindex1=0,strindex2=0;
            int l = (int)strlen(cacc);
            for(int i = 0;i<l;i++)
            {
                if(cacc[i]=='-')
                {
                    strindex1=i;
                    break;
                }
            }
            for(int i = 0;i<l;i++)
            {
                if(cacc[i]=='~')
                {
                    strindex2=i;
                    break;
                }
            }
            accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
            [numArr addObject:accNum];
            
            if(![accNum isEqual:self.loginID]&&[[num[i] objectForKey:KEY_GRP_MBSTATUS] intValue] == 2)
            {
                if(first == 1)
                {
                    list = accNum;
                    first = 0;
                }
                else
                    list = [NSString stringWithFormat:@"%@,%@",list,accNum];
            }
        }
        [textfield setText:list];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"SaveToGroupListNotification"
         object:list];//踢出操作2，给麦操作2，获取列表操作2:成员列表发给contactlist
        
//        [[NSNotificationCenter defaultCenter]
//         postNotificationName:@"SaveToGroupMemberNotification"
//         object:accNum];//获取会议成员，触发来电保存
    }
    
    return EC_OK;
}

#endif

#pragma mark - LocalNotification delegates

#define CALL_INCOMING_FLAG  @"CALL_INCOMING_FLAG"
-(BOOL)isBackground
{
    return [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground
    ||[[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive;
}
-(void)setCallIncomingFlag:(BOOL)reg
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:reg] forKey:CALL_INCOMING_FLAG];
}
-(BOOL)getCallIncomingFlag
{
    id obj = [[NSUserDefaults standardUserDefaults]objectForKey:CALL_INCOMING_FLAG];
    if (obj)
    {
        return [obj boolValue];
    }
    return NO;
}

/////////////////////////////////后台接听/////////////////////////////////
- (void)onApplicationWillEnterForeground:(UIApplication *)application
{
    if (!mSDKObj || ![mSDKObj isInitOk] || !mAccObj || ![mAccObj isRegisted])
    {
        CWLogDebug(@"isGettingToken:%d",isGettingToken);
        if(!isGettingToken)
        {
            isGettingToken = YES;
            CWLogDebug(@"重新初始化rtc");
            [self doUnRegister];
            [self onSDKInit];
        }
        return;
    }
    if ([self getCallIncomingFlag])
    {
        [self setCallIncomingFlag:NO];
        int callType = [[[NSUserDefaults standardUserDefaults]objectForKey:KEY_CALL_TYPE]intValue];
        NSString* uri = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_CALLER];
        NSString* gvcName = nil;
#if(SDK_HAS_GROUP>0)
        gvcName = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_GRP_NAME];
#endif
        
        const char* cacc = [uri UTF8String];
        int strindex1=0,strindex2=0;
        int l = (int)strlen(cacc);
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='-')
            {
                strindex1=i;
                break;
            }
        }
        for(int i = 0;i<l;i++)
        {
            if(cacc[i]=='~')
            {
                strindex2=i;
                break;
            }
        }
        NSString* accNum = [[NSString stringWithUTF8String:cacc] substringWithRange:NSMakeRange(strindex1+1, strindex2-strindex1-1)];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)),dispatch_get_main_queue(),^{CCallingViewController* view1 = [[CCallingViewController alloc]init];
        view1.isVideo = !(callType == AUDIO || callType == AUDIO_RECV || callType == AUDIO_SEND);
        view1.isCallOut = NO;
#if(SDK_HAS_GROUP>0)
        if([gvcName isEqualToString:@""])//点对点
            isGroup = 0;
        else
        {
            isGroup = 1;
            if(grpType < 20)
                view1.isVideo = NO;
            else
                view1.isVideo = YES;
        }
#endif
        if (view1.isVideo)
        {
            view1.isAutoRotate = isAutoRotationVideo;
        }
        
        view1.view.frame = self.view.frame;
        [self.tabBarController dismissViewControllerAnimated:NO completion:nil];
        callingView = view1;
        
        if(callType!=0)
            callingView.mCallingNum.text=accNum;//点对点
        else
            callingView.mCallingNum.text=gvcName;//多人
#if(SDK_HAS_GROUP>0)
        if (isGroup!=0)
            callingView.mCallingInfo.text=@"群组来电中...";
        else
#endif
            if (view1.isVideo)
            callingView.mCallingInfo.text=@"视频来电中...";
        else
            callingView.mCallingInfo.text=@"语音来电中...";
        [self presentViewController:view1 animated:NO completion:nil];
        
        [view1 release];
            });
    }
}

//后台长连接
-(void)onAppEnterBackground
{
    if (!mSDKObj || ![mSDKObj isInitOk] || !mAccObj || ![mAccObj isRegisted])
    {
        CWLogDebug(@"isGettingToken:%d",isGettingToken);
        if(!isGettingToken)
        {
            isGettingToken = YES;
            CWLogDebug(@"重新初始化rtc");
            [self doUnRegister];
            [self onSDKInit];
        }
        return;
    }
    CWLogDebug(@"keepAliveBegin");
    [mSDKObj onAppEnterBackground];
}

//网络切换重连
-(void)onNetworkChanged:(BOOL)netstatus
{
    if(netstatus)
    {
        CWLogDebug(@"networkChanged to YES");
        if (!mSDKObj || ![mSDKObj isInitOk] || !mAccObj || ![mAccObj isRegisted])
        {
            CWLogDebug(@"isGettingToken:%d",isGettingToken);
            if(!isGettingToken)
            {
                isGettingToken = YES;
                CWLogDebug(@"重新初始化rtc");
                [self doUnRegister];
                [self onSDKInit];
            }
            return;
        }
        
        [mSDKObj onAppEnterBackground];//网络恢复
    }
    else
    {
        CWLogDebug(@"networkChanged to NO");
        [mSDKObj onNetworkChanged];//网络断开后销毁网络数据

        if(mCallObj)//通话被迫结束，销毁通话界面
        {
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_HANGUP],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        }
        [self myAlertView:@"网络不稳定" msg:@"503"];
    }
}

-(BOOL)accObjIsRegisted
{
    if (mAccObj && [mAccObj isRegisted])
        return  YES;
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

@end
