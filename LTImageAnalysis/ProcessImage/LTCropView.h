//
//  LTCropView.h
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGeometry.h"
#import "LTFramePointModel.h"

#define kCropButtonSize         24

@interface LTCropView : UIView

@property (nonatomic, strong) UIView *activePoint;

@property (nonatomic, assign) BOOL middlePoint;

//Corner points
@property (nonatomic, strong) UIView *leftTopPointView;
@property (nonatomic, strong) UIView *rightTopPointView;
@property (nonatomic, strong) UIView *rightBottomPointView;
@property (nonatomic, strong) UIView *leftBottomPointView;
//Middle points
@property (nonatomic, strong) UIView *bottomCenterPointView;
@property (nonatomic, strong) UIView *rightCenterPointView;
@property (nonatomic, strong) UIView *topCenterPointView;
@property (nonatomic, strong) UIView *leftCenterPointView;
@property (nonatomic, strong) NSMutableArray *points;


- (BOOL)frameEdited;
- (void)resetFrame;

- (void)setCropFramePointModel:(LTFramePointModel *)framePointModel;
- (LTFramePointModel *)getCropFramePointModel;

- (void)checkAngle:(NSInteger)index;
- (BOOL)findPointAtLocation:(CGPoint)location;
- (void)moveActivePointToLocation:(CGPoint)locationPoint;

@end
