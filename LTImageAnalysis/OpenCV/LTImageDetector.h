//
//  LTImageDetector.h
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTFramePointModel.h"

@interface LTImageDetector : NSObject

// Find Edges, return LTFramePointModel that contains frame point
- (LTFramePointModel *)getEdgesRect:(UIImageView *)imageView;

// Crop Images, if image is not rectangle, first transfrom to rectangle then crop
- (UIImage *)cropAndTransformUIImage:(UIImage *)image framePointModel:(LTFramePointModel *)framePointModel;


// Find Lines, return NSNumber which is line's pos.y Integer value
- (NSArray *)findLinesPosYArray:(UIImage *)image minLineLength:(int)minLineLength maxLineGap:(int)maxLineGap;

- (UIImage *)debugFindLinesPosYArray:(UIImage *)image minLineLength:(int)minLineLength maxLineGap:(int)maxLineGap lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold;


// Find contours, that minHeight should be calc with linesHeight
- (UIImage *)findContours:(UIImage *)image linesArray:(NSArray *)linesArray minScale:(CGFloat)minScale lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold;


- (UIImage *)segment:(UIImage *)image linesArray:(NSArray *)linesArray minScale:(CGFloat)minScale lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold;

- (UIImage *)getCanny:(UIImage *)image lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold;

- (UIImage *)getThreshold:(UIImage *)image threshold:(double)threshold;


@end
