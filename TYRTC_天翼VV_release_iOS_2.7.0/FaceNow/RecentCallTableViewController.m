//
//  RecentCallTableViewController.m
//  FaceNow
//
//  Created by administration on 14-10-14.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "RecentCallTableViewController.h"
#import "RoyaDialView.h"
#import "MyCustomTableViewCell.h"
#import "PersonalDetailTableViewController.h"
#import "sdkobj.h"

@interface RecentCallTableViewController ()

@end

@implementation RecentCallTableViewController
@synthesize royaDialView;
@synthesize plistPath;
@synthesize myRecentListData;
@synthesize myRecentListSections;

/**********************************初始化最近联系人列表*************************************/
- (void)commonInit
{
    //Create a string representing the file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    self.plistPath = [documentsPath stringByAppendingPathComponent:@"RecentCallList.plist"];
    
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
    
    self.myRecentListData = dict;
    NSArray *dicoArray = [[self.myRecentListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.myRecentListSections = dicoArray;
    ////////////////////////////////////////////////////////////////////////////
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addAndRefreshTableView:)
                                                 name:@"SaveToRecentCallNotification"
                                               object:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *image1 = [UIColor colorWithPatternImage:[UIImage imageNamed:@"activity_bg.jpg"]];
    [self.tableView setBackgroundColor:image1];

    royaDialView = [[RoyaDialView alloc]init];
    [royaDialView showInView:self.view];
    [self.view bringSubviewToFront:royaDialView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;//有数据的Cell才显示分割线，没有数据的不显示
    
    NSString* imageName =   [NSString stringWithFormat:@"icon_top_phone.png"];
    UIImage *image = [UIImage imageNamed:imageName];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(onButtonOnOffPressed:)];
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
}

#define PULL_DOWN_OFFSET 5.0
-(void)setLayOn:(BOOL)isLayOn
{
    if (isLayOn == YES) {
        self.royaDialView.hidden = NO;
    }
    else
        self.royaDialView.hidden = YES;
}

-(void)onButtonOnOffPressed:(id)sender
{
    self.royaDialView.mIsLayOn ? (self.royaDialView.mIsLayOn = NO) : (self.royaDialView.mIsLayOn = YES);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setLayOn:self.royaDialView.mIsLayOn];
    [UIView commitAnimations];
    self.royaDialView.txtNumber.text = @"";
}

- (void) addAndRefreshTableView:(NSNotification *) notification
{
    NSArray *nums = [notification object];
    NSString* numberString = [nums componentsJoinedByString:@""];//数组切成字符串
    NSString* nameString = [NSString stringWithString:numberString];
        
    if ([[notification name] isEqualToString:@"SaveToRecentCallNotification"]) {
        [self.myRecentListData setObject:nameString forKey:numberString];
        [self.myRecentListData writeToFile:self.plistPath atomically:YES];
        self.myRecentListSections = [[self.myRecentListData allKeys] sortedArrayUsingSelector:@selector(compare:)];

        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    CWLogDebug(@"%s:Mem will be max",__FUNCTION__);
    if(! self.view.window)
        self.view =nil;
}

/**********************************列表操作*************************************/
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.myRecentListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.myRecentListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = [self.myRecentListData objectForKey:key];
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
    
    if (dataForSection != nil) {
        return [dataForSection count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return  nil;
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
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.myRecentListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = [self.myRecentListData objectForKey:key];
    NSArray *dataForSection = [NSArray arrayWithObjects:object,nil];
    
    //cell.textLabel.text = [[dataForSection allKeys] objectAtIndex:row];
    cell.textLabel.text = [dataForSection objectAtIndex:row];
    NSString  *imageName = [NSString  stringWithFormat:@"icon.png"];
    cell.imageView.image  =  [UIImage  imageNamed:imageName];
    [cell setBackgroundColor:[UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1]];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.myRecentListSections objectAtIndex:[indexPath section]];
    
    PersonalDetailTableViewController *detail = [[PersonalDetailTableViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    detail.phoneNum = key;
    [self.navigationController pushViewController:detail animated:NO];
    [detail release];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSUInteger section = [indexPath section];
        NSString *key = [self.myRecentListSections objectAtIndex:section];
        [self.myRecentListData removeObjectForKey:key];
        NSArray *dicoArray = [[self.myRecentListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.myRecentListSections = dicoArray;
        [self.myRecentListData writeToFile:self.plistPath atomically:YES];
        [tableView reloadData];
    }
}

@end
