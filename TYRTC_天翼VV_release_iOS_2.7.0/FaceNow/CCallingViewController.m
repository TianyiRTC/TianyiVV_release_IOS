#import "CCallingViewController.h"
#import "DAPIPView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <AVFoundation/AVCaptureSession.h>
#import <CoreMotion/CoreMotion.h>


#if(SDK_HAS_GROUP>0)
int isGroupCreator=0;//0为普通成员，1为创建者
SDK_GROUP_TYPE grpType=SDK_GROUP_CHAT_AUDIO;
int isGroup=0;//0表示点对点,1表示主动发起多人,2表示主动参加多人
UITextField *textfield;
BOOL micResponse=NO;
BOOL mGroupMic=NO;//YES 未静音;NO 已静音
UIButton* btnGroupMic;
NSString *micName = @"";
extern BOOL callingviewInvite;
extern BOOL callingviewKick;
extern BOOL callingviewMic;
extern BOOL callingviewNoMic;
extern BOOL callingviewList;
#define addAlertViewTag 1
#define deleteAlertViewTag 2
#define micAlertViewTag 3
#define noMicAlertViewTag 4
#endif
@interface CCallingViewController ()
{
    int mRotate;
    CMMotionManager *mMotionManager;
    int mLogIndex;
    BOOL mMuteState;//NO 未静音;YES 已静音
    BOOL mSpeakerState;//NO 听筒;YES 扬声
    NSTimer* mCallDurationTimer;
}
@property (strong, nonatomic) DAPIPView *dapiview;
@property (strong, nonatomic) UIButton* btnDTMF;
@property (strong, nonatomic) UIButton* btnMute;
@property (strong, nonatomic) UIButton* btnSpeaker;
@property (strong, nonatomic) UIButton* btnSwitchCamera;
@property (strong, nonatomic) UIButton* btnStartRecord;
@property (strong, nonatomic) UIButton* btnHideLocalVideo;
@property (strong, nonatomic) UIButton* btnRemoteVideoRotate;
@property (strong, nonatomic) UIButton* btnSnapRemote;
@property (strong, nonatomic) UIButton* btnSnapLocal;
@property (strong, nonatomic) UITextField*           mStatus;
@property (strong, nonatomic) UILabel*           mVideoStatus;
@property (strong, nonatomic) UILabel*           mDuration;
#if(SDK_HAS_GROUP>0)
@property (strong, nonatomic) UIButton* btnGroupList;
@property (strong, nonatomic) UIButton* btnGroupInvite;
@property (strong, nonatomic) UIButton* btnGroupKick;
@property (strong, nonatomic) UIButton* btnGroupClose;
@property (strong, nonatomic) UIButton* btnGroupUnMic;
@property (strong, nonatomic) UIButton* btnGroupDisplay;
#endif
@property (strong, nonatomic) UILabel*  lblCallStatus;
@end

@implementation CCallingViewController
@synthesize localVideoView = _localVideoView;
@synthesize dapiview = _dapiview;
@synthesize remoteVideoView = _remoteVideoView;
@synthesize isCallOut;
@synthesize isVideo;
@synthesize isAutoRotate;
@synthesize isRecording;
@synthesize btnHangup,btnAccept,btnReject,btnDTMF,btnMute,btnSpeaker,lblCallStatus,mStatus,mVideoStatus,mDuration;
@synthesize btnSwitchCamera,btnHideLocalVideo,btnRemoteVideoRotate,btnSnapRemote,btnSnapLocal,btnStartRecord,mCallingInfo,mCallingNum;
@synthesize loginImageView,callingImageView;
#if(SDK_HAS_GROUP>0)
@synthesize btnGroupList,btnGroupInvite,btnGroupKick,btnGroupClose,btnGroupUnMic,btnGroupDisplay;
@synthesize mUser3;
@synthesize contactlistViewController = _contactlistViewController;
#endif

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

-(UIButton*)addGridBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
    [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItem setTitle:title forState:UIControlStateNormal];
    [btnItem setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.view addSubview:btnItem];
    
    return btnItem;
}

-(UIButton*)addImageBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIImage *image1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_n.png",title]];
    //UIImage *image2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",title]];
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
   //[btnItem setShowsTouchWhenHighlighted:YES];
   [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
   [btnItem setBackgroundImage:image1 forState:UIControlStateNormal];
   //[btnItem setBackgroundImage:image2 forState:UIControlStateSelected];
   [btnItem.layer setMasksToBounds:YES];
   [btnItem.layer setCornerRadius:10.0];
   [self.view addSubview:btnItem];
   
   return btnItem;
}

-(UIButton*)addImageBtn2:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIImage *image1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",title]];
    //UIImage *image2 = [UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",title]];
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
    //[btnItem setShowsTouchWhenHighlighted:YES];
    [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItem setBackgroundImage:image1 forState:UIControlStateNormal];
    //[btnItem setBackgroundImage:image2 forState:UIControlStateSelected];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.view addSubview:btnItem];
    
    return btnItem;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = [[UIView alloc]initWithFrame:CGRectMake(0.0, IOS7_STATUSBAR_DELTA, SCREEN_WIDTH, SCREEN_HEIGHT)];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.view setBackgroundColor:image1];
    self.view.tag = CALLINGVIEW_TAG;
    int height = 30;
    int width = 60;
    int sep = 20;
    int x = 10;
    int y = 30;
    UITextField* tfItem;
    
    isRecording = NO;

    DAPIPView* dvItem;
    if(isGroup==1&&grpType==29&&isGroupCreator==1)
    {
        dvItem = [[DAPIPView alloc] init:300*(int)SCREEN_WIDTH/320];
    }
    else
    {
        dvItem = [[DAPIPView alloc] init:100*(int)SCREEN_WIDTH/320];
    }
    self.dapiview = dvItem;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.dapiview.borderInsets = UIEdgeInsetsMake(1.0f,       // top
                                                      1.0f,       // left
                                                      45.0f,      // bottom
                                                      1.0f);      // right
    }
    else
    {
        self.dapiview.borderInsets = UIEdgeInsetsMake(1.0f,       // top
                                                      1.0f,       // left
                                                      (SCREEN_WIDTH/3-20/3)/2.2,       // bottom
                                                      1.0f);      // right
    }
    
    
    IOSDisplay* ivItem = [[IOSDisplay alloc]initWithFrame:self.view.bounds];
    if(isGroup==1&&grpType==29&&isGroupCreator==1)
        self.remoteVideoView = nil;
    else
        self.remoteVideoView = ivItem;
    [self.view addSubview:ivItem];
    [ivItem release];
    
    UIView* vItem = [[UIView alloc]initWithFrame:self.dapiview.bounds];
    vItem.backgroundColor = [UIColor blackColor];
    self.localVideoView = vItem;
    [self.dapiview addSubview:vItem];
    [vItem release];
    [self.view addSubview:dvItem];
    [dvItem release];
    
    UILabel* lblItem = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 320, 90)];
    lblItem.numberOfLines = 0;
    [self.view addSubview:lblItem];
    self.mVideoStatus = lblItem;
    [lblItem release];
    
    lblItem = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 320, 30)];
    [self.view addSubview:lblItem];
    self.mDuration = lblItem;
    [lblItem release];
    
    loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2*SCREEN_WIDTH/5-60, SCREEN_HEIGHT/4+10, 50, 50)];
    NSString* imageName =   [NSString stringWithFormat:@"call_video_default_avatar.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    loginImageView.layer.contents = (id) image.CGImage;
    [self.view addSubview:loginImageView];
    
    CGRect lblItemFrame = CGRectMake(2*SCREEN_WIDTH/5, SCREEN_HEIGHT/4+10, 150, 60);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [self.view addSubview:lblItem];
    self.mCallingNum = lblItem;
    [lblItem release];
    
    callingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2*SCREEN_WIDTH/5-40, SCREEN_HEIGHT/4+70, 30, 30)];
    imageName =   [NSString stringWithFormat:@"call_type_audio.png"];
    image = [UIImage imageNamed:imageName];
    callingImageView.layer.contents = (id) image.CGImage;
    [self.view addSubview:callingImageView];
    
    lblItemFrame = CGRectMake(2*SCREEN_WIDTH/5, SCREEN_HEIGHT/4+70, 170, 30);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [self.view addSubview:lblItem];
    self.mCallingInfo = lblItem;
    [lblItem release];
#if(SDK_HAS_GROUP>0)
    CGRect tfItemFrame;
    CGFloat lblWidth = 80;
    CGFloat lblSep = -100;

    tfItemFrame.origin.y += sep + height;
    tfItemFrame = CGRectMake(x + lblWidth+lblSep+15, SCREEN_HEIGHT/4+130, SCREEN_WIDTH-x-lblWidth-lblSep-15, height);

    tfItem = [[UITextField alloc]initWithFrame:tfItemFrame];
    tfItem.placeholder = @"远端账号";
    tfItem.textAlignment = NSTextAlignmentLeft;
    tfItem.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:tfItem];
    mUser3 = tfItem;
    [tfItem release];
    [mUser3  setHidden:YES];
#endif
    y += height+ sep*1.5;
    CGFloat xSep = 5;
    int totalIndex = 0;
    
    CGRect rect;
    CGPoint start = CGPointMake(SCREEN_WIDTH-200, 20);
    CGSize size = CGSizeMake(45, 40);
    CGPoint start2 = CGPointMake(SCREEN_WIDTH-180, 20);
    CGSize size2 = CGSizeMake(width, height);

#if(SDK_HAS_GROUP>0)
    rect = [self calcBtnRect:start index:totalIndex size:size linSep:sep colSep:xSep];
    totalIndex++;
    self.btnGroupInvite = [self addImageBtn2:@"list_item_add"   func:@selector(onAddInvite:)rect:rect];
    
    totalIndex--;
#endif
    
    rect = [self calcBtnRect:start2 index:totalIndex size:size linSep:sep colSep:10];
    totalIndex++;
    self.btnSwitchCamera = [self addImageBtn:@"convert_window"   func:@selector(onBtnSwapCamera:) rect:rect];
    
#if(SDK_HAS_GROUP>0)
    rect = [self calcBtnRect:start index:totalIndex size:size linSep:sep colSep:xSep];
    totalIndex++;
    self.btnGroupKick = [self addImageBtn2:@"list_item_delete"     func:@selector(onDeleteKick:)          rect:rect];
    
    totalIndex--;
#endif
    
    rect = [self calcBtnRect:start2 index:totalIndex size:size linSep:sep colSep:10];
    totalIndex++;
    self.btnHideLocalVideo = [self addImageBtn:@"fill_window"   func:@selector(onLocalVideoShow:)rect:rect];
    
#if(SDK_HAS_GROUP>0)
    rect = [self calcBtnRect:start index:totalIndex size:size linSep:sep colSep:xSep];
    totalIndex++;
    btnGroupMic = [self addImageBtn2:@"call_video_nomic"   func:@selector(onBtnGroupMic:) rect:rect];
    
    totalIndex--;
#endif
    
    rect = [self calcBtnRect:start2 index:totalIndex size:size linSep:sep colSep:10];
    totalIndex++;
    self.btnSnapRemote = [self addImageBtn:@"capture_window"     func:@selector(onSnap:)          rect:rect];
    
#if(SDK_HAS_GROUP>0)
    rect = [self calcBtnRect:start index:totalIndex size:size linSep:sep colSep:xSep];
    totalIndex++;
    self.btnGroupList = [self addImageBtn2:@"tab_contact"     func:@selector(onGetGroupList:)          rect:rect];
#endif
    
    totalIndex++;
    
    rect = CGRectMake(0, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)*0.9, SCREEN_WIDTH/3-20/3, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnStartRecord = [self addGridBtn:@"REC"  func:@selector(onBtnStartRecord:) rect:rect];
    [self.btnStartRecord setTitle:@"REC" forState:UIControlStateNormal];
    
    rect = CGRectMake(SCREEN_WIDTH/3-20/3+10, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)*0.9, SCREEN_WIDTH/3-20/3-10, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnRemoteVideoRotate = [self addGridBtn:@"ROTATE"  func:@selector(onRotateRemote:) rect:rect];
    [self.btnRemoteVideoRotate setTitle:@"ROTATE" forState:UIControlStateNormal];
    
    rect = CGRectMake(0, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)/2.3, SCREEN_WIDTH/3-20/3, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnMute = [self addImageBtn:@"mute"     func:@selector(onMuteMic:)       rect:rect];
    
    rect = CGRectMake(SCREEN_WIDTH/3-20/3+10, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)/2.3, SCREEN_WIDTH/3-20/3, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnHangup = [self addImageBtn:@"exit"     func:@selector(onBtnExit:)       rect:rect];
    
    rect = CGRectMake(SCREEN_WIDTH*2/3-40/3+20, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)/2.3, SCREEN_WIDTH/3-20/3, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnSpeaker = [self addImageBtn:@"speak"    func:@selector(onSpeakerSwitch:) rect:rect];
    
    totalIndex = 0;
    
    rect = CGRectMake(0, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)/2.3, SCREEN_WIDTH/2-5, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnAccept = [self addImageBtn:@"accept"   func:@selector(onBtnAccept:)     rect:rect];
    
    rect = CGRectMake(SCREEN_WIDTH/2+5, SCREEN_HEIGHT-(SCREEN_WIDTH/3-20/3)/2.3, SCREEN_WIDTH/2-5, (SCREEN_WIDTH/3-20/3)/2.3);
    totalIndex++;
    self.btnReject = [self addImageBtn:@"reject"   func:@selector(onBtnReject:)     rect:rect];

#if(SDK_HAS_GROUP>0)
    totalIndex = 16;
    
    rect = [self calcBtnRect:start2 index:totalIndex size:size2 linSep:sep colSep:xSep];
    totalIndex++;
    self.btnGroupClose = [self addGridBtn:@"关闭"     func:@selector(onBtnGroupClose:)       rect:rect];
    
    [btnGroupList setHidden:YES];
    [btnGroupInvite setHidden:YES];
    [btnGroupKick setHidden:YES];
    [btnGroupClose setHidden:YES];
    [btnGroupMic setHidden:YES];
    [btnGroupUnMic setHidden:YES];
    [btnGroupDisplay setHidden:YES];
#endif
    
    [btnHideLocalVideo setHidden:YES];
    [btnSwitchCamera setHidden:YES];
    [btnStartRecord setHidden:YES];
    [btnSnapRemote setHidden:YES];
    [btnRemoteVideoRotate setHidden:YES];
    [btnSnapLocal setHidden:YES];
    [btnMute setHidden:YES];
    [btnSpeaker setHidden:YES];
    [btnDTMF setHidden:YES];
    [mVideoStatus setHidden:YES];
    [mDuration setHidden:YES];
    [mCallingInfo setHidden:NO];
    [mCallingNum setHidden:NO];
    
    if (isCallOut)
    {
        [btnAccept setHidden:YES];
        [btnReject setHidden:YES];
    }
    else
    {
        [btnHangup setHidden:YES];
    }
    
    [self.dapiview setHidden:YES];

    mRotate = 0;
    mMotionManager = [[CMMotionManager alloc]init];
    mLogIndex = 0;
    mMuteState = NO;
    mSpeakerState = NO;
    mGroupMic = NO;
    
    [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    [tapGr release];

    [self performSelector:@selector(onSendVideoParam) withObject:nil afterDelay:0.1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupInviteNotification:)
                                                 name:@"GroupInviteNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupKickNotification:)
                                                 name:@"GroupKickNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupMicNotification:)
                                                 name:@"GroupMicNotification"
                                               object:nil];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr
{
    [mStatus resignFirstResponder];
#if(SDK_HAS_GROUP>0)
    [mUser3 resignFirstResponder];
#endif
}

- (void)viewDidDisappear:(BOOL)animated
{
    if ([mCallDurationTimer isValid])
    {
        [mCallDurationTimer invalidate];
        mCallDurationTimer = nil;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    mCallDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onUpdateCallDuration:) userInfo:nil repeats:YES];
}

-(void)onUpdateCallDuration:(NSTimer*)timer
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_UPDATE_CALLDURATION],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)setCallDuration:(unsigned int)callDuration  withCPU:(float)cpuUseage withMem:(float)memUse
{
    int sec = callDuration%60;
    int temp = callDuration/60;
    int min = temp%60;
    temp = temp/60;
    int hour = temp%60;
    mDuration.text = [NSString stringWithFormat:@"时长:%02d:%02d:%02d",hour,min,sec];
}

-(void)onCallOk:(BOOL)callOK
{
    if(callOK)
    {
        [btnMute setHidden:NO];
        [btnSpeaker setHidden:NO];
        [btnDTMF setHidden:NO];
        [mVideoStatus setHidden:NO];
        [mDuration setHidden:NO];
        if (isVideo)
        {
            if(isGroup==0)
            {
                [self.dapiview setHidden:NO];
                [btnHideLocalVideo setHidden:NO];
                [btnSwitchCamera setHidden:NO];
                [btnStartRecord setHidden:NO];
                [btnSnapRemote setHidden:NO];
                [btnRemoteVideoRotate setHidden:NO];
            }
            if (isAutoRotate)
            {
                [self setLog:[NSString stringWithFormat:@"自动旋转适配:%@",isAutoRotate?@"开启":@"关闭"]];
                [self setMotionStatus:YES];
                isAutoRotate = !isAutoRotate;
            }
            [mCallingInfo setHidden:YES];
            [mCallingNum setHidden:YES];
            [loginImageView setHidden:YES];
            [callingImageView setHidden:YES];
        }
        else
        {
            [btnHideLocalVideo setHidden:YES];
            [btnSwitchCamera setHidden:YES];
            [btnStartRecord setHidden:YES];
            self.mCallingInfo.text=@"语音通话中";
        }
    #if(SDK_HAS_GROUP>0)
        if(isGroupCreator==1)
        {
            [btnGroupInvite setHidden:NO];
            [btnGroupKick setHidden:NO];
        }
        if(isGroup!=0/*&&grpType<20*/)
        {
            if(isGroup==1&&grpType==29&&isGroupCreator==1)
                [self.dapiview setHidden:NO];
            
            [btnGroupList setHidden:NO];
            [btnGroupDisplay setHidden:NO];
            if(grpType==1||grpType==21)
            {
                [btnGroupMic setHidden:NO];
                [btnGroupUnMic setHidden:NO];
            }
            else if(isGroupCreator&&(grpType==2||grpType==22))
            {
                [btnGroupMic setHidden:NO];
                [btnGroupUnMic setHidden:NO];
            }
            else
            {
                [btnGroupMic setHidden:YES];
                [btnGroupUnMic setHidden:YES];
            }
            if(grpType==0||grpType==20)
                self.mCallingInfo.text=@"聊天室会话中";
            else if(grpType==1||grpType==21)
                self.mCallingInfo.text=@"群对讲会话中";
            else if(grpType==2||grpType==22)
                self.mCallingInfo.text=@"VV秀场会话中";
            else if(grpType==9||grpType==29)
                self.mCallingInfo.text=@"现场直播会话中";
        }
        else
        {
            [mUser3  setHidden:YES];
            [btnGroupList setHidden:YES];
            [btnGroupInvite setHidden:YES];
            [btnGroupKick setHidden:YES];
            [btnGroupClose setHidden:YES];
            [btnGroupMic setHidden:YES];
            [btnGroupUnMic setHidden:YES];
            [btnGroupDisplay setHidden:YES];
        }
    #endif
    }
    else
        [self setMotionStatus:NO];
}

-(void)dealloc
{
    CWLogDebug(@"dealloc CCallingViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.localVideoView release];
    self.localVideoView = nil;
    [self.remoteVideoView release];
    self.remoteVideoView = nil;
    [self.dapiview release];
    self.loginImageView = nil;
    self.callingImageView = nil;
    
    [self.btnDTMF release];
    [self.btnMute release];
    [self.btnSpeaker release];
    [self.btnSwitchCamera release];
    [self.btnStartRecord release];
    [self.btnHideLocalVideo release];
    [self.btnRemoteVideoRotate release];
    [self.btnSnapRemote release];
    [self.btnSnapLocal release];
#if(SDK_HAS_GROUP>0)
    [self.btnGroupList release];
    [self.btnGroupInvite release];
    [self.btnGroupKick release];
    [self.btnGroupClose release];
    [btnGroupMic release];
    [self.btnGroupUnMic release];
    [self.btnGroupDisplay release];
#endif
    [self.mStatus release];
    [self.mVideoStatus release];
    [self.mDuration release];
    [self.mCallingInfo release];
    [self.mCallingNum release];
    [self.btnAccept release];
    [self.btnReject release];
    [self.btnHangup release];
    [self.lblCallStatus release];
    
    [mMotionManager stopDeviceMotionUpdates];
    [mMotionManager release];
    [super dealloc];
}

/**************************************控件响应*****************************************/
//挂断
-(IBAction)onBtnExit:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_HANGUP],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

#if (SDK_HAS_GROUP>0)
//关闭多人会话
-(IBAction)onBtnGroupClose:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_CLOSE],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)onGroupInviteNotification:(NSNotification *) notification
{
    NSString* remoteUri2 = mUser3.text;//账号之间用逗号隔开
    if ([[notification name] isEqualToString:@"GroupInviteNotification"]) {
        NSString *nums = [notification object];
        remoteUri2 = nums;
    }
    //邀请操作4:接收消息触发邀请接口
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_INVITE],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            remoteUri2,KEY_GRP_INVITEDMBLIST,
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)onGroupKickNotification:(NSNotification *) notification
{
    NSString* remoteUri2 = mUser3.text;//账号之间用逗号隔开
    if ([[notification name] isEqualToString:@"GroupKickNotification"]) {
        NSString *nums = [notification object];
        remoteUri2 = nums;
    }
    //踢出操作7:接收消息触发踢出操作
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_KICK],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            remoteUri2,KEY_GRP_KICKEDMBLIST,
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)onGroupMicNotification:(NSNotification *) notification
{
    NSString* remoteUri2 = mUser3.text;//账号之间用逗号隔开
    if ([[notification name] isEqualToString:@"GroupMicNotification"]) {
        NSString *nums = [notification object];
        remoteUri2 = nums;
    }
    
    if(mGroupMic)//收麦操作7:收到消息触发收麦接口
    {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_GROUP_MUTE],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                remoteUri2,KEY_GRP_MEMBER,
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        micResponse = YES;
    }
    else//给麦操作7:收到消息触发给麦接口
    {
        micName = remoteUri2;//收麦操作1:保存给麦账号
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_GROUP_UNMUTE],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                remoteUri2,KEY_GRP_MEMBER,
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        micResponse = YES;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == addAlertViewTag) {
        if (buttonIndex == 1)
        {
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            NSString* remoteUri2 = textfield.text;//账号之间用逗号隔开
            
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_INVITE],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_INVITEDMBLIST,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        }
    }
    else if (alertView.tag == deleteAlertViewTag) {
        if (buttonIndex == 1)
        {
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            NSString* remoteUri2 = textfield.text;//账号之间用逗号隔开
            
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_KICK],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_KICKEDMBLIST,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        }
    }
    else if (alertView.tag == micAlertViewTag) {
        if (buttonIndex == 1)
        {
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            NSString* remoteUri2 = textfield.text;//账号之间用逗号隔开
            
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_UNMUTE],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_MEMBER,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
            micResponse = YES;
        }
    }
    else if (alertView.tag == noMicAlertViewTag) {
        if (buttonIndex == 1)
        {
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            NSString* remoteUri2 = textfield.text;//账号之间用逗号隔开
            
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_MUTE],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_MEMBER,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
            micResponse = YES;
        }
    }
}

-(IBAction)onAddInvite:(id)sender
{
    callingviewInvite = YES;
    //邀请操作1：显示cantactlist
    ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
    self.contactlistViewController = view1;
    [self presentViewController:self.contactlistViewController animated:NO completion:nil];
    [view1 release];
}

-(IBAction)onDeleteKick:(id)sender
{
    //踢出操作1:获取成员列表
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_LIST],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    
    callingviewKick = YES;
    //踢出操作3:显示contactlist
    ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
    self.contactlistViewController = view1;
    [self presentViewController:self.contactlistViewController animated:NO completion:nil];
    [view1 release];
}

-(IBAction)onGetGroupList:(id)sender
{
    //获取列表操作1:获取成员列表
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_LIST],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    
    callingviewList = YES;
    //获取列表操作3:显示contactlist
    ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
    self.contactlistViewController = view1;
    [self presentViewController:self.contactlistViewController animated:NO completion:nil];
    [view1 release];
}

//给麦
-(IBAction)onBtnGroupMic:(id)sender
{
    if(grpType==1||grpType==21)
    {
        NSString* remoteUri2 = @"myself";//操作自己
        if(mGroupMic)//释麦操作1:mGroupMic为是触发释麦接口
        {
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_MUTE],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_MEMBER,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        }
        else//抢麦操作1:mGroupMic为否触发抢麦接口
        {
            NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                    [NSNumber numberWithInt:MSG_GROUP_UNMUTE],@"msgid",
                                    [NSNumber numberWithInt:0],@"arg",
                                    remoteUri2,KEY_GRP_MEMBER,
                                    nil];
            [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        }
        micResponse=YES;//由抢麦触发onresponse
    }
    else if((grpType==2||grpType==22)&&!mGroupMic)//给麦操作1:mGroupMic为否获取成员列表
    {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_GROUP_LIST],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        
        callingviewMic = YES;
        //给麦操作3:显示contactlist
        ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
        self.contactlistViewController = view1;
        [self presentViewController:self.contactlistViewController animated:NO completion:nil];
        [view1 release];
    }
    else if((grpType==2||grpType==22)&&mGroupMic)//收麦操作2：显示contactlist
    {
        callingviewNoMic = YES;
        
        ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
        self.contactlistViewController = view1;
        [self presentViewController:self.contactlistViewController animated:NO completion:nil];
        [view1 release];
        //收麦操作3:向contactlist发要收麦的账号
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupNoMicNotification"
         object:micName];
    }
}

//分屏
-(IBAction)onBtnGroupDisplay:(id)sender
{
    NSString* remoteUri2 = mUser3.text;
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_GROUP_DISPLAY],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            remoteUri2,KEY_GRP_MEMBER,
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}
#endif

//切换摄像头
-(IBAction)onBtnSwapCamera:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_SET_VIDEO_DEVICE],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [self setLog:@"摄像头切换"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

//录制视频
-(IBAction)onBtnStartRecord:(id)sender
{
    if (isRecording == NO) {
        [self.btnStartRecord setTitle:@"STOP" forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isRecording = YES;
        [self setLog:@"开始录制"];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_START_RECORDING],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                nil];
        
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        });

    } else {
        [self.btnStartRecord setTitle:@"REC" forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        isRecording = NO;
        [self setLog:@"停止录制"];
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_STOP_RECORDING],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                nil];
        
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
        });
    }
}

//隐藏视频
-(IBAction)onLocalVideoShow:(id)sender
{  
    int val = 0;
    if (self.dapiview.hidden)
    {
        val = DO_SHOW_LOCAL_VIDEO;
    }
    else
    {
        val = DO_HIDE_LOCAL_VIDEO;
    }
    [self.dapiview setHidden:!self.dapiview.hidden];
    [self setLog:[NSString stringWithFormat:@"本地视频隐藏:%@",self.dapiview.hidden?@"开启":@"关闭"]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_HIDE_LOCAL_VIDEO],@"msgid",
                            [NSNumber numberWithInt:val],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

//截取视频
-(IBAction)onSnap:(id)sender
{
    [self setLog:@"远端视频截屏"];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_SNAP],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)onSendVideoParam
{
    long long rVideo = 0;
    long long  lVideo = 0;
    
    if (isVideo)
    {
        rVideo = (long long)(self.remoteVideoView);
        lVideo = (long long)(self.localVideoView);
    }
#if(SDK_HAS_GROUP>0)
    int myCallGroup = 0;
    if(isGroup == 0)//点对点
        myCallGroup = MSG_NEED_VIDEO;
    else if(isGroup == 1)//发起多人
        myCallGroup = MSG_GROUP_CREATE;
    else if(isGroup == 2)//加入多人
        myCallGroup = MSG_GROUP_JOIN;
#endif
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
#if(SDK_HAS_GROUP>0)
                            [NSNumber numberWithInt:isGroup],@"isGroup",
                            [NSNumber numberWithInt:myCallGroup],@"msgid",
#else
                            [NSNumber numberWithInt:MSG_NEED_VIDEO],@"msgid",
#endif
                            [NSNumber numberWithInt:0],@"arg",
                            [NSNumber numberWithLongLong:rVideo],@"rvideo",
                            [NSNumber numberWithLongLong:lVideo],@"lvideo",
                            [NSNumber numberWithBool:self.isCallOut],@"iscallout",
                            nil];
    
    CWLogDebug(@"send param is %@",params);
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

//拒接
-(void)onBtnReject:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_REJECT],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    CWLogDebug(@"param is %@",params);
    
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

//接听
-(void)onBtnAccept:(id)sender
{
    [self setLog:@"已接听"];
    [btnHangup setHidden:NO];
    [btnAccept setHidden:YES];
    [btnReject setHidden:YES];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_ACCEPT],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            [NSNumber numberWithLongLong:(long long)(self.remoteVideoView)],@"rvideo",
                            [NSNumber numberWithLongLong:(long long)(self.localVideoView)],@"lvideo",
                            nil];

    CWLogDebug(@"param is %@",params);
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

//静音
- (IBAction)onMuteMic:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_MUTE],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    CWLogDebug(@"param is %@",params);
    [self setLog:mMuteState?@"解除静音":@"静音"];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    mMuteState = !mMuteState;
    
    if(mMuteState)
    [self.btnMute setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",@"mute"]] forState:UIControlStateNormal];
    else
    [self.btnMute setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_n.png",@"mute"]] forState:UIControlStateNormal];
}

//切换摄像头
- (IBAction)onSpeakerSwitch:(id)sender
{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_SET_AUDIO_DEVICE],@"msgid",
                            [NSNumber numberWithInt:!mSpeakerState],@"arg",
                            nil];
    CWLogDebug(@"param is %@",params);
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
    mSpeakerState = !mSpeakerState;
    
    if(mSpeakerState)
    [self.btnSpeaker setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_p.png",@"speak"]] forState:UIControlStateNormal];
    else
    [self.btnSpeaker setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_n.png",@"speak"]] forState:UIControlStateNormal];
}

//旋转摄像头
-(IBAction)onRotateRemote:(id)sender
{
    mRotate += 1;
    if (mRotate > SDK_VIDEO_ROTATE_270)
        mRotate = SDK_VIDEO_ROTATE_0;
    [self setLog:[NSString stringWithFormat:@"旋转摄像头:%d",mRotate]];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_ROTATE_REMOTE_VIDEO],@"msgid",
                            [NSNumber numberWithInt:mRotate],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"NOTIFY_EVENT" object:nil userInfo:params];
}

-(void)setCallStatus:(NSString*)log
{
    [self setLog:log];
}

-(void)performDismiss:(NSTimer *)timer
{
    UILabel  *alter = [timer userInfo];
    if(alter)
    {
        if(![alter isHidden])
            [alter setHidden:YES];
    }
}

-(void)setVideoStatus:(NSString*)log txtColor:(UIColor*)color
{
    [mVideoStatus setText:log];
    [mVideoStatus setTextColor:color];
    [mVideoStatus setHidden:NO];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(performDismiss:) userInfo:mVideoStatus repeats:NO];
}

+(NSInteger)calcRotation:(double)xy z:(double)z
{
    if ((z >= 45 && z <= 135) || (z >= -135 && z <= -45))//处于正向水平,反向水平位置,此时可作为竖直方向
    {
        return 0;
    }
    if (xy <= 180 && xy > 135)//竖直方向,向右侧倾斜,但未到角度
    {
        return 0;
    }
    if (xy <= 135 && xy >= 90)//竖直方向,向右倾斜,已经到位
    {
        return 90;
    }
    if (xy < 90 && xy >= 45) //斜向下方向,尚未到位
    {
        return 90;
    }
    if (xy < 45 && xy >= 0)//头朝下,已到位
    {
        return 180;
    }
    if (xy < 0 && xy >= -45)//头朝下,未到位
    {
        return 180;
    }
    if (xy < -45 && xy >= -90)//头朝下,已到位
    {
        return 270;
    }
    if (xy < -90 && xy >= -135)//头朝下,未到位
    {
        return 270;
    }
    if (xy < -135 && xy >= -180)//头朝上,偏左,已到位
    {
        return 0;
    }
    return 0;
}

-(void)setMotionStatus:(BOOL)doStart
{
    if (doStart)
    {
        [mMotionManager startDeviceMotionUpdatesToQueue:[[[NSOperationQueue alloc] init] autorelease]
                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                                                    double gravityX = motion.gravity.x;
                                                    double gravityY = motion.gravity.y;
                                                    double gravityZ = motion.gravity.z;
                                                    double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;
                                                    double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;
                                                    NSInteger rotation = [CCallingViewController calcRotation:xyTheta z:zTheta];
                                                    [[NSNotificationCenter defaultCenter]postNotificationName:@"MOTIONCHECK_NOTIFY"
                                                                                                       object:nil
                                                                                                     userInfo:
                                                     [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInteger:rotation],@"rotation",
                                                      nil]];
                                                });
                                            }];
    }
    else
    {
        [mMotionManager stopDeviceMotionUpdates];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"MOTIONCHECK_NOTIFY"
                                                           object:nil
                                                         userInfo:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInteger:0],@"rotation",
          nil]];
        
    }
}

-(void)setLog:(NSString*)log
{
    NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    NSString* datestr = [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    
    CWLogDebug(@"SDKTEST:%@:%@",datestr,log);
    NSString* str = [NSString stringWithFormat:@"%@:%@",datestr,log];
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"CallLog%d",mLogIndex]];
    mLogIndex++;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

@end
