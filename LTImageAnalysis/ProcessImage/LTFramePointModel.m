//
//  LTFramePointModel.m
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTFramePointModel.h"

@implementation LTFramePointModel


- (LTFramePointModel *)toScale:(CGFloat)scale {
    LTFramePointModel *pointModel = [[LTFramePointModel alloc] init];
    pointModel.leftTopPoint = CGPointMake(self.leftTopPoint.x / scale, self.leftTopPoint.y / scale);
    pointModel.leftBottomPoint = CGPointMake(self.leftBottomPoint.x / scale, self.leftBottomPoint.y / scale);
    pointModel.rightTopPoint = CGPointMake(self.rightTopPoint.x / scale, self.rightTopPoint.y / scale);
    pointModel.rightBottomPoint = CGPointMake(self.rightBottomPoint.x / scale, self.rightBottomPoint.y / scale);
    return pointModel;
}


@end
