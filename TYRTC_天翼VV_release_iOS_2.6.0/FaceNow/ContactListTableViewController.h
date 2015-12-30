//
//  ContactListTableViewController.h
//  FaceNow
//
//  Created by administration on 14-10-17.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactListTableViewController : UITableViewController<UISearchBarDelegate,UISearchDisplayDelegate>
-(NSArray *)getAllContacts;
-(NSString*)formatNumber:(NSString*)mobileNumber;

// 属性：搜索框
@property (nonatomic,retain) UISearchBar *searchBar;
@property (nonatomic, retain)UISearchDisplayController *searchController;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) IBOutlet UILabel* mGroupConduct;

// 方法：搜索contact list列表
-(void) searchContactsListTableView;

@property (nonatomic, retain) NSString *plistPath;
@property (nonatomic, retain) NSMutableDictionary *myContactListData;
@property (nonatomic, retain) NSArray *myContactListSections;

@end
