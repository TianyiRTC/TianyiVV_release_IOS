//
//  AudioCodecTableViewController.h
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioCodecTableViewController : UITableViewController<UINavigationControllerDelegate>

@property(nonatomic,retain)NSIndexPath* audioCodecSelected;
@property(nonatomic,retain)NSString* audioCodec;
@property (nonatomic, retain) NSMutableDictionary *audioParasListData;
@property (nonatomic, retain) NSArray *audioParasListSections;

@property (nonatomic, retain) NSMutableDictionary *audioCodecListData;
@property (nonatomic, retain) NSArray *audioCodecListSections;
- (void) setAudioInfo:(NSString*)codec;
@end
