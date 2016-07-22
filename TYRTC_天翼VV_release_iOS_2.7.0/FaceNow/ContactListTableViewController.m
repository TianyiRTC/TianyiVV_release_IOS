//
//  ContactListTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-17.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "ContactListTableViewController.h"
#import "PersonalDetailTableViewController.h"
#import "MyCustomTableViewCell.h"
#import "sdkobj.h"
#import <AddressBook/AddressBook.h>
#import "ContactsData.h"

#define MOBILE_NUMBER_LEN 11

BOOL callingviewInvite = NO;
BOOL callingviewKick = NO;
BOOL callingviewMic = NO;
BOOL callingviewNoMic = NO;
BOOL callingviewList = NO;
extern BOOL groupAddMember;

@interface ContactListTableViewController()
{
    // 这是与搜索框关联的对像
    IBOutlet UISearchBar *searchBar;
    
    // 标识：是否在搜索状态中
    BOOL isSearchOn;
    
    // 标识：是否能选择行
    BOOL canSelectRow;
    
    // 搜索结果列表
    NSMutableArray *searchResult;
}
@end


@interface ContactListTableViewController ()

@end

@implementation ContactListTableViewController

@synthesize searchBar;
@synthesize footerView,mGroupConduct;
@synthesize plistPath = _plistPath;
@synthesize myContactListData = _myContactListData;
@synthesize myContactListSections = _myContactListSections;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    int length = [self getLength:textField.text];
    if(length == MOBILE_NUMBER_LEN)
    {
        if(range.length == 0)
            return NO;
    }
    
    if(length == 3)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) ",num];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
    }
    else if(length == 7)
    {
        NSString *num = [self formatNumber:textField.text];
        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
        if(range.length > 0)
            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
    }
    
    return YES;
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    if(length > MOBILE_NUMBER_LEN)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-MOBILE_NUMBER_LEN];
    }
    
    return mobileNumber;
}

-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
}

//踢出操作5，给麦操作5，获取列表操作5:显示成员列表
-(void)getGroupList:(NSNotification *) notification
{
    NSString* remoteUri2 = nil;
    if ([[notification name] isEqualToString:@"SaveToGroupListNotification"]) {
        [self.myContactListData removeAllObjects];
        NSString *nums = [notification object];
        remoteUri2 = nums;
        NSArray* remoteAccArr = [remoteUri2 componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        for(int i = 0; i<countMem; i++)
        {
            [self.myContactListData setObject:remoteAccArr[i] forKey:remoteAccArr[i]];
        }
        
        self.myContactListSections = [[self.myContactListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }
}

-(void)getMicList:(NSNotification *) notification
{
    NSString* remoteUri2 = nil;//收麦操作5:显示收麦列表
    if (callingviewNoMic&&[[notification name] isEqualToString:@"GroupNoMicNotification"]) {
        [self.myContactListData removeAllObjects];
        NSString *nums = [notification object];
        remoteUri2 = nums;
        NSArray* remoteAccArr = [remoteUri2 componentsSeparatedByString:@","];
        NSUInteger countMem=[remoteAccArr count];
        for(int i = 0; i<countMem; i++)
        {
            [self.myContactListData setObject:remoteAccArr[i] forKey:remoteAccArr[i]];
        }
        
        self.myContactListSections = [[self.myContactListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        [self.tableView reloadData];
    }
}

//获取联系人
-(NSArray *)getAllContacts
{
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName);
        CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
        
        for (int i = 0; i < nPeople; i++)
        {
            ContactsData *contacts = [ContactsData new];
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            
            //get First Name and Last Name
            contacts.firstNames = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
            
            contacts.lastNames =  (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
            
            if (!contacts.firstNames) {
                contacts.firstNames = @"";
            }
            if (!contacts.lastNames) {
                contacts.lastNames = @"";
            }
            
            // get contacts picture, if pic doesn't exists, show standart one
            NSData  *imgData = (__bridge NSData *)ABPersonCopyImageData(person);
            contacts.image = [UIImage imageWithData:imgData];
            if (!contacts.image) {
                contacts.image = [UIImage imageNamed:@"NOIMG.png"];
            }
            //get Phone Numbers
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
            
            ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for(CFIndex i=0;i<ABMultiValueGetCount(multiPhones);i++) {
                
                CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
                NSString *phoneNumber = (__bridge NSString *) phoneNumberRef;
                [phoneNumbers addObject:phoneNumber];
            }
            
            
            [contacts setNumbers:phoneNumbers];
            
            [phoneNumbers release];
            //get Contact email
            NSMutableArray *contactEmails = [NSMutableArray new];
            ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
            
            for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
                CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
                NSString *contactEmail = (__bridge NSString *)contactEmailRef;
                
                [contactEmails addObject:contactEmail];
            }
            
            [contacts setEmails:contactEmails];
            
            //write to ContactList.plist
            if (contacts.numbers.count > 0 && (contacts.firstNames.length > 0 || contacts.lastNames.length > 0))
            {
                for (NSString* numberString in contacts.numbers) {
                    numberString = [self formatNumber:numberString];
                    NSString* nameString =  [[[contacts.lastNames stringByAppendingString:contacts.firstNames] stringByAppendingString:@" "]stringByAppendingString:numberString];
                    [self.myContactListData setObject:nameString forKey:numberString];
                }
                
            }
            [items addObject:contacts];
        }
        return items;
    } else {
        return NO;
    }
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

-(void)getRecentContacts
{
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
    
    self.myContactListData = dict;
}

/**********************************联系人操作界面*************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];
    self.view.tag = 2000;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示
    
    //UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshContactsList:)];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshContactsList:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    double x=0;
    double y=rect.size.height;
    int headerh=30;
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(x, y+20, SCREEN_WIDTH, 70)];
    
    UILabel* lblItem = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, 120, 35)];
    [self.footerView addSubview:lblItem];
    self.mGroupConduct = lblItem;
    [self.mGroupConduct setTextColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:255.0/255.0 alpha:1]];
    if(callingviewNoMic)
        self.mGroupConduct.text = @"请选择收麦成员";
    else if(callingviewMic)
        self.mGroupConduct.text = @"请选择给麦成员";
    else if(callingviewKick)
        self.mGroupConduct.text = @"请选择踢出成员";
    else if(callingviewList)
        self.mGroupConduct.text = @"成员列表";
    [lblItem release];
    
    x=200;
    y+=10;
    CGFloat w=88;
    CGFloat h=headerh+5;
    rect = CGRectMake(10, y, 160 , h);
    if(groupAddMember)
        [self addGridBtn:@"点此输入账号"   func:@selector(editGroupMember:)    rect:rect];
    else if(callingviewInvite)
        [self addGridBtn:@"点此输入邀请账号"   func:@selector(addGroupMember:)    rect:rect];
    rect = CGRectMake(x, y, w , h);
    [self addGridBtn:@"返回"   func:@selector(backCallingView:)    rect:rect];
    
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
    
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.plistPath = [documentsPath stringByAppendingPathComponent:@"RecentCallList.plist"];//@"ContactList.plist"

    if(callingviewKick||callingviewMic||callingviewNoMic||callingviewList)//邀请操作2，添加账号操作2:初始化列表
    {
        self.plistPath = [documentsPath stringByAppendingPathComponent:@"ContactList.plist"];
        [self getRecentContacts];
    }
    
    if(!callingviewKick&&!callingviewMic&&!callingviewNoMic&&!callingviewList)//邀请操作2，添加账号操作2:读取通讯录
    {
        [self getRecentContacts];
//        int count = [self.myContactListData count];
//        
//        if (count == 0) {
//            //[self getAllContacts];
//        } else {
//            //得到词典的数量
//            int count = [self.myContactListData count];
//            //得到词典中所有KEY值
//            NSEnumerator * enumeratorKey = [self.myContactListData keyEnumerator];
//            //得到词典中所有Value值
//            NSEnumerator * enumeratorValue = [self.myContactListData objectEnumerator];
//        }
    }
    
    NSArray *dicoArray = [[self.myContactListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    self.myContactListSections = dicoArray;

    
    // This will not cause a space to appear at the top
    self.tableView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getGroupList:)
                                                 name:@"SaveToGroupListNotification"
                                               object:nil];//踢出操作4，给麦操作4，获取列表操作4：收到消息显示列表
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getMicList:)
                                                 name:@"GroupNoMicNotification"
                                               object:nil];//收麦操作4:接收账号显示列表
}

- (void) refreshTableView
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新"];
    [self.myContactListData removeAllObjects];
    //[self getAllContacts];
    [self getRecentContacts];
    NSArray *dicoArray = [[self.myContactListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.myContactListSections = dicoArray;
    [self.tableView reloadData];
}

-(void)refreshContactsList:(id)sender
{
    [self.myContactListData removeAllObjects];
    //[self getAllContacts];
    [self getRecentContacts];
    NSArray *dicoArray = [[self.myContactListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.myContactListSections = dicoArray;
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    self.searchBar = nil;
    [super viewDidUnload];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the content inset, good for section headers
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
    //if (isSearchOn) {
    if(tableView == self.searchController.searchResultsTableView)
    {
        return 1;  // 进入搜索状态，只有一个节点
    }
    else
    {
        return [self.myContactListSections count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of rows is the number of time zones in the region for the specified section.
    //if (isSearchOn)
    if(tableView == self.searchController.searchResultsTableView)
    {
        return [searchResult count];  // 搜索结果的数量
    }
    else
    {
        NSString *key = [self.myContactListSections objectAtIndex:section];
        //通过KEY找到value
        NSObject *object = [self.myContactListData objectForKey:key];
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
    //if (isSearchOn)
    if(tableView == self.searchController.searchResultsTableView)
    {
        return  nil;
    }
    else
    {
        return  nil;
    }
}

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
    //if (isSearchOn)
    if(tableView == self.searchController.searchResultsTableView)
    {
        NSString *title = [searchResult objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
    }
    else
    {
        
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        
        NSString *key = [self.myContactListSections objectAtIndex:section];
        //通过KEY找到value
        NSObject *object = [self.myContactListData objectForKey:key];
        NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
        cell.textLabel.text = [dataForSection objectAtIndex:row];
        NSString  *imageName = [NSString  stringWithFormat:@"icon.png"];
        cell.imageView.image  =  [UIImage  imageNamed:imageName];
    }
    [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    return cell;
}

-(void)editGroupMember:(id)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"EditGroupMemberNotification"
     object:nil];//编辑账号操作1:发消息给createtable
    [self dismissViewControllerAnimated:YES completion:nil];
    groupAddMember = NO;
}

-(void)addGroupMember:(id)sender
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AddGroupMemberNotification"
     object:nil];//编辑账号操作1:发消息给createtable
    [self dismissViewControllerAnimated:YES completion:nil];
    callingviewInvite = NO;
}

#pragma mark - Table view delegate
-(void)backCallingView:(id)sender
{
    callingviewInvite = NO;
    callingviewKick = NO;
    callingviewMic = NO;
    callingviewNoMic = NO;
    callingviewList = NO;
    groupAddMember = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    NSString *key = [self.myContactListSections objectAtIndex:[indexPath section]];
    
    PersonalDetailTableViewController *detail = [[PersonalDetailTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    detail.phoneNum = key;
    
    if(groupAddMember)//添加账号操作3:向createtableview发消息
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupAddMemberNotification"
         object:key];
        groupAddMember = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(callingviewInvite)//邀请操作3:向callingview发邀请消息
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupInviteNotification"
         object:key];
        callingviewInvite = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupAddMemberNotification"
         object:key];
    }
    else if(callingviewKick)//踢出操作6:向callingview发邀请消息
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupKickNotification"
         object:key];
        callingviewKick = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(callingviewMic)//给麦操作6:向callingview发给麦消息
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupMicNotification"
         object:key];
        callingviewMic = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if(callingviewNoMic)//收麦操作6:向callingview发收麦消息
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"GroupMicNotification"
         object:key];
        callingviewNoMic = NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.navigationController pushViewController:detail animated:NO];
        [detail release];
    }
}

@end
