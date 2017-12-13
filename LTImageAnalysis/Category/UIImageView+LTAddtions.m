//
//  UIImageView+LTAddtions.m
//  LTImageAnalysis
//
//  Created by alicia on 10/30/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "UIImageView+LTAddtions.h"

@implementation UIImageView (LTAddtions)

- (CGRect)contentFrame {
    CGSize scaledImageSize = [self contentSize];
    CGRect contentFrame = CGRectMake(self.frame.origin.x + (CGRectGetWidth(self.bounds) - scaledImageSize.width) / 2, self.frame.origin.y + (CGRectGetHeight(self.bounds) - scaledImageSize.height) / 2, scaledImageSize.width, scaledImageSize.height);
    return contentFrame;
}

- (CGSize)contentSize {
    CGFloat imageScale = [self contentScale];
    CGSize imageSize = self.image.size;
    CGSize finalSize = CGSizeMake(imageSize.width * imageScale, imageSize.height * imageScale);
    return finalSize;
}

- (CGFloat)contentScale {
    CGSize imageSize = self.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(self.bounds) / imageSize.width, CGRectGetHeight(self.bounds) / imageSize.height);
    return imageScale;
}

- (CGRect)imageFrame {
    CGSize scaledImageSize = [self contentSize];
    CGRect imageFrame = CGRectMake((CGRectGetWidth(self.bounds) - scaledImageSize.width) / 2, (CGRectGetHeight(self.bounds) - scaledImageSize.height) / 2, scaledImageSize.width, scaledImageSize.height);
    return imageFrame;
}
@end
