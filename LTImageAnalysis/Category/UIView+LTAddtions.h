//
//  UIView+LTAddtions.h
//  LTImageAnalysis
//
//  Created by Alicia on 2017/10/28.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LTAddtions)

@property (nonatomic) CGFloat left;        //  frame.origin.x.
@property (nonatomic) CGFloat top;         //  frame.origin.y
@property (nonatomic) CGFloat right;       //  frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      //  frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       //  frame.size.width.
@property (nonatomic) CGFloat height;      //  frame.size.height.
@property (nonatomic) CGFloat centerX;     //  center.x
@property (nonatomic) CGFloat centerY;     //  center.y
@property (nonatomic) CGPoint origin;      //  frame.origin.
@property (nonatomic) CGSize  size;        //  frame.size.


- (UIImage *)convertViewToImageWithRect:(CGRect)rect;

@end
