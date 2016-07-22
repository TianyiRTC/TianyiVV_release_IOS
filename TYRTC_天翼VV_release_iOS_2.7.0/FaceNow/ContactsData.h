//
//  ContactsData.h
//  FaceNow
//
//  Created by administration on 14-9-30.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ContactsData : NSObject
@property (strong, nonatomic) NSMutableArray *numbers;
@property (strong, nonatomic) NSMutableArray *emails;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *firstNames;
@property (strong, nonatomic) NSString *lastNames;
@end
