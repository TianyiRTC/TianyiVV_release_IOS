//
//  MyCustomTableViewCell.m
//  FaceNow
//
//  Created by administration on 14/11/14.
//  Copyright (c) 2014年 FaceNow. All rights reserved.
//

#import "MyCustomTableViewCell.h"

@implementation MyCustomTableViewCell


// 自绘分割线
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, rect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
}

@end
