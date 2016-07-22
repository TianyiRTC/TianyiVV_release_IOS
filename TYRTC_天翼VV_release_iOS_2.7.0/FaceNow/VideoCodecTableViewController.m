//
//  VideoCodecTableViewController.m
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "VideoCodecTableViewController.h"
#import "MyInfoTableViewController.h"
#import "sdkobj.h"

@interface VideoCodecTableViewController ()

@end

@implementation VideoCodecTableViewController
@synthesize videoCodecSelected;
@synthesize videoResolutionSelected;
@synthesize videoCodec;
@synthesize videoResolution;
@synthesize videoCodecListData;
@synthesize videoCodecListSections;
@synthesize videoParasListData;
@synthesize videoParasListSections;
@synthesize videoResolutionListData;
@synthesize videoResolutionListSections;

/**********************************设置视频编解码*************************************/
- (void) setVideoInfo:(NSString*) codec resolution:(NSString*) reso
{
    self.videoCodec = [NSString stringWithString:codec];
    self.videoResolution = [NSString stringWithString:reso];

    if ([codec isEqualToString:@"H264"]) {
        self.videoCodecSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        self.videoCodecSelected = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    if ([reso isEqualToString:@"流畅"]) {
        self.videoResolutionSelected = [NSIndexPath indexPathForRow:0 inSection:1];
      }
        else if ([reso isEqualToString:@"标清"]) {
        self.videoResolutionSelected = [NSIndexPath indexPathForRow:1 inSection:1];
    }
        else if ([reso isEqualToString:@"高清"]) {
        self.videoResolutionSelected = [NSIndexPath indexPathForRow:2 inSection:1];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;

    self.tableView=[[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] autorelease];
    
    NSMutableDictionary *dict;
    //创建词典对象，初始化长度为10
    dict = [NSMutableDictionary dictionaryWithCapacity:2];
    self.videoCodecListData = dict;
    [self.videoCodecListData setObject:@"VP8" forKey:@"VP8"];
    [self.videoCodecListData setObject:@"H264" forKey:@"H264"];
    NSArray *dicoArray = [[self.videoCodecListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.videoCodecListSections = dicoArray;
    
    //创建词典对象，初始化长度为10
    dict = [NSMutableDictionary dictionaryWithCapacity:2];
    self.videoResolutionListData = dict;
    [self.videoResolutionListData setObject:@"流畅" forKey:@"1.QCIF"];
    [self.videoResolutionListData setObject:@"标清" forKey:@"3.CIF"];
    [self.videoResolutionListData setObject:@"高清" forKey:@"5.4CIF"];

    dicoArray = [[self.videoResolutionListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.videoResolutionListSections = dicoArray;
    
    //创建词典对象，初始化长度为10
    self.videoParasListData = [NSMutableDictionary dictionaryWithCapacity:2];
    [self.videoParasListData setObject:@"Codec" forKey:@"Codec"];
    //[self.videoParasListData setObject:@"Resolution" forKey:@"Resolution"];
    
    self.videoParasListSections = [[self.videoParasListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[MyInfoTableViewController class]]) {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_UPDATE_VIDEO_CODEC],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                self.videoCodec,@"videoCodec",
                                self.videoResolution,@"videoResolution",
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
    return [self.videoParasListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.videoParasListSections objectAtIndex:section];
    NSInteger i = 0;
    //通过KEY找到value
    if ([key isEqualToString:@"Codec"]) {
        for (id akey in [self.videoCodecListData allKeys]) {
            i++;
        }
    } else if ([key isEqualToString:@"Resolution"]) {
        for (id akey in [self.videoResolutionListData allKeys]) {
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
    NSString *string1 = [self.videoParasListSections objectAtIndex:section];
    return [NSString stringWithFormat:@"%@", string1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    // Configure the cell...
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.videoParasListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = nil;
    if ([key isEqualToString:@"Codec"]) {
        NSString *k = [self.videoCodecListSections objectAtIndex:row];
        object = [self.videoCodecListData objectForKey:k];
        int selectedRow = (self.videoCodecSelected != nil) ? [self.videoCodecSelected row] : -1;
        if(row == selectedRow)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    } else if ([key isEqualToString:@"Resolution"]) {
        NSString *k = [self.videoResolutionListSections objectAtIndex:row];
        object = [self.videoResolutionListData objectForKey:k];
        int selectedRow = (self.videoResolutionSelected != nil) ? [self.videoResolutionSelected row] : -1;
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
    
    NSString *key = [self.videoParasListSections objectAtIndex:section];
    //通过KEY找到value
    if ([key isEqualToString:@"Codec"]) {
        int oldRow = (self.videoCodecSelected != nil) ? [self.videoCodecSelected row] : -1;
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.videoCodecSelected];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.videoCodecSelected = indexPath;
            self.videoCodec = [NSString stringWithString:newCell.textLabel.text];
        }
    } else if ([key isEqualToString:@"Resolution"]) {
        int oldRow = (self.videoResolutionSelected != nil) ? [self.videoResolutionSelected row] : -1;
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.videoResolutionSelected];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.videoResolutionSelected = indexPath;
            self.videoResolution = [NSString stringWithString:newCell.textLabel.text];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
