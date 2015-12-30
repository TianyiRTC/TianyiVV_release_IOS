//
//  AudioCodecTableViewController.m
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "AutoAcceptViewController.h"
#import "MyInfoTableViewController.h"
#import "sdkobj.h"

@interface AutoAcceptViewController ()

@end

@implementation AutoAcceptViewController
@synthesize autoAcceptSelected;
@synthesize autoAccept;
@synthesize autoAcceptListData;
@synthesize autoAcceptListSections;
@synthesize autoAcceptParasListData;
@synthesize autoAcceptParasListSections;

/**********************************设置音频编解码*************************************/
- (void) setAutoInfo:(NSString*)codec
{
    self.autoAccept = [NSString stringWithString:codec];
    
    if ([codec isEqualToString:@"NO"]) {
        self.autoAcceptSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if ([codec isEqualToString:@"YES"]) {
        self.autoAcceptSelected = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    //    else if ([codec isEqualToString:@"iSAC"]) {
    //        self.audioCodecSelected = [NSIndexPath indexPathForRow:2 inSection:0];
    //    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    self.tableView=[[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    
    NSMutableDictionary *dict;
    //创建词典对象，初始化长度为10
    dict = [NSMutableDictionary dictionaryWithCapacity:2];
    self.autoAcceptListData = dict;
    [self.autoAcceptListData setObject:@"NO" forKey:@"AUTONO"];
    [self.autoAcceptListData setObject:@"YES" forKey:@"AUTOYES"];
    
    NSArray *dicoArray = [[self.autoAcceptListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.autoAcceptListSections = dicoArray;
    //创建词典对象，初始化长度为10
    self.autoAcceptParasListData = [NSMutableDictionary dictionaryWithCapacity:2];
    [self.autoAcceptParasListData setObject:@"AUTOACCEPT" forKey:@"AUTOACCEPT"];
    self.autoAcceptParasListSections = [[self.autoAcceptParasListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[MyInfoTableViewController class]]) {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_UPDATE_AUTOACCEPT],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                self.autoAccept,@"autoaccept",
                                nil];
        [[NSNotificationCenter defaultCenter]  postNotificationName:@"MYINFO_EVENT" object:nil userInfo:params];
        
    }
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
    return [self.autoAcceptParasListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.autoAcceptParasListSections objectAtIndex:section];
    NSInteger i = 0;
    //通过KEY找到value
    if ([key isEqualToString:@"AUTOACCEPT"]) {
        for (id akey in [self.autoAcceptListData allKeys]) {
            i++;
        }
    } else {
        i = 0;
    }
    
    return i;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    NSString *string1 = [self.autoAcceptParasListSections objectAtIndex:section];
    return [NSString stringWithFormat:@"%@", string1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    // Configure the cell...
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.autoAcceptParasListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = nil;
    if ([key isEqualToString:@"AUTOACCEPT"]) {
        NSString *k = [self.autoAcceptListSections objectAtIndex:row];
        object = [self.autoAcceptListData objectForKey:k];
        int selectedRow = (self.autoAcceptSelected != nil) ? [self.autoAcceptSelected row] : -1;
        if(row == selectedRow)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else {
        object = nil;
    }
    
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
    cell.textLabel.text = [dataForSection objectAtIndex:0];
    cell.detailTextLabel.text =@"";
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    NSString  *imageName = [NSString  stringWithFormat:@"icon.png"];
    cell.imageView.image  =  [UIImage  imageNamed:imageName];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
    UIView* myView = [[[UIView alloc] init] autorelease];
    return myView;
}

#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger newRow = [indexPath row];
    
    NSString *key = [self.autoAcceptParasListSections objectAtIndex:section];
    //通过KEY找到value
    if ([key isEqualToString:@"AUTOACCEPT"]) {
        int oldRow = (self.autoAcceptSelected != nil) ? [self.autoAcceptSelected row] : -1;
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.autoAcceptSelected];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.autoAcceptSelected = indexPath;
            self.autoAccept = [NSString stringWithString:newCell.textLabel.text];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
