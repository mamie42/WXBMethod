//
//  UIView+WXAlterView.m
//  WXBMethodDemo
//
//  Created by mamie on 17/5/17.
//  Copyright © 2017年 mamie. All rights reserved.
//
#define wxRgb(r, g, b, a)       [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define wxLineColor  wxRgb(224, 224, 227,1).CGColor
#define wxConWidth   self.frame.size.width*0.8
#define wxBntHeight  50
#define wxPadding    10
#import "WXAlterView.h"


static WXAlterView *alterView=nil;
static dispatch_once_t onceToken;

typedef void(^buttonAction)(void) ;
@interface AlterButton :NSObject;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, copy)buttonAction actionHandler;
@property(nonatomic,strong)UIWindow  *window;
@end
@implementation AlterButton
@end


@interface WXAlterView()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) NSMutableArray<AlterButton*> *buttons;
@end

@implementation WXAlterView
+(WXAlterView*)shareAlterView{
    dispatch_once(&onceToken, ^{
        if(alterView==nil){
            alterView=[[self alloc]init];
            alterView.backgroundColor=wxRgb(0, 0, 0, 0.3);
        }
    });
    return alterView;
}
+(void)showAlterWithTitle:(NSString *)title message:(NSString *)message action:(void(^)(void))action{
    [[self shareAlterView] showTitle:title message:message];
    [[self shareAlterView] addBtnWithTitle:@"确认" handler:^{
        if(action)action();
        [[self shareAlterView] hide];
    }];
    [[self shareAlterView] show];
}
+(void)showAlterWithTitle:(NSString *)title message:(NSString *)message  buttonTitles:(NSArray <NSString *>*)buttonTitles actionWithIndex:(void(^)(NSInteger index))action{
     [[self shareAlterView] showTitle:title message:message];
    if(buttonTitles.count>0){
        for (int i = 0; i < buttonTitles.count; i ++) {
            [[self shareAlterView] addBtnWithTitle:buttonTitles[i] handler:^{
                if(action)action(i);
                [[self shareAlterView] hide];
            }];
        }
    }
    [[self shareAlterView] show];
}
+(void)showAlterFieldWith:(NSString*)title placeholder:(NSString*)placeholder action:(void(^)(NSString*string))action{
   [[self shareAlterView] showTitle:title message:nil];
   [self shareAlterView].textField.placeholder=placeholder;
    [[self shareAlterView] addBtnWithTitle:@"取消" handler:^{
        [[self shareAlterView] hide];
    }];
    [[self shareAlterView] addBtnWithTitle:@"确认" handler:^{
        if(action)action([self shareAlterView].textField.text);
          [[self shareAlterView] hide];
    }];
    [[self shareAlterView] show];
    
}
+(void)hideAlterField{
      [[self shareAlterView] hide];
}
-(void)showTitle :(NSString *)title message:(NSString *)message{
    self.frame=[UIScreen mainScreen].bounds;
    self.backgroundColor=wxRgb(0, 0, 0, 0.3);
    if(title){
        self.titleLabel.text = title;
    }
    if(message){
        self.messageLabel.text=message;
    }
}
-(void)didMoveToSuperview{
    [self updataUIFrame];
}
-(void)updataUIFrame{
    CGSize size=CGSizeZero;
    if(_titleLabel){
        size= [_titleLabel sizeThatFits:CGSizeMake(wxConWidth,30)];
        _titleLabel.frame=CGRectMake(wxPadding,wxPadding,wxConWidth-2*wxPadding,size.height);
    }
    if(_messageLabel){
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_messageLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing =5;
        [string addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, _messageLabel.text.length)];
        _messageLabel.attributedText = string;
        
        size= [_messageLabel sizeThatFits:CGSizeMake(wxConWidth,30)];
        _messageLabel.frame=CGRectMake(wxPadding,CGRectGetMaxY(_titleLabel.frame)+wxPadding,wxConWidth-2*wxPadding,size.height);
    }
    if(_textField){
        _textField.frame=CGRectMake(wxPadding,CGRectGetMaxY(_titleLabel.frame)+wxPadding,wxConWidth-2*wxPadding,40);
    }
    
    CGFloat topHeight=wxPadding;
    if(_titleLabel){
        topHeight=CGRectGetMaxY(_titleLabel.frame)+wxPadding;
    }
    if(_messageLabel){
        topHeight=CGRectGetMaxY(_messageLabel.frame)+wxPadding;
    }
    if(_textField){
        topHeight=CGRectGetMaxY(_textField.frame)+wxPadding;
    }
    if(_buttons.count==1||_buttons.count>=3){
        for (int i=0; i<_buttons.count; i++) {
            [self drawLineLayer:topHeight];
            AlterButton *btnModel=_buttons[i];
            UIButton *button=btnModel.button;
            button.frame=CGRectMake(0, topHeight+1,wxConWidth, wxBntHeight);
            topHeight=CGRectGetMaxY(button.frame);
            if(_buttons.count==1){
                [button setTitleColor:wxRgb(30,132,251,1) forState:UIControlStateNormal];
            }
        }
        _contentView.frame=CGRectMake(0, 0,wxConWidth,topHeight);
    }else{
        [self drawLineLayer:topHeight];
        //竖线 #2188fb  21 26  215
        CALayer *lineLayer2 = [CALayer layer];
        lineLayer2.backgroundColor = wxLineColor;
        lineLayer2.frame = CGRectMake(wxConWidth/2.0, topHeight+1, 1, wxBntHeight);
        [_contentView.layer addSublayer:lineLayer2];
        for (int i=0; i<_buttons.count; i++) {
            AlterButton *btnModel=_buttons[i];
            UIButton *button=btnModel.button;
            button.frame=CGRectMake(wxConWidth/2.0*i, topHeight+1,wxConWidth/2.0, wxBntHeight);
            if(i==1){
                [button setTitleColor:wxRgb(30,132,251,1) forState:UIControlStateNormal];
            }
        }
        _contentView.frame=CGRectMake(0, 0,wxConWidth,topHeight+1+wxBntHeight);
    }
    _contentView.center=self.center;
}
- (void) addBtnWithTitle:(NSString *)title handler:(void((^)(void)))handler{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 1000+self.buttons.count;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:wxRgb(144, 144, 144, 1) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:button];
    
    AlterButton *btnModel = [AlterButton new];
    btnModel.button = button;
    btnModel.actionHandler = handler;
    [_buttons addObject:btnModel];
}
-(void)btnAction:(UIButton*)sender{
    NSInteger index = sender.tag-1000;
    AlterButton *model = _buttons[index];
    buttonAction handler = model.actionHandler;
    if (handler) handler();
    [self hide];
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self hide];
}
-(void)show{
    UIViewController *root=[UIApplication sharedApplication].keyWindow.rootViewController;
    if(root.presentedViewController){
        [root.presentedViewController.view addSubview:self];
    }else{
        [root.view addSubview:self];
    }
}
-(void)hide{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    }];
    [UIView animateWithDuration:0.2 animations:^{
        _contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    onceToken = 0;
    alterView=nil;
}
//横线
-(void)drawLineLayer:(CGFloat)top{
    CALayer *lineLayer=[CALayer layer];
    lineLayer.backgroundColor=wxLineColor;
    lineLayer.frame=CGRectMake(0, top, wxConWidth, 1);
    [_contentView.layer addSublayer:lineLayer];
}
-(UIView*)contentView{
    if(!_contentView){
        _contentView=[[UIView alloc]init];
        _contentView.backgroundColor=[UIColor whiteColor];
        _contentView.layer.cornerRadius=10;
        _contentView.layer.masksToBounds=YES;
        _contentView.clipsToBounds=YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}
-(UILabel*)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.numberOfLines = 0;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}
-(UILabel*)messageLabel{
    if(!_messageLabel){
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_messageLabel];
    }
    return _messageLabel;
}
-(UITextField*)textField{
    if(!_textField){
        _textField=[[UITextField alloc]init];
        _textField.layer.cornerRadius=8;
        _textField.delegate=self;
        _textField.layer.borderColor=[UIColor lightGrayColor].CGColor;
        _textField.layer.borderWidth=1;
        _textField.font=[UIFont systemFontOfSize:15];
        [self.contentView addSubview:_textField];
    }
    return _textField;
}
-(NSMutableArray*)buttons{
    if(!_buttons){
        _buttons=[NSMutableArray array];
    }
    return _buttons;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
