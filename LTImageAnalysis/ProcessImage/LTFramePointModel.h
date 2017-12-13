//
//  LTFramePointModel.h
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTFramePointModel : NSObject

// Corner Point
@property (nonatomic, assign) CGPoint leftTopPoint;
@property (nonatomic, assign) CGPoint rightTopPoint;
@property (nonatomic, assign) CGPoint leftBottomPoint;
@property (nonatomic, assign) CGPoint rightBottomPoint;

//Middle Point
@property (nonatomic, assign) CGPoint leftCenterPoint;
@property (nonatomic, assign) CGPoint rightCenterPoint;
@property (nonatomic, assign) CGPoint topCenterPoint;
@property (nonatomic, assign) CGPoint bottomCenterPoint;

- (LTFramePointModel *)toScale:(CGFloat)scale;

@end
