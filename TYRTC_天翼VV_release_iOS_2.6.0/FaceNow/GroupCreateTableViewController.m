//
//  GroupCreateTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-16.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "GroupCreateTableViewController.h"
#import "PersonalDetailTableViewController.h"
#import "MyCustomTableViewCell.h"
#import "CCallingViewController.h"
#import "sdkobj.h"

#define groupNameAlertViewTag 1234
#define groupNameAlertViewTag2 4567
#if(SDK_HAS_GROUP>0)
extern SDK_GROUP_TYPE grpType;
BOOL groupAddMember = NO;
#endif
@interface GroupCreateTableViewController ()

@end

@implementation GroupCreateTableViewController
@synthesize groupName;
@synthesize footerView;
@synthesize plistPath = _plistPath;
@synthesize myGroupListData = _myGroupListData;
@synthesize myGroupListSections = _myGroupListSections;

/**********************************群组呼叫界面*************************************/
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
    [btnItem setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1] forState:UIControlStateNormal];
    [btnItem setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:214.0/255.0 blue:0.0/255.0 alpha:1]];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.footerView addSubview:btnItem];
    
    return btnItem;
}

-(UIButton*)addImageBtn:(NSString*)title  func:(SEL)func rect:(CGRect)rect
{
    UIImage *image1 = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",title]];
    UIButton* btnItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnItem.frame = rect;
    [btnItem addTarget:self action:func forControlEvents:UIControlEventTouchDown];
    [btnItem setBackgroundImage:image1 forState:UIControlStateNormal];
    [btnItem.layer setMasksToBounds:YES];
    [btnItem.layer setCornerRadius:10.0];
    [self.footerView addSubview:btnItem];
    
    return btnItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];

    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    double x=0;
    double y=rect.size.height;
    int headerh=30;
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(x, y, SCREEN_WIDTH, y+2*(33*SCREEN_WIDTH/320+12.5))];
    x=50;
    y-=10;
    CGFloat w=0.9*SCREEN_WIDTH/3;//88;
    CGFloat h=headerh+3;
    CGFloat sep=25;
    rect = CGRectMake(x/4, y, w , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"lts"   func:@selector(makeAChatCall:)    rect:rect];
    
    rect = CGRectMake(x/4+w+0.2*sep,y, w , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"qdj"   func:@selector(makeASpeakCall:)    rect:rect];
    
    rect = CGRectMake(x/4+2*w+0.4*sep,y, w , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"vvxc"   func:@selector(makeATwoCall:)    rect:rect];
    
    rect = CGRectMake(x/4, y+h*SCREEN_WIDTH/320+0.5*sep, w , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"xczb"   func:@selector(makeVLiveCall:)    rect:rect];
    
    rect = CGRectMake(x/4+w+0.2*sep, y+h*SCREEN_WIDTH/320+0.5*sep, w , h*SCREEN_WIDTH/320);
    [self addImageBtn:@"sphy"   func:@selector(makeVChatCall:)    rect:rect];
    
//    rect = CGRectMake(x+2*w+2*sep,y+h+0.5*sep, w , h);
//    [self addGridBtn:@"加入会议"   func:@selector(makeJoinCall:)    rect:rect];
    
    self.tableView.autoresizesSubviews = YES;
    [self.footerView setNeedsLayout];
    [self.footerView layoutIfNeeded];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [self.tableView beginUpdates];
    [self.tableView setTableHeaderView:self.footerView];
    [self.tableView endUpdates];
    [self.footerView release];

    self.title = [[NSString alloc] initWithString:self.groupName];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    //self.refreshControl = [[UIRefreshControl alloc]init];
    //self.refreshControl.tintColor = [UIColor blueColor];
    //self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"刷新"];
    //[self.refreshControl addTarget:self action:@selector(refreshTableView) forControlEvents:UIControlEventValueChanged];
    
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString* nameString =  [[@"GroupList_" stringByAppendingString:self.groupName] stringByAppendingString:@".plist"];
    self.plistPath = [documentsPath stringByAppendingPathComponent:nameString];
    
    NSMutableDictionary *dict;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.plistPath])
    {
        [[NSFileManager defaultManager]  createFileAtPath:self.plistPath contents:nil attributes:nil];
        
        //创建词典对象，初始化长度为10
        dict = [NSMutableDictionary dictionaryWithCapacity:10];
        
    }
    else
    {
        //Load the file in a dictionnary
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:self.plistPath];
        if (dict == nil) {
            dict = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    }
    
    self.myGroupListData = dict;
    
    
    NSArray *dicoArray = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.myGroupListSections = dicoArray;
    
    /////////////////////////////////////////////////////////////////////////
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(addAndRefreshTableView2:)
//                                                 name:@"SaveToGroupMemberNotification"
//                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupAddMemberNotification:)
                                                 name:@"GroupAddMemberNotification"
                                               object:nil];//添加账号操作4:接收消息添加账号
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupAddMemberNotification:)
                                                 name:@"EditGroupMemberNotification"
                                               object:nil];//编辑账号操作2:接收消息添加账号
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onGroupAddMemberNotification:)
                                                 name:@"AddGroupMemberNotification"
                                               object:nil];//编辑账号操作2:接收消息添加账号
}
#if(SDK_HAS_GROUP>0)
//创建语音群聊
-(void)makeAChatCall:(id)sender
{
    grpType = SDK_GROUP_CHAT_AUDIO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建语音两方
-(void)makeATwoCall:(id)sender
{
    grpType = SDK_GROUP_TWOVOICE_AUDIO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建语音对讲
-(void)makeASpeakCall:(id)sender
{
    grpType = SDK_GROUP_SPEAK_AUDIO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建语音直播
-(void)makeALiveCall:(id)sender
{
    grpType = SDK_GROUP_MICROLIVE_AUDIO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//主动加入会议
-(void)makeJoinCall:(id)sender
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupJoinNotification"
     object:dic];
}

//创建视频群聊
-(void)makeVChatCall:(id)sender
{
    grpType = SDK_GROUP_CHAT_VIDEO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建视频两方
-(void)makeVTwoCall:(id)sender
{
    grpType = SDK_GROUP_TWOVOICE_VIDEO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建视频对讲
-(void)makeVSpeakCall:(id)sender
{
    grpType = SDK_GROUP_SPEAK_VIDEO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}

//创建视频直播
-(void)makeVLiveCall:(id)sender
{
    grpType = SDK_GROUP_MICROLIVE_VIDEO;
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.myGroupListSections,KEY_GRP_INVITEELIST,
                         self.groupName,KEY_GRP_NAME,
                         nil];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"GroupCallNotification"
     object:dic];
}
#endif

- (void) refreshTableView
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //解决中文输入法下，输入nihao,结果确得到ni hao
    NSString* newstring = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *checker = [NSString stringWithFormat:@"%C", 8198]; // %C为大写
    if ([newstring rangeOfString:checker].length) {
        newstring = [newstring stringByReplacingOccurrencesOfString:checker withString:@""];
    }
    return true;
}

- (void) viewWillAppear:(BOOL) animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)onGroupAddMemberNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"GroupAddMemberNotification"]) {
        NSString *nums = [notification object];
        [self addGroupByName:nums];//点列表项邀请
    }
    else if ([[notification name] isEqualToString:@"EditGroupMemberNotification"]) {
        self.groupNameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"添加账号", @"") message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [self.groupNameAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        self.groupNameAlertView.tag = groupNameAlertViewTag;
        //becoming the delegate for the input text field
        [[self.groupNameAlertView textFieldAtIndex:0] setDelegate:self.groupNameAlertView];
        [self.groupNameAlertView show];//编辑账号操作3:显示输入框
    }
    else if ([[notification name] isEqualToString:@"AddGroupMemberNotification"]) {
        self.groupNameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"添加账号", @"") message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
        [self.groupNameAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
        self.groupNameAlertView.tag = groupNameAlertViewTag2;
        //becoming the delegate for the input text field
        [[self.groupNameAlertView textFieldAtIndex:0] setDelegate:self.groupNameAlertView];
        [self.groupNameAlertView show];//编辑账号操作3:显示输入框
    }
}

-(void)addGroupByName:(NSString*) nameGroup
{
    NSString *name = [nameGroup stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    
    if (name.length > 0 )
    {
        //得到词典中所有KEY值
        NSEnumerator * enumeratorKey = [self.myGroupListData keyEnumerator];
        
        //快速枚举遍历所有KEY的值
        for (NSObject *object in enumeratorKey) {
            NSString *key = [NSString stringWithFormat:@"%@", object];
            if ([name isEqualToString:key]) {
//                NSLog(@"重复的账号: %@",object);
//                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"重复的账号" message:@"请重新输入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                
//                [alertView show];
//                [alertView release];
                return;
            }
        }
        
        [self.myGroupListData setObject:name forKey:name];
        [self.myGroupListData writeToFile:self.plistPath atomically:YES];
        self.myGroupListSections = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        [self.tableView reloadData];
    }
}

-(void)addGroup:(id)sender
{
    groupAddMember = YES;
    
    //添加账号操作1：显示cantactlist
    ContactListTableViewController* view1 = [[ContactListTableViewController alloc]initWithNibName:nil bundle:nil];
    [self presentViewController:view1 animated:NO completion:nil];
    [view1 release];
}

//- (void) addAndRefreshTableView2:(NSNotification *) notification
//{
//    // [notification name] should always be @"CallNotification"
//    // unless you use this method for observation of other notifications
//    // as well.
//    NSMutableArray *nums = [notification object];//成员列表
//    NSString* groupString = [nums[0] componentsJoinedByString:@""];//群组名
////    NSString* nameString;
//
//    //Create a string representing the file path
//    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = [paths objectAtIndex:0];
//    NSString* groupplistPath =  [[@"GroupList_" stringByAppendingString:groupString] stringByAppendingString:@".plist"];
//    self.plistPath = [documentsPath stringByAppendingPathComponent:groupplistPath];
//    NSMutableDictionary *dict;
//    if (![[NSFileManager defaultManager] fileExistsAtPath:self.plistPath])
//    {
//        [[NSFileManager defaultManager]  createFileAtPath:self.plistPath contents:nil attributes:nil];
//        
//        //创建词典对象，初始化长度为10
//        dict = [NSMutableDictionary dictionaryWithCapacity:10];
//        
//    }
//    else
//    {
//        //Load the file in a dictionnary
//        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:groupplistPath];
//        if (dict == nil) {
//            dict = [NSMutableDictionary dictionaryWithCapacity:10];
//        }
//    }
//    self.myGroupListData = dict;
//    NSArray *dicoArray = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
//    self.myGroupListSections = dicoArray;
//    
//    if ([[notification name] isEqualToString:@"SaveToGroupMemberNotification"]) {
//        for(int i = 1; i<[nums count]; i++)
//        {
//            [self addGroupByName:[nums[i] componentsJoinedByString:@""]];
//        }
//    }
//}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.groupNameAlertView dismissWithClickedButtonIndex:self.groupNameAlertView.firstOtherButtonIndex animated:YES];
    [self addGroupByName:textField.text];
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == groupNameAlertViewTag) {
        if (buttonIndex == 1)
        {
            //do something
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            [self addGroupByName:textfield.text];//编辑账号操作4:名单加人
            
            NSArray *num = [NSArray arrayWithObjects:textfield.text,nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SaveToRecentCallNotification"
             object:num];
        }
    }
    else if (alertView.tag == groupNameAlertViewTag2) {
        if (buttonIndex == 1)
        {
            //do something
            UITextField *textfield =  [self.groupNameAlertView textFieldAtIndex: 0];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"GroupInviteNotification"
             object:textfield.text];//编辑账号操作4:触发邀请
            
            NSArray *num = [NSArray arrayWithObjects:textfield.text,nil];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"SaveToRecentCallNotification"
             object:num];
            
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"GroupAddMemberNotification"
             object:textfield.text];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
        return [self.myGroupListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    {
        NSString *key = [self.myGroupListSections objectAtIndex:section];
        //通过KEY找到value
        NSObject *object = [self.myGroupListData objectForKey:key];
        NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
        
        if (dataForSection != nil) {
            return [dataForSection count];
        } else {
            return 1;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    {
        return  nil;
    }
}

//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    //return self.myGroupListSections;
//    NSMutableArray *toBeReturned = [[NSMutableArray alloc]init];
//    
//    for(char c = 'A'; c<='Z'; c++)
//        
//        [toBeReturned addObject:[NSString stringWithFormat:@"%c",c]];
//    
//    return toBeReturned;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    static NSString *CellIdentifier = @"Cell";
    
    MyCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MyCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
        
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.myGroupListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = [self.myGroupListData objectForKey:key];
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
    
    cell.textLabel.text = [dataForSection objectAtIndex:row];
    NSString  *imageName = [NSString  stringWithFormat:@"icon.png"];
    cell.imageView.image  =  [UIImage  imageNamed:imageName];
    [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSUInteger section = [indexPath section];
        NSString *key = [self.myGroupListSections objectAtIndex:section];
        [self.myGroupListData removeObjectForKey:key];
        NSArray *dicoArray = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.myGroupListSections = dicoArray;
        [self.myGroupListData writeToFile:self.plistPath atomically:YES];
        [tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.myGroupListSections objectAtIndex:[indexPath section]];
    
    PersonalDetailTableViewController *detail = [[PersonalDetailTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    detail.phoneNum = key;
    [self.navigationController pushViewController:detail animated:NO];
    [detail release];
}

@end
