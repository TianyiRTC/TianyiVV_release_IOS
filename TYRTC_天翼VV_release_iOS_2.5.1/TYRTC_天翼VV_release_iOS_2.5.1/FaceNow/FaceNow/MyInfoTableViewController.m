//
//  MyInfoTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-14.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "MyInfoTableViewController.h"
#import  "MyCustomTableViewCell.h"
#import "VideoCodecTableViewController.h"
#import "AudioCodecTableViewController.h"
#import "VersionViewController.h"
#import "AutoAcceptViewController.h"
#import "sdkobj.h"

int changeVersion=1;//1为多人终端版，2为浏览器互通版

@interface MyInfoTableViewController ()

@end

@implementation MyInfoTableViewController
@synthesize infoImageName;
@synthesize infoImagePath;
@synthesize infoPhotoImageView;
@synthesize labelView;
@synthesize loginID;
@synthesize terminalType;
@synthesize myInfoListData;
@synthesize myInfoListSections;
@synthesize myInfoListPath;
@synthesize loginActivityIndicator;

/**********************************获取设置信息*************************************/
- (void) getCurrentInfo
{
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.myInfoListPath = [documentsPath stringByAppendingPathComponent:@"MyInfoList.plist"];
    
    NSMutableDictionary *dict;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.myInfoListPath])
    {
        NSLog(@"MyInfoList.plist not found !");
        return;
    }
    else
    {
        //Load the file in a dictionnary
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.myInfoListPath];
        if (dict == nil) {
            NSLog(@"MyInfoList.plist is nil !");
            return;
        }
    }
    
    self.myInfoListData = dict;
    NSArray *dicoArray = [[self.myInfoListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.myInfoListSections = dicoArray;
}

-(void) viewWillAppear:(BOOL)animated{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_UPDATE_STATUS],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MYINFO_EVENT" object:nil userInfo:params];

    [self getCurrentInfo];
}

UIButton* btnItemf;
-(UIButton*)addImageBtn:(NSString*)imageName  title:(NSString*)title func:(SEL)func rect:(CGRect)rect
{
    UIImage *image = [UIImage imageNamed:imageName];
    btnItemf = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItemf.frame = rect;
    [btnItemf setShowsTouchWhenHighlighted:YES];
    [btnItemf addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItemf setBackgroundImage:image forState:UIControlStateNormal];
    [btnItemf setTitle:title forState:UIControlStateNormal];
    [btnItemf setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnItemf.layer setMasksToBounds:YES];
    [btnItemf.layer setCornerRadius:10.0];
    [self.tableView.tableFooterView addSubview:btnItemf];
    
    return btnItemf;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView=[[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped] autorelease];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_UPDATE_STATUS],@"msgid",
                            [NSNumber numberWithInt:0],@"arg",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MYINFO_EVENT" object:nil userInfo:params];

    [self getCurrentInfo];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示

    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];

    double x=10;
    double y=rect.size.height;
    int headerh=100;
    int imagew=headerh-40;
    int lablew =SCREEN_WIDTH - imagew;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH, headerh)];
    
    self.infoImageName =   [NSString stringWithFormat:@"currentInfoImage.png"];
    self.infoImagePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:self.infoImageName];

    self.infoPhotoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imagew, imagew)];
    self.infoPhotoImageView.backgroundColor = [UIColor clearColor];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.infoImagePath])
    {
        NSString* imageName =   [NSString stringWithFormat:@"call_video_default_avatar.png"];
        UIImage *image = [UIImage imageNamed:imageName];
        self.infoPhotoImageView.layer.contents = (id) image.CGImage;
    }
    else
    {
        [self.infoPhotoImageView setImage:[UIImage imageWithContentsOfFile:self.infoImagePath]];
    }

    // Rounded corners.
    self.infoPhotoImageView.layer.cornerRadius = 10;
    self.infoPhotoImageView.userInteractionEnabled = YES;
    self.infoPhotoImageView.multipleTouchEnabled = YES;
    
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(onClickImage:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    singleFingerOne.delegate= self;
    [self.infoPhotoImageView addGestureRecognizer:singleFingerOne];
    [singleFingerOne release];

    [headerView addSubview:self.infoPhotoImageView];
    self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(x+imagew+10, y, lablew, imagew)];
    [self.labelView setText:self.loginID];
    [headerView addSubview:self.labelView];
    
    self.tableView.autoresizesSubviews = YES;
    
    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:headerView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, headerh+50)];
    [self.tableView setTableFooterView:footerView];
    x=30;
    y=0;
    CGFloat w=SCREEN_WIDTH - 2*x;
    CGFloat h=40;
    rect = CGRectMake(x, y, w , h);
    [self addImageBtn:@"button_more_f.png" title:@"注销" func:@selector(onUnRegist:)    rect:rect];
    
    rect = CGRectMake(x, y+h+10, w , h);
    [self addImageBtn:@"button_more_f.png" title:@"上传日志" func:@selector(onEmailLog:)    rect:rect];
    
    rect = CGRectMake(x, y+2*h+20, w , h);
    [self addImageBtn:@"button_more_f.png" title:@"切换至浏览器互通版" func:@selector(onChangeVersion:)    rect:rect];
    
    [self.tableView endUpdates];

    [footerView release];
    [labelView release];
    [headerView release];
    
    loginActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    [loginActivityIndicator setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    loginActivityIndicator.frame = CGRectMake(rect.size.width/2,rect.size.height/2, 0, 0);
    [self.tableView addSubview:loginActivityIndicator];
    loginActivityIndicator.color = [UIColor greenColor]; // 改变圈圈的颜色； iOS5引入
    [loginActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onChangeVersionNotification:)
                                                 name:@"ChangeVersionNotification"
                                               object:nil];
}

//版本切换
-(void)onChangeVersionNotification:(NSNotification *) notification
{
    if(changeVersion==1)
        [btnItemf setTitle:@"切换至浏览器互通版" forState:UIControlStateNormal];
    else if(changeVersion==2)
        [btnItemf setTitle:@"切换至多人终端版" forState:UIControlStateNormal];
}

//处理单指事件
- (void)onClickImage:(UITapGestureRecognizer *)sender
{
    if(sender.numberOfTapsRequired == 1) {
        //单指单击
        UIActionSheet *sheet;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            sheet  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
        }
        else {
            sheet = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        }
        
        sheet.tag = 255;
        
        [sheet showInView:self.tableView.superview];
    }else if(sender.numberOfTapsRequired == 2){
        //单指双击
    }
}

//注销登录
- (IBAction)onUnRegist:(id)sender
{
    [loginActivityIndicator startAnimating];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                            [NSNumber numberWithInt:MSG_UPDATE_UNREG],@"msgid",
                            nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MYINFO_EVENT" object:nil userInfo:params];
}

//切换浏览器模式
- (IBAction)onChangeVersion:(id)sender
{
   [loginActivityIndicator startAnimating];
    
    NSDictionary* params;
    if(changeVersion==1)
        params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"arg",
                                [NSNumber numberWithInt:MSG_CHANGE_UNREG],@"msgid",
                                nil];
    else if(changeVersion==2)
        params = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2], @"arg",
                                [NSNumber numberWithInt:MSG_CHANGE_UNREG],@"msgid",
                                nil];
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"MYINFO_EVENT" object:nil userInfo:params];
}

//发送邮件
-(void)displayComposerSheet
{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject: @"iOS Log"];
    
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObjects: @"dingpeng@ctbri.com.cn", @"shenyun_bjy@ctbri.com.cn", @"shilh@ctbri.com.cn", @"zhangzch@ctbri.com.cn", @"weilai@ctbri.com.cn",nil];
    [mailPicker setToRecipients: toRecipients];
    
    // 添加正文
    NSString *emailBody = @"";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    //添加附件
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *file = [NSString stringWithFormat:@"%@/cwlog.txt",tmpDir];
    NSData *txt = [NSData dataWithContentsOfFile:file];
    [mailPicker addAttachmentData: txt mimeType: @"" fileName: @"cwlog.txt"];
    
    [self presentViewController: mailPicker animated:YES completion:nil];
    [mailPicker release];
}

-(void)launchMailAppOnDevice
{
    NSString *recipients = @"mailto:first@example.com&subject=my email!";
    NSString *body = @"&body=email body!";
    NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];
}

- (IBAction)onEmailLog:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - action sheet delegte
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}]; //此处的delegate是上层的ViewController，如果你直接在ViewController使用，直接self就可以了
    }
}

#pragma mark - image picker delegte

//从相册选择图片后操作
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
    //保存原始图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self saveImage:image withName:self.infoImageName];
    
}

//保存图片
- (void) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
     self.infoImagePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imageData writeToFile:self.infoImagePath atomically:NO];
    //将选择的图片显示出来
    [self.infoPhotoImageView setImage:[UIImage imageWithContentsOfFile:self.infoImagePath]];
    //将图片保存到disk
    UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
}

//取消操作时调用
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
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
    return [self.myInfoListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.myInfoListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = [self.myInfoListData objectForKey:key];
    
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
    
    if (dataForSection != nil) {
        return [dataForSection count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    NSString *string1 = [self.myInfoListSections objectAtIndex:section];
    NSString *string2 = [string1 substringFromIndex:4];
    return [NSString stringWithFormat:@"%@", string2];
}

//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return self.myContactListSections;
//    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
//    
//    for(char c = 'A'; c<='Z'; c++)
//        
//        [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
//    
//    return toBeReturned;
//}

//点击右侧索引表项时调用
- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MyCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MyCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
        
    NSString *key = [self.myInfoListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = [self.myInfoListData objectForKey:key];
        
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
        
    //cell.textLabel.text = [[dataForSection allKeys] objectAtIndex:row];
    cell.textLabel.text = [dataForSection objectAtIndex:row];
    NSString  *imageName = [NSString  stringWithFormat:@"icon.png"];
    cell.imageView.image  =  [UIImage  imageNamed:imageName];
    if ([key isEqualToString:KEY_MYINFO_VIDEO_CODEC] || [key isEqualToString:KEY_MYINFO_AUDIO_CODEC] || [key isEqualToString:KEY_MYINFO_VERSION] || [key isEqualToString:KEY_MYINFO_AUTOACCEPT]) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.myInfoListSections objectAtIndex:[indexPath section]];
    if ([key isEqualToString:KEY_MYINFO_VIDEO_CODEC]) {
        VideoCodecTableViewController *detail = [[VideoCodecTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        NSString *codec = [self.myInfoListData objectForKey:KEY_MYINFO_VIDEO_CODEC];
        //NSRange range = [codec rangeOfString:@"@"];
        //NSString *codec = nil;
        NSString *reso = nil;
//        if (range.length > 0) {
//            NSArray *array = [string componentsSeparatedByString:@"@"]; //从字符A中分隔成2个元素的数组
//            codec = [array objectAtIndex:0];
//            reso = [array objectAtIndex:1];
//        }
        
        if (codec == nil)
            codec = @"VP8";

        if (reso == nil)
            reso = @"标清";
        
        [detail setVideoInfo:codec resolution:reso];
        [self.navigationController pushViewController:detail animated:NO];
    }
    else if ([key isEqualToString:KEY_MYINFO_AUDIO_CODEC]) {
        AudioCodecTableViewController *detail = [[AudioCodecTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        NSObject *object = [self.myInfoListData objectForKey:KEY_MYINFO_AUDIO_CODEC];
        NSString *string = [NSString stringWithFormat:@"%@", object];
        
        if (string == nil)
            string = @"iLBC";
        
        [detail setAudioInfo:string];
        [self.navigationController pushViewController:detail animated:NO];
    }
    else if ([key isEqualToString:KEY_MYINFO_VERSION]) {
        VersionViewController *detail = [[VersionViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        NSObject *object = [self.myInfoListData objectForKey:KEY_MYINFO_VERSION];
        NSString *string = [NSString stringWithFormat:@"%@", object];
        [self.navigationController pushViewController:detail animated:NO];
    }
    else if ([key isEqualToString:KEY_MYINFO_AUTOACCEPT]) {
        AutoAcceptViewController *detail = [[AutoAcceptViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
        NSObject *object = [self.myInfoListData objectForKey:KEY_MYINFO_AUTOACCEPT];
        NSString *string = [NSString stringWithFormat:@"%@", object];
        
        if (string == nil)
            string = @"NO";
        
        [detail setAutoInfo:string];
        [self.navigationController pushViewController:detail animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}


- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

//设置cell的隔行换色
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] % 2 == 0) {
        cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    } else {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}

@end
