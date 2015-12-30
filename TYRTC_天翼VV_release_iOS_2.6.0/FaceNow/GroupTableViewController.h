//
//  GroupTableViewController.h
//  FaceNow
//
//  Created by administration on 14-10-16.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCreateTableViewController.h"

@interface GroupTableViewController : UITableViewController
@property (nonatomic, retain) UIAlertView *groupNameAlertView;
@property (nonatomic, retain) NSString *plistPath;
@property (nonatomic, retain) NSMutableDictionary *myGroupListData;
@property (nonatomic, retain) NSArray *myGroupListSections;
// 属性：搜索框
@property (nonatomic,retain) UISearchBar *searchBar;
@property(strong,nonatomic) GroupCreateTableViewController *detail;
// 方法：搜索contact list列表
-(void) searchGroupListTableView;
@end
