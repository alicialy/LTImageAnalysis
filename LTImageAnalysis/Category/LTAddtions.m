//
//  LTAddtions.m
//  LTImageAnalysis
//
//  Created by alicia on 10/30/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTAddtions.h"

@implementation LTAddtions


- (CGRect)contentFrame {
    CGSize scaledImageSize = [self contentSize];
    CGRect imageFrame = CGRectMake(0.5 * (CGRectGetWidth(self.bounds) - scaledImageSize.width), 0.5 * (CGRectGetHeight(self.bounds) -scaledImageSize.height), scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
}

- (CGSize)contentSize {
    CGFloat imageScale = [self contentScale];
    CGSize imageSize = self.image.size;
    CGSize finalSize = CGSizeMake(imageSize.width * imageScale, imageSize.height * imageScale);
    return finalSize;
}

- (CGFloat)contentScale {
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds)/imageSize.width, CGRectGetHeight(self.bounds)/imageSize.height);
    return imageScale;
}

@end
