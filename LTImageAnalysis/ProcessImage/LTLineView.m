//
//  LTLineView.m
//  LTImageAnalysis
//
//  Created by Alicia on 2017/11/1.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import "LTLineView.h"
#import "CommonDefine.h"
#import "UIImageView+LTAddtions.h"
#import "UIView+LTAddtions.h"

@implementation LTLineView


#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.frame.size.height - kLineHeight) / 2, self.frame.size.width, kLineHeight)];
    lineView.backgroundColor = MAIN_COLOR;
    [self addSubview:lineView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kLineDelButtonWH, kLineDelButtonWH)];
    button.backgroundColor = [UIColor redColor];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = kLineDelButtonWH / 2;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:@"一" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];

    
    // To make lineView positon right 
    CGRect frame = self.frame;
    frame.origin.y -= kLineViewHeight / 2;
    self.frame = frame;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(linePanGesture:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - Gesture
- (void)linePanGesture:(UIPanGestureRecognizer *)gestureRecongizer {
    UIView *superView = self.superview;
    CGFloat superTop = 0;
    CGFloat superBottom = superView.bottom;
    if ([superView isKindOfClass:[UIImageView class]]) {
        UIImageView *superImageView = (UIImageView *)superView;
        CGRect imageFrame = [superImageView imageFrame];
        superTop = imageFrame.origin.y;
        superBottom = imageFrame.origin.y + imageFrame.size.height;
    }
    CGPoint point = [gestureRecongizer locationInView:self.superview];
    CGRect newFrame = gestureRecongizer.view.frame;
    CGFloat y = point.y;
    if (y < superTop) {
        y = superTop;
    } else if (y > superBottom) {
        y = superBottom;
    }
    y = y - newFrame.size.height / 2;
 
    newFrame.origin.y = y;
    gestureRecongizer.view.frame = newFrame;
}

#pragma mark - Actions
- (void)deleteAction:(id)sender {
    [self removeFromSuperview];
    
    if (self.delegate) {
        [self.delegate deleteLineWithTag:self.tag];
    }
}



@end
