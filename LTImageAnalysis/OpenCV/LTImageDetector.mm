//
//  LTImageDetector.m
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTImageDetector.h"
#import "CommonDefine.h"
#import "UIImageView+LTAddtions.h"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>


#define kCosineNearZeroDegree           0.999
#define kFindLineThreshold              100
#define kGaussianBlurSize               11

@implementation LTImageDetector


#pragma mark - Public Method

- (LTFramePointModel *)getEdgesRect:(UIImageView *)imageView {
    
    LTFramePointModel *framePointModel = nil;
    
    UIImage *image = imageView.image;
    cv::Mat src;
    
    src = [self cvMatFromUIImage:image];
    
    CGSize targetSize = imageView.contentSize;
    cv::resize(src, src, cvSize(targetSize.width, targetSize.height));
    
    std::vector<std::vector<cv::Point>> squares = [self p_getSquaresFromMat:src];
    
    std::vector<cv::Point> largest_square;
    p_findLargestSquare(squares, largest_square);
    
    if (largest_square.size() == 4) {
        
        // Manually sorting points, needs major improvement. Sorry.
        NSMutableArray *points = [NSMutableArray array];
        NSMutableDictionary *sortedPoints = [NSMutableDictionary dictionary];
        
        for (int i = 0; i < 4; i++) {
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGPoint:CGPointMake(largest_square[i].x, largest_square[i].y)], @"point", [NSNumber numberWithInt:(largest_square[i].x + largest_square[i].y)], @"value", nil];
            [points addObject:dict];
        }
        
        int min = [[points valueForKeyPath:@"@min.value"] intValue];
        int max = [[points valueForKeyPath:@"@max.value"] intValue];
        
        int minIndex = 0;
        int maxIndex = 0;
        
        int missingIndexOne = 0;
        int missingIndexTwo = 0;
        
        for (int i = 0; i < 4; i++) {
            NSDictionary *dict = [points objectAtIndex:i];
            
            if ([[dict objectForKey:@"value"] intValue] == min) {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"0"];
                minIndex = i;
                continue;
            }
            
            if ([[dict objectForKey:@"value"] intValue] == max) {
                [sortedPoints setObject:[dict objectForKey:@"point"] forKey:@"2"];
                maxIndex = i;
                continue;
            }
            
            LTLog(@"missing point %i", i);
            
            missingIndexOne = i;
        }
        
        for (int i = 0; i < 4; i++) {
            if (missingIndexOne != i && minIndex != i && maxIndex != i) {
                missingIndexTwo = i;
            }
        }
        
        
        if (largest_square[missingIndexOne].x < largest_square[missingIndexTwo].x) {
            //2nd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"3"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"1"];
        }  else  {
            //4rd Point Found
            [sortedPoints setObject:[[points objectAtIndex:missingIndexOne] objectForKey:@"point"] forKey:@"1"];
            [sortedPoints setObject:[[points objectAtIndex:missingIndexTwo] objectForKey:@"point"] forKey:@"3"];
        }
        
        framePointModel = [[LTFramePointModel alloc] init];
        framePointModel.leftTopPoint =  [(NSValue *)[sortedPoints objectForKey:@"0"] CGPointValue];
        framePointModel.rightTopPoint =  [(NSValue *)[sortedPoints objectForKey:@"1"] CGPointValue];
        framePointModel.rightBottomPoint = [(NSValue *)[sortedPoints objectForKey:@"2"] CGPointValue];
        framePointModel.leftBottomPoint = [(NSValue *)[sortedPoints objectForKey:@"3"] CGPointValue];
    
        LTLog(@"%@ Sorted Points",sortedPoints);
    }
    
    src.release();
    
    return framePointModel;
}

- (UIImage *)cropAndTransformUIImage:(UIImage *)image framePointModel:(LTFramePointModel *)framePointModel {
    //Thanks To stackOverflow
    CGFloat w1 = sqrt(pow(framePointModel.rightBottomPoint.x - framePointModel.leftBottomPoint.x , 2) + pow(framePointModel.rightBottomPoint.x - framePointModel.leftBottomPoint.x, 2));
    CGFloat w2 = sqrt(pow(framePointModel.rightTopPoint.x -
                          framePointModel.leftTopPoint.x , 2) + pow(framePointModel.rightTopPoint.x - framePointModel.leftTopPoint.x, 2));
    
    CGFloat h1 = sqrt(pow(framePointModel.leftTopPoint.y - framePointModel.rightBottomPoint.y , 2) + pow(framePointModel.rightTopPoint.y - framePointModel.rightBottomPoint.y, 2));
    CGFloat h2 = sqrt(pow(framePointModel.leftTopPoint.y - framePointModel.leftBottomPoint.y , 2) + pow(framePointModel.leftTopPoint.y - framePointModel.leftBottomPoint.y, 2));
    
    CGFloat maxWidth = (w1 < w2) ? w1 : w2;
    CGFloat maxHeight = (h1 < h2) ? h1 : h2;
    
    cv::Point2f src[4], dst[4];
    src[0].x = framePointModel.leftTopPoint.x;
    src[0].y = framePointModel.leftTopPoint.y;
    src[1].x = framePointModel.rightTopPoint.x;
    src[1].y = framePointModel.rightTopPoint.y;
    src[2].x = framePointModel.rightBottomPoint.x;
    src[2].y = framePointModel.rightBottomPoint.y;
    src[3].x = framePointModel.leftBottomPoint.x;
    src[3].y = framePointModel.leftBottomPoint.y;
    
    dst[0].x = 0;
    dst[0].y = 0;
    dst[1].x = maxWidth - 1;
    dst[1].y = 0;
    dst[2].x = maxWidth - 1;
    dst[2].y = maxHeight - 1;
    dst[3].x = 0;
    dst[3].y = maxHeight - 1;
    
    cv::Mat undistorted = cv::Mat(cvSize(maxWidth,maxHeight), CV_8UC4);
    cv::Mat original = [self cvMatFromUIImage:image];
    
    LTLog(@"%f %f %f %f", framePointModel.leftBottomPoint.x, framePointModel.rightBottomPoint.x, framePointModel.rightTopPoint.x, framePointModel.leftTopPoint.x);
    
    cv::Mat transform = cv::getPerspectiveTransform(src, dst);
    cv::warpPerspective(original, undistorted, transform, cvSize(maxWidth, maxHeight));

    UIImage *undistortedImage = [self UIImageFromCVMat:undistorted];
    original.release();
    undistorted.release();
    
    return undistortedImage;
}


- (NSArray *)findLinesPosYArray:(UIImage *)image minLineLength:(int)minLineLength maxLineGap:(int)maxLineGap {
    return [self p_findLinesPosYArray:image minLineLength:minLineLength maxLineGap:maxLineGap lowerThreshold:CANNY_LINE_LOWER_THRESHOLD upperThreshold:CANNY_LINE_UPPER_THRESHOLD isDebug:NO];
}

- (UIImage *)debugFindLinesPosYArray:(UIImage *)image minLineLength:(int)minLineLength maxLineGap:(int)maxLineGap lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold  {
    return [self p_findLinesPosYArray:image minLineLength:minLineLength maxLineGap:maxLineGap lowerThreshold:lowerThreshold upperThreshold:upperThreshold isDebug:YES];
}

- (UIImage *)getCanny:(UIImage *)image lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshod {
    cv::Mat src = [self cvMatFromUIImage:image];
    cv::Mat mid = [self getCannyFromMat:src lowerThreshold:lowerThreshold upperThreshold:upperThreshod];
    UIImage *dstImage = [self UIImageFromCVMat:mid];
    return dstImage;
}


- (UIImage *)getThreshold:(UIImage *)image threshold:(double)threshold {
    cv::Mat src = [self cvMatFromUIImage:image];
    cv::Mat mid = [self getThresholdFromMat:src threshold:threshold];
    UIImage *dstImage = [self UIImageFromCVMat:mid];
    return dstImage;
}

- (UIImage *)findContours:(UIImage *)image linesArray:(NSArray *)linesArray minScale:(CGFloat)minScale lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold {
    cv::Mat src = [self cvMatFromUIImage:image];
    
    
    cv::Mat mid = [self getCannyFromMat:src lowerThreshold:lowerThreshold upperThreshold:upperThreshold];
    
    dilate(mid, mid, cv::Mat(), cv::Point(-1, -1));

 
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;

    findContours(mid, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_SIMPLE, cv::Point());
    
    if (contours.size() == 0) {
        LTLog(@"Error not find contour");
    }
    
    std::vector<cv::Rect> boundRect(contours.size());
    for (int i = 0; i < contours.size(); i++) {
        boundRect[i] = boundingRect(cv::Mat(contours[i]));
    }

    BOOL isFilterHeight = YES;
    if (!linesArray || [linesArray count] == 0) {
        isFilterHeight = NO;
    }
    for (int i = 0; i< contours.size(); i++) {

        if (isFilterHeight) {
//            BOOL isFind = NO;
            for (NSInteger j = 0; j < linesArray.count; j++) {
                NSInteger height = [linesArray[j] integerValue];
                if (boundRect[i].br().y < height) {
                    NSInteger maxHeight;
                    if (j > 0) {
                        maxHeight = height - [linesArray[j - 1] integerValue];
                    } else {
                        maxHeight = height;
                    }
                    [self drawRectangle:boundRect[i] toMat:src maxHeight:maxHeight * minScale];
//                    isFind = YES;
                    break;
                }
            }
        } else {
            rectangle(src, boundRect[i].tl(), boundRect[i].br(), cv::Scalar(0, 250, 155), 2, 8, 0);
        }
    }
     //    UIImage *dstImage = [self UIImageFromCVMat:mid];
    UIImage *dstImage = [self UIImageFromCVMat:src];
    return dstImage;
}

// scan image each row pixel, if it is 0 there got something, or nothing
- (UIImage *)segment:(UIImage *)image linesArray:(NSArray *)linesArray minScale:(CGFloat)minScale lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold {
    cv::Mat src = [self cvMatFromUIImage:image];
    
    cv::Mat mid = [self getThresholdFromMat:src threshold:upperThreshold];
    
    
    int erodeTimes = 4;
    cv::erode(mid,mid,cv::Mat(),cv::Point(-1, -1), erodeTimes);
 
    int paddingX = erodeTimes / 2;
    int paddingY = 5;
    
    for (int i = 0; i < linesArray.count; i++) {
        CGFloat top = 0;
        NSNumber *bottomNumber = linesArray[i];
        CGFloat bottom = [bottomNumber floatValue];
        CGFloat rowHeight = bottom;
        if (i > 0) {
            NSNumber *topNumber = linesArray[i - 1];
            top = [topNumber floatValue];
            rowHeight -= top;
        }
        
        int row = rowHeight * minScale;
        
        BOOL isInRect = NO;
        int startCol = 0;
        int endCol = 0;
        for (int col = 0; col < mid.cols; col++) {
            int perPixelValue = mid.at<uchar>(row, col);
            if (!isInRect && perPixelValue != 0) {
                isInRect = YES;
                startCol = col;
            } else if (perPixelValue == 0 && isInRect) {
                endCol = col;
                isInRect = NO;
                
                cv::Point tlPoint = cv::Point(startCol - paddingX, top + paddingY);
                cv::Point brPoint = cv::Point(endCol + paddingX, bottom - paddingY * 2);
                rectangle(src, tlPoint, brPoint, cv::Scalar(255, 0, 250), 2, 8, 0);
            }
        }
    }
    
    UIImage *dstImage = [self UIImageFromCVMat:src];
    return dstImage;
}


cv::Vec3b RandomColor(int value) {
    value = value % 255;  //生成0~255的随机数
    cv::RNG rng;
    int aa = rng.uniform(0, value);
    int bb = rng.uniform(0, value);
    int cc = rng.uniform(0, value);
    return cv::Vec3b(aa, bb, cc);
}

- (void)drawRectangle:(cv::Rect)boundRect toMat:(cv::Mat)mat maxHeight:(NSInteger)maxHeight {
    float rectHeight = boundRect.height;
    if (rectHeight >= maxHeight) {
        rectangle(mat, boundRect.tl(), boundRect.br(), cv::Scalar(255, 255, 0), 2, 8, 0);
    }
}

- (cv::Mat)getCannyFromMat:(cv::Mat)src lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold gaussianBlurSize:(double)gaussianBlurSize {
    cv::Mat mid;
    cvtColor(src, mid, CV_RGB2GRAY);
    GaussianBlur(mid, mid, cv::Size(gaussianBlurSize, gaussianBlurSize), 0);
    Canny(mid, mid, lowerThreshold, upperThreshold);
    return mid;
}

- (cv::Mat)getCannyFromMat:(cv::Mat)src lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold {
    return [self getCannyFromMat:src lowerThreshold:lowerThreshold upperThreshold:upperThreshold gaussianBlurSize:kGaussianBlurSize];
}

- (cv::Mat)getThresholdFromMat:(cv::Mat)src threshold:(double)threshold {
    cv::Mat mid;
    cvtColor(src, mid, CV_RGB2GRAY);
    GaussianBlur(mid, mid, cv::Size(kGaussianBlurSize, kGaussianBlurSize), 0);
    cv::threshold(mid, mid, threshold, 255, cv::THRESH_BINARY);
    return mid;
}



#pragma mark - Find Squaure
- (std::vector<std::vector<cv::Point>>)p_getSquaresFromMat:(cv::Mat&)src {
    cv::Mat mid = [self getCannyFromMat:src lowerThreshold:10 upperThreshold:20];
    //    cv::Mat mid = [self getThresholdFromMat:src threshold:upperThreshold];
    dilate(mid, mid, cv::Mat(), cv::Point(-1, -1));
    
    std::vector<std::vector<cv::Point>> squares;
    std::vector<std::vector<cv::Point>> contours;
  
    // Find contours and store them in a list
    findContours(mid, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    // Test contours
    std::vector<cv::Point> approx;
    for (size_t i = 0; i < contours.size(); i++) {
        // approximate contour with accuracy proportional
        // to the contour perimeter
        approxPolyDP(cv::Mat(contours[i]), approx, arcLength(cv::Mat(contours[i]), true)*0.02, true);
        
        // Note: absolute value of an area is used because
        // area may be positive or negative - in accordance with the
        // contour orientation
        if (approx.size() == 4 &&
            fabs(contourArea(cv::Mat(approx))) > 1000 &&
            isContourConvex(cv::Mat(approx))) {
            double maxCosine = 0;
            
            for (int j = 2; j < 5; j++) {
                double cosine = fabs(p_angle(approx[j%4], approx[j-2], approx[j-1]));
                maxCosine = MAX(maxCosine, cosine);
            }
            
            if (maxCosine < 0.3) {
                squares.push_back(approx);
            }
        }
    }
    return squares;
}


void p_findLargestSquare(const std::vector<std::vector<cv::Point>>& squares, std::vector<cv::Point>& biggest_square) {
    
    if (!squares.size()) {
        // no squares detected
        return;
    }
    
    int max_width = 0;
    int max_height = 0;
    int max_square_idx = 0;
    
    for (int i = 0; i < squares.size(); i++) {
        // Convert a set of 4 unordered Points into a meaningful cv::Rect structure.
        cv::Rect rectangle = boundingRect(cv::Mat(squares[i]));
        
        //        cout << "find_largest_square: #" << i << " rectangle x:" << rectangle.x << " y:" << rectangle.y << " " << rectangle.width << "x" << rectangle.height << endl;
        
        // Store the index position of the biggest square found
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height)) {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    
    biggest_square = squares[max_square_idx];
}



double p_angle(cv::Point pt1, cv::Point pt2, cv::Point pt0) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1 * dx2 + dy1 * dy2) / sqrt((dx1 * dx1 + dy1 * dy1) * (dx2 * dx2 + dy2 * dy2) + 1e-10);
}


- (cv::Scalar)p_getRandomColor {
    cv::RNG rng(12345);
    cv::Scalar color = cv::Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255));
    return color;
}

#pragma mark - Find Lines
- (id)p_findLinesPosYArray:(UIImage *)image minLineLength:(int)minLineLength maxLineGap:(int)maxLineGap lowerThreshold:(double)lowerThreshold upperThreshold:(double)upperThreshold isDebug:(BOOL)isDebug {
    
    cv::Mat src = [self cvMatFromUIImage:image];
    
    cv::Mat mid = [self getCannyFromMat:src lowerThreshold:lowerThreshold upperThreshold:upperThreshold];
    
    dilate(mid, mid, cv::Mat(), cv::Point(-1, -1), 2);
    
    std::vector<cv::Vec4i> lines;
    
    HoughLinesP(mid, lines, 1, CV_PI / 180, 20, minLineLength, maxLineGap);
    
    
    unsigned long count = lines.size();
    NSMutableArray *linesArray = nil;
    if (!isDebug) {
        linesArray = [NSMutableArray array];
    }
    
    for (size_t i = 0; i < count; i++ ) {
        cv::Vec4i l = lines[i];
        
        cv::Point pt1 = cv::Point(l[0], l[1]);
        cv::Point pt2 = cv::Point(l[2], l[3]);
        short lineLength = 10;
        cv::Point pt3 = cv::Point(l[2] + lineLength, l[3]);
        double cosine = fabs(p_angle(pt1, pt2, pt3));
        // only want the line angle near 0 or 180 degree
        if ((cosine > 0 && cosine > kCosineNearZeroDegree) || (cosine < 0 && cosine < -kCosineNearZeroDegree)) {
            if (!isDebug) {
                [linesArray addObject:[NSNumber numberWithInteger:(l[1] + l[3]) / 2]];
            } else {
                line(src, pt1, pt2, cv::Scalar(0, 0, 255), 2);
            }
            LTLog(@"cosine:%f, pt=%d", cosine, (l[1] + l[3]) / 2);
        } else {
            line(src, pt1, pt2, cv::Scalar(255, 0, 0), 2);
            
        }
    }
    if (!isDebug) {
        return [linesArray copy];
    } else {
        UIImage *dstImage = [self UIImageFromCVMat:src];
//          UIImage *dstImage = [self UIImageFromCVMat:mid];
        return dstImage;
    }
}

#pragma mark - Convert Between Mav and UIImage

- (cv::Mat)cvMatFromUIImage:(UIImage *)image {
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols,rows;
    if  (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
        cols = image.size.height;
        rows = image.size.width;
    } else {
        cols = image.size.width;
        rows = image.size.height;
    }
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    
    cv::Mat cvMatTest;
    cv::transpose(cvMat, cvMatTest);
    
    if  (image.imageOrientation == UIImageOrientationLeft
         || image.imageOrientation == UIImageOrientationRight) {
        
    } else {
        return cvMat;
        
    }
    cvMat.release();
    
    cv::flip(cvMatTest, cvMatTest, 1);
    
    return cvMatTest;
}


- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat {
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}


#pragma mark - Debug Method
cv::Mat debugSquares( std::vector<std::vector<cv::Point> > squares, cv::Mat image) {

    for (unsigned int i = 0; i < squares.size(); i++) {
        // draw contour
        cv::drawContours(image, squares, i, cv::Scalar(255,0,0), 1, 8, std::vector<cv::Vec4i>(), 0, cv::Point());
        
        // draw bounding rect
        cv::Rect rect = boundingRect(cv::Mat(squares[i]));
        cv::rectangle(image, rect.tl(), rect.br(), cv::Scalar(0,255,0), 2, 8, 0);
        
        // draw rotated rect
        cv::RotatedRect minRect = minAreaRect(cv::Mat(squares[i]));
        cv::Point2f rect_points[4];
        minRect.points( rect_points );
        for ( int j = 0; j < 4; j++ ) {
            cv::line( image, rect_points[j], rect_points[(j+1)%4], cv::Scalar(0,0,255), 1, 8 ); // blue
        }
    }
    
    return image;
}

@end
