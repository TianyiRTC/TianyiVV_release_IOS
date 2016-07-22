//
//  GroupTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-16.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "GroupTableViewController.h"
#import "MyCustomTableViewCell.h"
#import "sdkobj.h"

#define groupNameAlertViewTag 1234


@interface GroupTableViewController()
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

@interface GroupTableViewController ()

@end

@implementation GroupTableViewController

@synthesize searchBar;
@synthesize plistPath = _plistPath;
@synthesize myGroupListData = _myGroupListData;
@synthesize myGroupListSections = _myGroupListSections;
@synthesize detail;

/**********************************群组界面*************************************/
- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroup:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout =UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.plistPath = [documentsPath stringByAppendingPathComponent:@"GroupList.plist"];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

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

//新建群组
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
                NSLog(@"重复的群名称: %@",object);
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"重复的群名称" message:@"请重新输入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                
                [alertView show];
                [alertView release];
                return;
            }
        }
        
        [self.myGroupListData setObject:name forKey:name];
        [self.myGroupListData writeToFile:self.plistPath atomically:YES];
        self.myGroupListSections = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        [self.tableView reloadData];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString* nameString =  [[@"GroupList_" stringByAppendingString:name] stringByAppendingString:@".plist"];
        NSString *memberPath = [documentsPath stringByAppendingPathComponent:nameString];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:memberPath])
            [[NSFileManager defaultManager]  createFileAtPath:memberPath contents:nil attributes:nil];
    }
}

-(void)addGroup:(id)sender
{
    self.groupNameAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"群组名称", @"") message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"OK", @""), nil];
    [self.groupNameAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    self.groupNameAlertView.tag = groupNameAlertViewTag;
    //becoming the delegate for the input text field
    [[self.groupNameAlertView textFieldAtIndex:0] setDelegate:self.groupNameAlertView];
    [self.groupNameAlertView show];
}

- (void) addAndRefreshTableView:(NSNotification *) notification
{
    NSArray *nums = [notification object];
    NSString* numberString = [nums componentsJoinedByString:@""];//数组切成字符串
    NSString* nameString = nil;
    
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString* groupplistPath = [documentsPath stringByAppendingPathComponent:@"GroupList.plist"];
    
    NSMutableDictionary *dict;
    if (![[NSFileManager defaultManager] fileExistsAtPath:groupplistPath])
    {
        nameString = [NSString stringWithString:numberString];
    }
    else
    {
        //Load the file in a dictionnary
        dict = [[NSMutableDictionary alloc] initWithContentsOfFile:groupplistPath];
        if (dict == nil) {
            nameString = [NSString stringWithString:numberString];
        }
        else
        {
            //通过KEY找到value
            NSObject *object = [dict objectForKey:numberString];
            
            if (object != nil) {
                NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
                nameString = [dataForSection componentsJoinedByString:@""];//数组切成字符串
            }
            else
            {
                nameString = [NSString stringWithString:numberString];
            }
        }
        [dict release];
    }
    
    if ([[notification name] isEqualToString:@"SaveToGroupCallNotification"]) {
        [self.myGroupListData setObject:nameString forKey:numberString];
        [self.myGroupListData writeToFile:self.plistPath atomically:YES];
        self.myGroupListSections = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        
        [self.tableView reloadData];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString* nameString2 =  [[@"GroupList_" stringByAppendingString:nameString] stringByAppendingString:@".plist"];
        NSString *memberPath = [documentsPath stringByAppendingPathComponent:nameString2];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:memberPath])
        [[NSFileManager defaultManager]  createFileAtPath:memberPath contents:nil attributes:nil];
    }
}

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
            [self addGroupByName:textfield.text];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (isSearchOn) {
        return 1;  // 进入搜索状态，只有一个节点
    }
    else
    {
        return [self.myGroupListSections count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (isSearchOn)
    {
        return [searchResult count];  // 搜索结果的数量
    }
    else
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
    if (isSearchOn)
    {
        return  nil;
    }
    else
    {
        return  nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    static NSString *CellIdentifier = @"Cell";
    
    MyCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[MyCustomTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    if (isSearchOn)
    {
        NSString *title = [searchResult objectAtIndex:indexPath.row];
        cell.textLabel.text = title;
    }
    else
    {
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        
        NSString *key = [self.myGroupListSections objectAtIndex:section];
        //通过KEY找到value
        NSObject *object = [self.myGroupListData objectForKey:key];
        NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
        cell.textLabel.text = [dataForSection objectAtIndex:row];
    }
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
        NSString *mykey = key;
        [self.myGroupListData removeObjectForKey:key];
        NSArray *dicoArray = [[self.myGroupListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        [self.myGroupListData writeToFile:self.plistPath atomically:YES];
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString* nameString =  [[@"GroupList_" stringByAppendingString:mykey] stringByAppendingString:@".plist"];
        if(nameString)
        {
            NSString* plistPath = [documentsPath stringByAppendingPathComponent:nameString];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:plistPath error:nil];
        }
        self.myGroupListSections = dicoArray;
        [tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.myGroupListSections objectAtIndex:[indexPath section]];
    detail = [[GroupCreateTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    detail.groupName = key;
    [self.navigationController pushViewController:detail animated:NO];
    [detail release];
    
}

@end
