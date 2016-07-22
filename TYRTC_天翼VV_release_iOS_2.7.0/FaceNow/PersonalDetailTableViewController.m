//
//  PersonalDetailTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-15.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "PersonalDetailTableViewController.h"
#import "MyInfoTableViewController.h"
#import <UIKit/UIKit.h>
#import "sdkobj.h"

@interface PersonalDetailTableViewController ()
{
    UIToolbar *toolBar;
}
@end

@interface PersonalDetailTableViewController ()

@end

@implementation PersonalDetailTableViewController
@synthesize phoneNum;

/**********************************联系人呼叫界面*************************************/
-(UIButton*)addImageBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:title];
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
    [btnItem setShowsTouchWhenHighlighted:YES];
    [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItem setBackgroundImage:image forState:UIControlStateNormal];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.view addSubview:btnItem];
    
    return btnItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示

    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    double x=10;
    double y=rect.size.height;
    int headerh=100;
    int imagew=headerh-40;
    int lablew =SCREEN_WIDTH - imagew;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH, headerh)];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imagew, imagew)];
    imageView.backgroundColor = [UIColor clearColor];
    UIImage *image = [UIImage imageNamed:@"call_video_default_avatar.png"];
    imageView.layer.contents = (id) image.CGImage;
    // Rounded corners.
    imageView.layer.cornerRadius = 10;
    imageView.userInteractionEnabled = YES;
    imageView.multipleTouchEnabled = YES;
        
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                               action:@selector(onClickImage:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate= self;
    [imageView addGestureRecognizer:singleFingerOne];
    [singleFingerOne release];
    
    [headerView addSubview:imageView];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(x+imagew+10, y, lablew, imagew)];
    [labelView setText:self.phoneNum];
    [headerView addSubview:labelView];
    self.tableView.autoresizesSubviews = YES;

    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:headerView];
    [self.tableView endUpdates];
    [imageView release];
    [labelView release];
    [headerView release];
    
    x=20;
    y=110;
    CGFloat w=160 - 1.5*x;
    CGFloat h=40;
    rect = CGRectMake(SCREEN_WIDTH/4-w*SCREEN_WIDTH/640, y, w*SCREEN_WIDTH/320 , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"dialpad_audio_call_s.png"   func:@selector(makeAudioCall:)    rect:rect];

    rect = CGRectMake(3*SCREEN_WIDTH/4-w*SCREEN_WIDTH/640,y, w*SCREEN_WIDTH/320 , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"dialpad_video_call_s.png"   func:@selector(makeVideoCall:)    rect:rect];
    
    [self.navigationController  setToolbarHidden:YES animated:YES];
    [self.view addSubview:toolBar];
    
}

//处理单指事件
- (void)onClickImage:(UITapGestureRecognizer *)sender
{
    if(sender.numberOfTapsRequired == 1) {
        //单指单击
    }else if(sender.numberOfTapsRequired == 2){
        //单指双击
    }
}

//音频呼叫
-(void)makeAudioCall:(id)sender
{
    NSArray *num = [NSArray arrayWithObjects:self.phoneNum,nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AudioCallNotification"
     object:num];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToRecentCallNotification"
     object:num];
}

//视频呼叫
-(void)makeVideoCall:(id)sender
{
    NSArray *num = [NSArray arrayWithObjects:self.phoneNum,nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"VideoCallNotification"
     object:num];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToRecentCallNotification"
     object:num];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}
@end
