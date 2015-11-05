//
//  RoyaDialView.h
//  Test
//
//  Created by royasoft on 12-12-5.
//  Copyright (c) 2012年 royasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RoyaDialViewDelegate;

@interface RoyaDialView : UIView<UITextFieldDelegate>

@property(assign,nonatomic) BOOL mIsLayOn;

@property(strong,nonatomic) id<RoyaDialViewDelegate> delegate;

@property(strong,nonatomic) UIButton *btnOffOn;

@property(strong,nonatomic) UITextField *txtNumber;

@property(strong,nonatomic) UIButton *btn0;

@property(strong,nonatomic) UIButton *btn1;

@property(strong,nonatomic) UIButton *btn2;

@property(strong,nonatomic) UIButton *btn3;

@property(strong,nonatomic) UIButton *btn4;

@property(strong,nonatomic) UIButton *btn5;

@property(strong,nonatomic) UIButton *btn6;

@property(strong,nonatomic) UIButton *btn7;

@property(strong,nonatomic) UIButton *btn8;

@property(strong,nonatomic) UIButton *btn9;

@property(strong,nonatomic) UIButton *btnDial;

@property(strong,nonatomic) UIButton *btnDialVideo;

@property(strong,nonatomic) UIButton *btnDialRandom;

@property(strong,nonatomic) UIButton *btnComma;

@property(strong,nonatomic) UIButton *btnUndo;

-(IBAction)onKeyPressed:(id)sender;

-(IBAction)onButtonOnOffPressed:(id)sender;

-(void)showInView:(UIView *)view;

@end
