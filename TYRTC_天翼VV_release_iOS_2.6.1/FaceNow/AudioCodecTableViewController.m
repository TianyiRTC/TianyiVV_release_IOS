//
//  AudioCodecTableViewController.m
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "AudioCodecTableViewController.h"
#import "MyInfoTableViewController.h"
#import "sdkobj.h"

@interface AudioCodecTableViewController ()

@end

@implementation AudioCodecTableViewController
@synthesize audioCodecSelected;
@synthesize audioCodec;
@synthesize audioCodecListData;
@synthesize audioCodecListSections;
@synthesize audioParasListData;
@synthesize audioParasListSections;

/**********************************设置音频编解码*************************************/
- (void) setAudioInfo:(NSString*)codec
{
    self.audioCodec = [NSString stringWithString:codec];
    
    if ([codec isEqualToString:@"OPUS"]) {
        self.audioCodecSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if ([codec isEqualToString:@"iLBC"]) {
        self.audioCodecSelected = [NSIndexPath indexPathForRow:1 inSection:0];
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
    self.audioCodecListData = dict;
    [self.audioCodecListData setObject:@"iLBC" forKey:@"iLBC"];
    [self.audioCodecListData setObject:@"OPUS" forKey:@"OPUS"];
    //[self.audioCodecListData setObject:@"iSAC" forKey:@"iSAC"];
    
    NSArray *dicoArray = [[self.audioCodecListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.audioCodecListSections = dicoArray;
    //创建词典对象，初始化长度为10
    self.audioParasListData = [NSMutableDictionary dictionaryWithCapacity:2];
    [self.audioParasListData setObject:@"Codec" forKey:@"Codec"];
    self.audioParasListSections = [[self.audioParasListData allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[MyInfoTableViewController class]]) {
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"params",
                                [NSNumber numberWithInt:MSG_UPDATE_AUDIO_CODEC],@"msgid",
                                [NSNumber numberWithInt:0],@"arg",
                                self.audioCodec,@"audioCodec",
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
    return [self.audioParasListSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSString *key = [self.audioParasListSections objectAtIndex:section];
    NSInteger i = 0;
    //通过KEY找到value
    if ([key isEqualToString:@"Codec"]) {
        for (id akey in [self.audioCodecListData allKeys]) {
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
    NSString *string1 = [self.audioParasListSections objectAtIndex:section];
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
    
    NSString *key = [self.audioParasListSections objectAtIndex:section];
    //通过KEY找到value
    NSObject *object = nil;
    if ([key isEqualToString:@"Codec"]) {
        NSString *k = [self.audioCodecListSections objectAtIndex:row];
        object = [self.audioCodecListData objectForKey:k];
        int selectedRow = (self.audioCodecSelected != nil) ? [self.audioCodecSelected row] : -1;
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
    
    NSString *key = [self.audioParasListSections objectAtIndex:section];
    //通过KEY找到value
    if ([key isEqualToString:@"Codec"]) {
        int oldRow = (self.audioCodecSelected != nil) ? [self.audioCodecSelected row] : -1;
        if(newRow != oldRow)
        {
            UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.audioCodecSelected];
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            self.audioCodecSelected = indexPath;
            self.audioCodec = [NSString stringWithString:newCell.textLabel.text];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
