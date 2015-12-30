//
//  MyInfoTableViewController.h
//  FaceNow
//
//  Created by administration on 14-10-14.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sdkkey.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define KEY_MYINFO_LOGIN_ID                 @"001_账号"
#define KEY_MYINFO_STATUS                    @"002_状态"

#define KEY_MYINFO_APP_ID                     @"003_AppID"
#define KEY_MYINFO_APP_KEY                  @"004_AppKey"
#define KEY_MYINFO_UDID                         @"005_UDID"

#define KEY_MYINFO_NAVI_ADDRES        @"006_地址"
#define KEY_MYINFO_URI_DOMAIN           @"007_UriDomain"

#define KEY_MYINFO_VIDEO_CODEC            @"008_视频编码"
#define KEY_MYINFO_AUDIO_CODEC           @"009_音频编码"
#define KEY_MYINFO_AUTOACCEPT           @"011_自动应答"
#define KEY_MYINFO_VERSION           @"010_关于"


#define KEY_MYINFO_VIDEO_WIDTH        @"VIDEO_WIDTH"
#define KEY_MYINFO_VIDEO_HEIGHT        @"VIDEO_HEIGHT"

#define KEY_MYINFO_CODEC        @"编码"
#define KEY_MYINFO_VIDEOSIZE        @"分辨率"

typedef enum MYINFO_EVENTID
{
    MSG_UPDATE_STATUS = 4000,
    MSG_UPDATE_VIDEO_CODEC,
    MSG_UPDATE_AUDIO_CODEC,
    MSG_UPDATE_UNREG,
    MSG_CHANGE_UNREG,
    MSG_UPDATE_AUTOACCEPT,
}myinfo_eventid;

typedef enum _ACTIONSHEETTAG
{
    TAG_TERMINAL_TYPE_SELECT,
    TAG_ADDRESS_SELECT,
}ACTIONSHEETTAG;

struct MyInfoSet {
    NSString* loginID;
    NSString* naviAddress;//导航服务器地址
    NSString* uriDomain;
    NSString* appID;
    NSString* appKey;
    NSString* UDID;
    NSString* status;
    NSString*  videoType;
    NSString* audioType;

};

@interface MyInfoTableViewController : UITableViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MFMailComposeViewControllerDelegate>
@property (nonatomic, retain) NSString*   infoImageName;
@property (nonatomic, retain) NSString*   infoImagePath;
@property (nonatomic, retain) UIImageView* infoPhotoImageView;
@property (nonatomic, retain) UILabel *labelView;
@property (nonatomic, retain) NSString*   loginID;
@property (nonatomic, retain) NSString*   terminalType;

@property (nonatomic, retain) NSString *myInfoListPath;
@property (nonatomic, retain) NSMutableDictionary *myInfoListData;
@property (nonatomic, retain) NSArray *myInfoListSections;
@property(strong,nonatomic) UIActivityIndicatorView *loginActivityIndicator;

- (void) getCurrentInfo;

@end
