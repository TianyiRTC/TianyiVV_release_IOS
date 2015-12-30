//
//  VersionTableViewController.m
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "VersionViewController.h"
#import "MyInfoTableViewController.h"
#import "sdkobj.h"

#define APP_VERSION         @"SDK2.6.0_VV2.6.0"

@interface VersionViewController ()

@end

@implementation VersionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.view setBackgroundColor:image1];
    CGRect lblItemFrame;//lbl : label
    CGFloat height = 30;
    CGFloat y = 160;
    UILabel* lblItem;
    
    UIImageView* loginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 30, y-60, 60, 60)];
    NSString* imageName =   [NSString stringWithFormat:@"login_logo.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    loginImageView.layer.contents = (id) image.CGImage;
    [self.view addSubview:loginImageView];
    
    lblItemFrame = CGRectMake(SCREEN_WIDTH/5, y, SCREEN_WIDTH, height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    [lblItem setText:[NSString stringWithFormat: @"版本号:%@",APP_VERSION ]];
    [self.view addSubview:lblItem];
    [lblItem release];
    
    lblItemFrame = CGRectMake(10, y+2*height, SCREEN_WIDTH, 4*height);
    lblItem = [[UILabel alloc]initWithFrame:lblItemFrame];
    lblItem.numberOfLines = 0;
    [lblItem setText:@"使用须知:\n1:log路径:/天翼VV/tmp/cwlog.txt\n2:开启扬声器距离很近时会啸叫\n3:登录时提示-1002，请检查网络环境"];
    [self.view addSubview:lblItem];
    [lblItem release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

@end
