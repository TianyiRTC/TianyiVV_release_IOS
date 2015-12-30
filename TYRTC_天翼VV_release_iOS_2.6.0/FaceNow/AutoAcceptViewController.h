//
//  AudioCodecTableViewController.h
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AutoAcceptViewController : UITableViewController<UINavigationControllerDelegate>

@property(nonatomic,retain)NSIndexPath* autoAcceptSelected;
@property(nonatomic,retain)NSString* autoAccept;
@property (nonatomic, retain) NSMutableDictionary *autoAcceptParasListData;
@property (nonatomic, retain) NSArray *autoAcceptParasListSections;

@property (nonatomic, retain) NSMutableDictionary *autoAcceptListData;
@property (nonatomic, retain) NSArray *autoAcceptListSections;
- (void) setAutoInfo:(NSString*)codec;
@end
