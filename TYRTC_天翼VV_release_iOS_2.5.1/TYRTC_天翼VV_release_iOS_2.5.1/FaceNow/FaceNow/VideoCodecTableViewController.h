//
//  VideoCodecTableViewController.h
//  FaceNow
//
//  Created by administration on 14/11/4.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCodecTableViewController : UITableViewController<UINavigationControllerDelegate>
@property(nonatomic,retain)NSIndexPath* videoCodecSelected;
@property(nonatomic,retain)NSIndexPath* videoResolutionSelected;
@property(nonatomic,retain)NSString* videoCodec;
@property(nonatomic,retain)NSString* videoResolution;

@property (nonatomic, retain) NSMutableDictionary *videoParasListData;
@property (nonatomic, retain) NSArray *videoParasListSections;

@property (nonatomic, retain) NSMutableDictionary *videoCodecListData;
@property (nonatomic, retain) NSArray *videoCodecListSections;

@property (nonatomic, retain) NSMutableDictionary *videoResolutionListData;
@property (nonatomic, retain) NSArray *videoResolutionListSections;

- (void) setVideoInfo:(NSString*) codec resolution:(NSString*) reso;

@end
