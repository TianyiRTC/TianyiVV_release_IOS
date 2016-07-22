//
//  GroupCreateTableViewController.h
//  FaceNow
//
//  Created by administration on 14-10-16.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sdkkey.h"

@interface GroupCreateTableViewController : UITableViewController
@property (nonatomic, retain) NSString*   groupName;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) UIAlertView *groupNameAlertView;
@property (nonatomic, retain) NSString *plistPath;
@property (nonatomic, retain) NSMutableDictionary *myGroupListData;
@property (nonatomic, retain) NSArray *myGroupListSections;

@end
