#import <UIKit/UIKit.h>
#import "sdkkey.h"
#import "sdkobj.h"
#import "ContactListTableViewController.h"

typedef enum EVENTID
{
    MSG_NEED_VIDEO = 4000,
    MSG_SET_AUDIO_DEVICE = 4001,
    MSG_SET_VIDEO_DEVICE = 4002,
    MSG_HIDE_LOCAL_VIDEO = 4003,
    MSG_ROTATE_REMOTE_VIDEO = 4004,
    MSG_SNAP = 4005,
    MSG_MUTE = 4006,
    MSG_SENDDTMF = 4007,
    MSG_DOHOLD = 4008,
    MSG_UPDATE_CALLDURATION = 4009,
    MSG_HANGUP = 4010,
    MSG_ACCEPT = 4011,
    MSG_REJECT = 4012,
#if(SDK_HAS_GROUP>0)
    MSG_GROUP_CREATE = 4013,
    MSG_GROUP_ACCEPT = 4014,
    MSG_GROUP_LIST = 4015,
    MSG_GROUP_INVITE = 4016,
    MSG_GROUP_KICK = 4017,
    MSG_GROUP_CLOSE = 4018,
    MSG_GROUP_UNMUTE = 4019,
    MSG_GROUP_MUTE = 4020,
    MSG_GROUP_DISPLAY = 4021,
    MSG_GROUP_JOIN = 4022,
#endif
    MSG_START_RECORDING = 4023,
    MSG_STOP_RECORDING = 4024,
}eventid;

#define CALLINGVIEW_TAG 2000
@interface CCallingViewController : UIViewController
@property (nonatomic, retain) IBOutlet UILabel*           mCallingNum;
@property (nonatomic, retain) IBOutlet UILabel*           mCallingInfo;
@property (nonatomic, retain) IBOutlet UIImageView* loginImageView;
@property (nonatomic, retain) IBOutlet UIImageView* callingImageView;
#if(SDK_HAS_GROUP>0)
@property (nonatomic, retain) IBOutlet UITextField*           mUser3;
@property (nonatomic, retain) UIAlertView *groupNameAlertView;
@property (strong, nonatomic) ContactListTableViewController *contactlistViewController;
#endif
@property(nonatomic,assign)BOOL isCallOut;
@property(nonatomic,assign)BOOL isVideo;
@property(nonatomic,assign)BOOL isAutoRotate;
@property(nonatomic,assign)BOOL isRecording;
@property (strong, nonatomic) UIButton* btnAccept;
@property (strong, nonatomic) UIButton* btnReject;
@property (strong, nonatomic) UIButton* btnHangup;
@property (strong, nonatomic) UIView *localVideoView;
@property (strong, nonatomic) IOSDisplay *remoteVideoView;

-(void)onCallOk:(BOOL)callOK;

-(void)setCallStatus:(NSString*)log;
-(void)setVideoStatus:(NSString*)log txtColor:(UIColor*)color;
-(void)setCallDuration:(unsigned int)callDuration withCPU:(float)cpuUseage withMem:(float)memUse;
@end
