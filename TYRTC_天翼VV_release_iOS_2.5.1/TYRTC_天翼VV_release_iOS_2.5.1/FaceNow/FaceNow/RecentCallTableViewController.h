//
//  RecentCallTableViewController.h
//  FaceNow
//
//  Created by administration on 14-10-14.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RoyaDialView;

@interface RecentCallTableViewController : UITableViewController
@property(retain,nonatomic) RoyaDialView *royaDialView;

@property (nonatomic, retain) NSString *plistPath;
@property (nonatomic, retain) NSMutableDictionary *myRecentListData;
@property (nonatomic, retain) NSArray *myRecentListSections;

- (void)commonInit;

@end
