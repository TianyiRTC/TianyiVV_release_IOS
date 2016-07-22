//
//  RoyaDialView.m
//  Test
//
//  Created by royasoft on 12-12-5.
//  Copyright (c) 2012年 royasoft. All rights reserved.
//

#import "RoyaDialView.h"
#import "RoyaDialViewDelegate.h"

#define CONFIGURE_BUTTON(BTN,X,Y,TITLE,TAG) {\
                                    self.BTN = [UIButton buttonWithType:UIButtonTypeCustom];\
                                    [self.BTN setFrame:CGRectMake(X, Y, widthOfButton, heightOfButton)];\
                                    [self.BTN setShowsTouchWhenHighlighted:YES];\
                                    [self.BTN setTintColor:[UIColor whiteColor]];\
                                    [self.BTN setBackgroundColor:[UIColor darkGrayColor]];\
                                    [self.BTN setTag:TAG];\
                                    [self.BTN addTarget:self action:@selector(onKeyPressed:) \
                                                forControlEvents:UIControlEventTouchUpInside];\
                                    [self addSubview:self.BTN];\
                                   }

#define PULL_DOWN_OFFSET 5.0

#define TAG_KEY_DIAL     111

#define TAG_KEY_DIAL_VIDEO     222

#define TAG_KEY_DIAL_RANDOM     333

#define TAG_KEY_UNDO     444

#define TAG_KEY_COMMA     555



//private
@interface RoyaDialView(private)

-(void)setLayOn:(BOOL) isLayOn;

-(void)handleAudioCall:(NSString *) phoneNum;
-(void)handleVideoCall:(NSString *) phoneNum;
-(void)handleRandomCall:(NSString *) phoneNum;


-(void)postAudioCall:(NSString *) phoneNum;
-(void)postVideoCall:(NSString *) phoneNum;
-(void)postRandomCall:(NSString *) phoneNum;


@end

@implementation RoyaDialView(private)

-(void)setLayOn:(BOOL)isLayOn
{
    if (isLayOn == YES) {
        self.hidden = NO;
    }
    else
        self.hidden = YES;
}

- (void) postAudioCall:(NSString *) phoneNum
{
    NSArray *num = [NSArray arrayWithObjects:phoneNum,nil];

    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"AudioCallNotification"
     object:num];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToRecentCallNotification"
     object:num];
    
}

- (void) postVideoCall:(NSString *) phoneNum
{
    NSArray *num = [NSArray arrayWithObjects:phoneNum,nil];
    
    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"VideoCallNotification"
     object:num];
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SaveToRecentCallNotification"
     object:num];
    
}

- (void) postRandomCall:(NSString *) phoneNum
{
    // All instances of TestClass will be notified
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RandomCallNotification"
     object:nil];
}

-(void)handleAudioCall:(NSString *) phoneNum
{
    if(phoneNum.length){
        if ([self.delegate  respondsToSelector:@selector(onDialView:makePhoneCall:)]) {
            [self.delegate onDialView:self makePhoneCall:phoneNum];
        }else{
            [self postAudioCall:phoneNum];
              }
    }
}

-(void)handleVideoCall:(NSString *) phoneNum
{
    if(phoneNum.length){
        if ([self.delegate  respondsToSelector:@selector(onDialView:makePhoneCall:)]) {
            [self.delegate onDialView:self makePhoneCall:phoneNum];
        }else{
            [self postVideoCall:phoneNum];
        }
    }
}

-(void)handleRandomCall:(NSString *) phoneNum
{
    if(phoneNum.length){
        if ([self.delegate  respondsToSelector:@selector(onDialView:makePhoneCall:)]) {
            [self.delegate onDialView:self makePhoneCall:phoneNum];
        }else{
            [self postRandomCall:phoneNum];
        }
    }
}

@end

//public
@implementation RoyaDialView
@synthesize mIsLayOn;
-(id)init
{
    CGRect frame = [[UIScreen mainScreen]applicationFrame];
    frame.size.height /= 1.2;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGFloat heightOfTextField = 40.0;
        CGFloat widthOfButtonOnOff = frame.size.width / 4.0;
        CGFloat verticalButtonNums = 6.0;
        CGFloat horizontalButtonNums = 3.0;


        self.btnOffOn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnOffOn setFrame:CGRectMake(frame.size.width - widthOfButtonOnOff, 0, widthOfButtonOnOff, heightOfTextField)];
        [self.btnOffOn setShowsTouchWhenHighlighted:YES];
        [self.btnOffOn setImage:[UIImage imageNamed:@"dial_num_12_normal.png"] forState:UIControlStateNormal];
        [self.btnOffOn addTarget:self
                       action:@selector(onButtonOnOffPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
        self.btnOffOn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [self addSubview:self.btnOffOn]; 
        
        self.txtNumber = [[UITextField alloc]initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      frame.size.width - self.btnOffOn.frame.size.width,
                                                                      heightOfTextField)];
        [self.txtNumber setBorderStyle:UITextBorderStyleRoundedRect];
        [self.txtNumber setEnabled:NO];
        [self.txtNumber setPlaceholder:@"号码:"];
        self.txtNumber.text = @"";
        self.txtNumber.delegate = self;
        [self addSubview:self.txtNumber];
        
        CGFloat heightOfButton = 10+frame.size.height / verticalButtonNums - heightOfTextField;
        CGFloat widthOfButton = frame.size.width / horizontalButtonNums;
        
        //configure the number key
        CONFIGURE_BUTTON(btn1, 0, heightOfTextField, @"1",1);
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"dial_num_1_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn2, widthOfButton , heightOfTextField, @"2",2);
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"dial_num_2_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn3, widthOfButton*2, heightOfTextField, @"3",3);
        [self.btn3 setBackgroundImage:[UIImage imageNamed:@"dial_num_3_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn4, 0, heightOfButton + heightOfTextField, @"4",4);
        [self.btn4 setBackgroundImage:[UIImage imageNamed:@"dial_num_4_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn5, widthOfButton, heightOfButton + heightOfTextField, @"5",5);
        [self.btn5 setBackgroundImage:[UIImage imageNamed:@"dial_num_5_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn6, widthOfButton*2, heightOfButton + heightOfTextField, @"6",6);
        [self.btn6 setBackgroundImage:[UIImage imageNamed:@"dial_num_6_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn7, 0, heightOfButton*2 + heightOfTextField, @"7",7);
        [self.btn7 setBackgroundImage:[UIImage imageNamed:@"dial_num_7_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn8, widthOfButton, heightOfButton*2 + heightOfTextField, @"8",8);
        [self.btn8 setBackgroundImage:[UIImage imageNamed:@"dial_num_8_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn9, widthOfButton*2, heightOfButton*2 + heightOfTextField, @"9",9);
        [self.btn9 setBackgroundImage:[UIImage imageNamed:@"dial_num_9_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btn0, widthOfButton, heightOfButton*3 + heightOfTextField, @"0",0);
        [self.btn0 setBackgroundImage:[UIImage imageNamed:@"dial_num_11_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btnDial,0,heightOfButton*3 + heightOfTextField, @"Dial",TAG_KEY_DIAL);
        [self.btnDial setBackgroundImage:[UIImage imageNamed:@"dial_num_10_normal.png"]
                             forState:UIControlStateNormal];
        
        CONFIGURE_BUTTON(btnDialVideo,widthOfButton*2,heightOfButton*3 + heightOfTextField, @"DialVideo",TAG_KEY_DIAL_VIDEO);
        [self.btnDialVideo setBackgroundImage:[UIImage imageNamed:@"dial_num_13_normal.png"]
                                forState:UIControlStateNormal];
        
        mIsLayOn = YES;
        [self setLayOn:mIsLayOn];
        self.backgroundColor = [UIColor darkGrayColor];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)onKeyPressed:(id)sender
{
   NSInteger tag = [sender tag];
    NSString *text = self.txtNumber.text;
    switch (tag) {
       case TAG_KEY_DIAL:
            [self handleAudioCall:text];
            break;
        case TAG_KEY_DIAL_VIDEO:
            [self handleVideoCall:text];
            break;
        case TAG_KEY_DIAL_RANDOM:
            [self handleRandomCall:text];
            break;
       case TAG_KEY_UNDO:
            if (text.length) {
                 self.txtNumber.text = @"";
            }
            break;
        case TAG_KEY_COMMA:
            self.txtNumber.text = [NSString stringWithFormat:@"%@,",text];
            break;
       default:
            self.txtNumber.text = [NSString stringWithFormat:@"%@%d",text,tag];//前面的输入加上现在的输入等于更新后的总的输入
            break;
    }
    if ([self.delegate respondsToSelector:@selector(onDialView:dialNumber:withKey:)]) {
        [self.delegate onDialView:self dialNumber:text withKey:tag];
    }
    
}

-(void)onButtonOnOffPressed:(id)sender
{
    if (self.txtNumber.text.length) {
        self.txtNumber.text = @"";
    }
}

-(void)dealloc
{
    [self.btn0 release];
    [self.btn1 release];
    [self.btn2 release];
    [self.btn3 release];
    [self.btn4 release];
    [self.btn5 release];
    [self.btn6 release];
    [self.btn7 release];
    [self.btn8 release];
    [self.btn9 release];
    [self.btnDial release];
    [self.btnDialVideo release];
    [self.btnDialRandom release];
    [self.btnComma release];
    [self.btnUndo release];
    [super dealloc];
}

-(void)showInView:(UIView *)view
{
    CGPoint center = self.center;
    center.y += view.frame.size.height * 0.38;
    self.center = center;
    [view addSubview:self];
}

#pragma Delegate

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    mIsLayOn ? (mIsLayOn = NO) : (mIsLayOn = YES);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [self setLayOn:mIsLayOn];
    [UIView commitAnimations];
    self.txtNumber.text = @"";
}

@end