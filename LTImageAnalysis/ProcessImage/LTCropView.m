//
//  LTCropView.m
//  LTImageAnalysis
//
//  Created by alicia on 10/29/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTCropView.h"
#import "CommonDefine.h"
#import "UIView+LTAddtions.h"


#define kCropButtonAlpha        0.3
#define kCropButtonColor        [UIColor grayColor]
#define kCropButtonBorderWith   1
#define kCropButtonPadding      (kCropButtonSize / 2)

@interface LTCropView ()

@property (nonatomic, assign) CGPoint touchOffset;

@property (nonatomic, strong) LTFramePointModel *framePointModel;

@property (nonatomic, assign) BOOL frameMoved;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger previousIndex;
@property (nonatomic, assign) NSInteger k;

@end

@implementation LTCropView

#pragma mark - Draw

- (void)drawRect:(CGRect)rect; {
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context) {
        // [UIColor colorWithRed:0.52f green:0.65f blue:0.80f alpha:1.00f];
        
        //        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.7f);
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 0.0f);
        if([self checkForNeighbouringPoints:self.currentIndex] >= 0 ){
            self.frameMoved = YES;
            CGContextSetRGBStrokeColor(context, 0.1294f, 0.588f, 0.9529f, 1.0f);
        } else {
            self.frameMoved = NO;
            CGContextSetRGBStrokeColor(context, 0.9568f, 0.262f, 0.211f, 1.0f);
        }
        CGContextSetLineJoin(context, kCGLineJoinRound);
        CGContextSetLineWidth(context, 4.0f);
        
        CGRect boundingRect = CGContextGetClipBoundingBox(context);
        CGContextAddRect(context, boundingRect);
        CGContextFillRect(context, boundingRect);
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGPathMoveToPoint(pathRef, NULL, self.leftBottomPointView.left + kCropButtonPadding, self.leftBottomPointView.top + kCropButtonPadding);
        CGPathAddLineToPoint(pathRef, NULL, self.rightBottomPointView.left + kCropButtonPadding, self.rightBottomPointView.top + kCropButtonPadding);
        CGPathAddLineToPoint(pathRef, NULL, self.rightTopPointView.left + kCropButtonPadding, self.rightTopPointView.top + kCropButtonPadding);
        CGPathAddLineToPoint(pathRef, NULL, self.leftTopPointView.left + kCropButtonPadding, self.leftTopPointView.top + kCropButtonPadding);
        
        CGPathCloseSubpath(pathRef);
        CGContextAddPath(context, pathRef);
        CGContextStrokePath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        
        CGContextAddPath(context, pathRef);
        CGContextFillPath(context);
        
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        
        CGPathRelease(pathRef);
    }
}


#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.points = [[NSMutableArray alloc] init];
        
        //Corner points
        self.leftBottomPointView = [[UIView alloc] init];
        self.rightBottomPointView = [[UIView alloc] init];
        self.rightTopPointView = [[UIView alloc] init];
        self.leftTopPointView = [[UIView alloc] init];
        
        //Middle Points
        self.bottomCenterPointView = [[UIView alloc] init];
        self.rightCenterPointView = [[UIView alloc] init];
        self.topCenterPointView = [[UIView alloc] init];
        self.leftCenterPointView = [[UIView alloc] init];
        
        self.leftBottomPointView.alpha = kCropButtonAlpha;
        self.rightBottomPointView.alpha = kCropButtonAlpha;
        self.rightTopPointView.alpha = kCropButtonAlpha;
        self.leftTopPointView.alpha = kCropButtonAlpha;
        self.bottomCenterPointView.alpha = kCropButtonAlpha;
        self.rightCenterPointView.alpha = kCropButtonAlpha;
        self.topCenterPointView.alpha = kCropButtonAlpha;
        self.leftCenterPointView.alpha = kCropButtonAlpha;
        
        self.leftBottomPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.rightBottomPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.rightTopPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.leftTopPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.bottomCenterPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.rightCenterPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.topCenterPointView.layer.cornerRadius = kCropButtonSize / 2;
        self.leftCenterPointView.layer.cornerRadius = kCropButtonSize / 2;
        
        self.leftBottomPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.rightBottomPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.rightTopPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.leftTopPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.bottomCenterPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.rightCenterPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.topCenterPointView.layer.borderColor = MAIN_COLOR.CGColor;
        self.leftCenterPointView.layer.borderColor = MAIN_COLOR.CGColor;
        
        self.leftBottomPointView.layer.borderWidth = kCropButtonBorderWith;
        self.rightBottomPointView.layer.borderWidth = kCropButtonBorderWith;
        self.rightTopPointView.layer.borderWidth = kCropButtonBorderWith;
        self.leftTopPointView.layer.borderWidth = kCropButtonBorderWith;
        self.bottomCenterPointView.layer.borderWidth = kCropButtonBorderWith;
        self.rightCenterPointView.layer.borderWidth = kCropButtonBorderWith;
        self.topCenterPointView.layer.borderWidth = kCropButtonBorderWith;
        self.leftCenterPointView.layer.borderWidth = kCropButtonBorderWith;

        
        [self addSubview:self.leftBottomPointView];
        [self addSubview:self.rightBottomPointView];
        [self addSubview:self.rightTopPointView];
        [self addSubview:self.leftTopPointView];
        
        [self addSubview:self.bottomCenterPointView];
        [self addSubview:self.rightCenterPointView];
        [self addSubview:self.topCenterPointView];
        [self addSubview:self.leftCenterPointView];
        
        [self.points addObject:self.leftTopPointView];
        [self.points addObject:self.rightTopPointView];
        [self.points addObject:self.rightBottomPointView];
        [self.points addObject:self.leftBottomPointView];
        
        [self.points addObject:self.bottomCenterPointView];
        [self.points addObject:self.rightCenterPointView];
        [self.points addObject:self.topCenterPointView];
        [self.points addObject:self.leftCenterPointView];
        
        
        //COLOR
        self.leftBottomPointView.backgroundColor = kCropButtonColor;
        self.rightBottomPointView.backgroundColor = kCropButtonColor;
        self.rightTopPointView.backgroundColor = kCropButtonColor;
        self.leftTopPointView.backgroundColor = kCropButtonColor;
        self.bottomCenterPointView.backgroundColor = kCropButtonColor;
        self.rightCenterPointView.backgroundColor = kCropButtonColor;
        self.topCenterPointView.backgroundColor = kCropButtonColor;
        self.leftCenterPointView.backgroundColor = kCropButtonColor;

        self.framePointModel = [[LTFramePointModel alloc] init];
        
        [self setPoints];
        [self setClipsToBounds:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self setContentMode:UIViewContentModeRedraw];
        [self setButtons];
    }
    return self;
}


#pragma mark - Public Method

- (void)resetFrame {
    [self setPoints];
    [self setNeedsDisplay];
    [self drawRect:self.bounds];
    [self setButtons];
}

- (BOOL)frameEdited {
    return self.frameMoved;
}


- (void)setCropFramePointModel:(LTFramePointModel *)framePointModel {
    self.framePointModel.leftTopPoint = framePointModel.leftTopPoint;
    self.framePointModel.leftBottomPoint = framePointModel.leftBottomPoint;
    self.framePointModel.rightTopPoint = framePointModel.rightTopPoint;
    self.framePointModel.rightBottomPoint = framePointModel.rightBottomPoint;
    
    [self needsRedraw];
}

- (LTFramePointModel *)getCropFramePointModel {
    self.framePointModel.leftTopPoint = CGPointMake(self.leftTopPointView.centerX - kCropButtonPadding, self.leftTopPointView.centerY - kCropButtonPadding);
    self.framePointModel.leftBottomPoint = CGPointMake(self.leftBottomPointView.centerX - kCropButtonPadding, self.leftBottomPointView.centerY - kCropButtonPadding);
    self.framePointModel.rightTopPoint = CGPointMake(self.rightTopPointView.centerX - kCropButtonPadding, self.rightTopPointView.centerY - kCropButtonPadding);
    self.framePointModel.rightBottomPoint = CGPointMake(self.rightBottomPointView.centerX - kCropButtonPadding, self.rightBottomPointView.centerY -  kCropButtonPadding);
    
    return self.framePointModel;
}

- (void)checkAngle:(NSInteger)index{
    self.k = 0;
    
    NSArray *points = [self getPoints];
    for (NSInteger i = 0; i < points.count; i++) {
        CGFloat fValue = [self getAngleByPoints:points withIndex:i];
        if (fValue < 0) {
            ++self.k;
        }
    }
    
    //    LTLog(@"Last Call%d",self.previousIndex);
    
    if (self.k >= 2) {
        [self swapTwoPoints];
    }
    
    self.previousIndex = self.currentIndex;
}

- (CGPoint)getPointInsideContent:(CGPoint)point{
    // if pan gesture out of imageview, do nothing
    CGFloat padding = kCropButtonSize;
    if (point.x < 0) {
        point.x = 0;
    } else if (point.x > self.width - padding) {
        point.x = self.width - padding;
    }
    if (point.y < 0) {
        point.y = 0;
    } else if (point.y > self.height - padding) {
        point.y = self.height - padding;
    }
    
    return point;
}

- (BOOL)findPointAtLocation:(CGPoint)location {
    location = [self getPointInsideContent:location];
    self.activePoint.backgroundColor = [UIColor blueColor];
    self.activePoint = nil;
    CGFloat smallestDistance = INFINITY;
    NSInteger i = 0;
    for (UIView *point in self.points) {
        
        CGRect extentedFrame = CGRectInset(point.frame, -kCropButtonSize, -kCropButtonSize);
   
        LTLog(@"For Point %ld Location%f %f and Point %f %f", (long)i, location.x, location.y, point.frame.origin.x, point.frame.origin.y);
        
        if (CGRectContainsPoint(extentedFrame, location)) {
            CGFloat distanceToThis = [self distanceBetween:point.frame.origin And:location];
            LTLog(@"Distance %f", distanceToThis);
            if(distanceToThis < smallestDistance) {
                self.activePoint = point;
                 LTLog(@"acvtive Point %lf %lf", point.frame.origin.x, point.frame.origin.y);
                smallestDistance = distanceToThis;
                self.currentIndex = i;
                
                if (i == 4 || i == 5 || i == 6 || i == 7) {
                    self.middlePoint = YES;
                } else {
                    self.middlePoint = NO;
                }
            }
        }
        i++;
    }
//    if(self.activePoint) {
//        self.activePoint.backgroundColor = [UIColor redColor];
//    }
    
    LTLog(@"Active Point%@",self.activePoint);
    
    if (self.activePoint) {
        return YES;
    } else {
        return NO;
    }
}

- (void)moveActivePointToLocation:(CGPoint)locationPoint {
    locationPoint = [self getPointInsideContent:locationPoint];
    //    LTLog(@"location: %f,%f", locationPoint.x, locationPoint.y);
    
    if (self.activePoint && !self.middlePoint){
        self.activePoint.frame = CGRectMake(locationPoint.x - kCropButtonSize / 2, locationPoint.y -kCropButtonSize / 2, kCropButtonSize, kCropButtonSize);
        [self cornerControlsMiddle];
//        LTLog(@"Point D %f %f",_pointD.left,_pointD.top);
    } else {
        if (![self checkForNeighbouringPoints:self.currentIndex]) {
            [self movePointsForMiddle:locationPoint];
        }
    }
    [self setNeedsDisplay];
}


#pragma mark - Private Method
- (NSArray *)getPoints {
    NSMutableArray *p = [NSMutableArray array];
    
    for (uint i = 0; i < self.points.count; i++) {
        UIView *v = [self.points objectAtIndex:i];
        CGPoint point = CGPointMake(v.frame.origin.x + kCropButtonSize / 2, v.frame.origin.y + kCropButtonSize / 2);
        [p addObject:[NSValue valueWithCGPoint:point]];
    }
    return p;
}


- (UIImage *)squareButtonWithWidth:(int)width {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return blank;
}

- (void)setPoints {
//    CGFloat padding = 15;
    CGFloat padding = 0;
    
    self.framePointModel.leftTopPoint = CGPointMake(0 + padding, 0 + padding);
    self.framePointModel.leftBottomPoint = CGPointMake(0 + padding, self.height - padding);
    self.framePointModel.rightTopPoint = CGPointMake(self.width - padding, 0 + padding);
    self.framePointModel.rightBottomPoint = CGPointMake(self.width - padding, self.height - padding);

//    self.e = CGPointMake((self.a.x + self.b.x) / 2, self.a.y);
//    self.f = CGPointMake(self.b.x, 0 + (self.b.y + self.c.y) / 2);
//    self.g = CGPointMake((self.c.x + self.d.x) / 2, 0 + self.c.y);
//    self.h = CGPointMake(self.a.x, 0 + (self.a.y + self.d.y) / 2);
    
    
//    self.d = framePointModel.leftTopPoint;
//    self.a = framePointModel.leftBottomPoint;
//    self.c = framePointModel.rightTopPoint;
//    self.b = framePointModel.rightBottomPoint;
//    
//    
//    self.e = framePointModel.bottomCenterPoint;
//    self.f = framePointModel.rightCenterPoint;
//    self.g = framePointModel.topCenterPoint;
//    self.h = framePointModel.leftCenterPoint;
    
    self.framePointModel.leftCenterPoint = CGPointMake(self.framePointModel.leftBottomPoint.x, padding + (self.framePointModel.leftBottomPoint.y + self.framePointModel.leftTopPoint.y) / 2);
    
    self.framePointModel.topCenterPoint = CGPointMake((self.framePointModel.rightTopPoint.x + self.framePointModel.leftTopPoint.x) / 2, padding + self.framePointModel.rightTopPoint.y);
    
    self.framePointModel.rightCenterPoint = CGPointMake(self.framePointModel.rightBottomPoint.x, padding + (self.framePointModel.rightBottomPoint.y + self.framePointModel.rightTopPoint.y) / 2);
    
    self.framePointModel.bottomCenterPoint = CGPointMake((self.framePointModel.leftBottomPoint.x + self.framePointModel.rightBottomPoint.x) / 2, self.framePointModel.leftBottomPoint.y);
}

- (void)setButtons {
    [self setButtonsWithPadding:kCropButtonSize];
}

- (void)setButtonsWithPadding:(CGFloat)buttonPadding {
    CGFloat padding = 0;
    [self.leftTopPointView setFrame:CGRectMake(self.framePointModel.leftTopPoint.x - padding, self.framePointModel.leftTopPoint.y - padding, kCropButtonSize, kCropButtonSize)];
    [self.rightTopPointView setFrame:CGRectMake(self.framePointModel.rightTopPoint.x - padding - buttonPadding, self.framePointModel.rightTopPoint.y - padding, kCropButtonSize, kCropButtonSize)];
    [self.rightBottomPointView setFrame:CGRectMake(self.framePointModel.rightBottomPoint.x - padding - buttonPadding, self.framePointModel.rightBottomPoint.y - padding - buttonPadding, kCropButtonSize, kCropButtonSize)];
    [self.leftBottomPointView setFrame:CGRectMake(self.framePointModel.leftBottomPoint.x - padding, self.framePointModel.leftBottomPoint.y - padding - buttonPadding, kCropButtonSize, kCropButtonSize)];
    /*
    [self.bottomCenterPointView setFrame:CGRectMake(self.framePointModel.bottomCenterPoint.x - padding, self.framePointModel.bottomCenterPoint.y - padding, kCropButtonSize, kCropButtonSize)];
    [self.rightCenterPointView setFrame:CGRectMake(self.framePointModel.rightCenterPoint.x - padding, self.framePointModel.rightCenterPoint.y - padding, kCropButtonSize, kCropButtonSize)];
    [self.topCenterPointView setFrame:CGRectMake(self.framePointModel.topCenterPoint.x - padding, self.framePointModel.topCenterPoint.y - padding, kCropButtonSize, kCropButtonSize)];
    [self.leftCenterPointView setFrame:CGRectMake(self.framePointModel.leftCenterPoint.x - padding, self.framePointModel.leftCenterPoint.y - padding, kCropButtonSize, kCropButtonSize)];
     */
    
    [self cornerControlsMiddle];
}

- (void)needsRedraw {
    [self setButtonsWithPadding:0];

    [self setNeedsDisplayInRect:self.bounds];
}


- (CGFloat)getAngleByPoints:(NSArray *)points withIndex:(NSUInteger)index {
    CGPoint p1;
    CGPoint p2;
    CGPoint p3;
    
    switch (index) {
        case 0:
            p1 = [[points objectAtIndex:0] CGPointValue];
            p2 = [[points objectAtIndex:1] CGPointValue];
            p3 = [[points objectAtIndex:3] CGPointValue];
            break;
        case 1:
            p1 = [[points objectAtIndex:1] CGPointValue];
            p2 = [[points objectAtIndex:2] CGPointValue];
            p3 = [[points objectAtIndex:0] CGPointValue];
            break;
        case 2:
            p1 = [[points objectAtIndex:2] CGPointValue];
            p2 = [[points objectAtIndex:3] CGPointValue];
            p3 = [[points objectAtIndex:1] CGPointValue];
            break;
        default:
            p1 = [[points objectAtIndex:3] CGPointValue];
            p2 = [[points objectAtIndex:0] CGPointValue];
            p3 = [[points objectAtIndex:2] CGPointValue];
            break;
    }
    
    CGPoint ab = CGPointMake(p2.x - p1.x, p2.y - p1.y);
    CGPoint cb = CGPointMake(p2.x - p3.x, p2.y - p3.y);
    CGFloat dot = (ab.x * cb.x + ab.y * cb.y); // dot product
    CGFloat cross = (ab.x * cb.y - ab.y * cb.x); // cross product
    
    CGFloat alpha = atan2(cross, dot);
    
    CGFloat fValue = -1 * (CGFloat)floor(alpha * 180. / 3.14 + 0.5);
//        LTLog(@"%f",fValue);
    return fValue;
}

// Condition For Valid Rect
- (double)checkForNeighbouringPoints:(NSInteger)index {
    NSArray *points = [self getPoints];
    for (NSInteger i = 0; i < points.count; i++) {
        CGFloat fValue = [self getAngleByPoints:points withIndex:i];
        if (fValue < 0) {
            return fValue;
        }
    }
    return 0;
}

- (void)swapTwoPoints {
    if (self.k == 2) {
        LTLog(@"Swicth  2");
        if ([self checkForHorizontalIntersection]) {
            CGRect temp0 = [[self.points objectAtIndex:0] frame];
            CGRect temp3 = [[self.points objectAtIndex:3] frame];
            
            [[self.points objectAtIndex:0] setFrame:temp3];
            [[self.points objectAtIndex:3] setFrame:temp0];
            [self checkAngle:0];
            [self cornerControlsMiddle];
            [self setNeedsDisplay];
        }
        if ([self checkForVerticalIntersection]) {
            CGRect temp0 = [[self.points objectAtIndex:2] frame];
            CGRect temp3 = [[self.points objectAtIndex:3] frame];
            
            [[self.points objectAtIndex:2] setFrame:temp3];
            [[self.points objectAtIndex:3] setFrame:temp0];
            [self checkAngle:0];
            [self cornerControlsMiddle];
            [self setNeedsDisplay];
        }
    } else {
        LTLog(@"Swicth More then 2");
        CGRect temp2 = [[self.points objectAtIndex:2] frame];
        CGRect temp0 = [[self.points objectAtIndex:0] frame];
        
        [[self.points objectAtIndex:0] setFrame:temp2];
        [[self.points objectAtIndex:2] setFrame:temp0];
        [self cornerControlsMiddle];
        [self setNeedsDisplay];
    }
}

- (BOOL)checkForHorizontalIntersection {
    CGLine line1 = CGLineMake(CGPointMake([[self.points objectAtIndex:0] frame].origin.x, [[self.points objectAtIndex:0] frame].origin.y), CGPointMake([[self.points objectAtIndex:1] frame].origin.x, [[self.points objectAtIndex:1] frame].origin.y));
    
    CGLine line2 = CGLineMake(CGPointMake([[self.points objectAtIndex:2] frame].origin.x, [[self.points objectAtIndex:2] frame].origin.y), CGPointMake([[self.points objectAtIndex:3] frame].origin.x, [[self.points objectAtIndex:3] frame].origin.y));
    
    //    NSLog(@"Horizontal%f %f",CGLinesIntersectAtPoint(line1, line2).x,CGLinesIntersectAtPoint(line1, line2).y);
    
    CGPoint temp = CGLinesIntersectAtPoint(line1, line2);
    if (temp.x != INFINITY && temp.y != INFINITY) {
        return YES;
    }
    return NO;
}

-(BOOL)checkForVerticalIntersection {
    CGLine line3 = CGLineMake(CGPointMake([[self.points objectAtIndex:0] frame].origin.x, [[self.points objectAtIndex:0] frame].origin.y), CGPointMake([[self.points objectAtIndex:3] frame].origin.x, [[self.points objectAtIndex:3] frame].origin.y));
    
    CGLine line4 = CGLineMake(CGPointMake([[self.points objectAtIndex:2] frame].origin.x, [[self.points objectAtIndex:2] frame].origin.y), CGPointMake([[self.points objectAtIndex:1] frame].origin.x, [[self.points objectAtIndex:1] frame].origin.y));
    
    //     NSLog(@"Verical %f %f",CGLinesIntersectAtPoint(line3, line4).x,CGLinesIntersectAtPoint(line3, line4).y);
    
    CGPoint temp = CGLinesIntersectAtPoint(line3, line4);
    if(temp.x != INFINITY && temp.y!= INFINITY){
        return YES;
    }
    return NO;
}

-(CGFloat)distanceBetween:(CGPoint)first And:(CGPoint)last {
    CGFloat xDist = (last.x - first.x);
    if (xDist < 0) {
        xDist = xDist * -1;
    }
    CGFloat yDist = (last.y - first.y);
    if (yDist < 0) {
        yDist=yDist * -1;
    }
    return sqrt((xDist * xDist) + (yDist * yDist));
}

// Corner Touch
- (void)cornerControlsMiddle {
    self.bottomCenterPointView.frame = CGRectMake((self.leftBottomPointView.left + self.rightBottomPointView.left) / 2, (self.leftBottomPointView.top + self.rightBottomPointView.top) / 2, kCropButtonSize, kCropButtonSize);
    self.topCenterPointView.frame = CGRectMake((self.rightTopPointView.left + self.leftTopPointView.left) / 2, (self.rightTopPointView.top + self.leftTopPointView.top) / 2, kCropButtonSize, kCropButtonSize);
    self.rightCenterPointView.frame = CGRectMake((self.rightBottomPointView.left + self.rightTopPointView.left) /2, (self.rightBottomPointView.top + self.rightTopPointView.top) / 2, kCropButtonSize, kCropButtonSize);
    self.leftCenterPointView.frame = CGRectMake((self.leftBottomPointView.left + self.leftTopPointView.left) / 2, (self.leftBottomPointView.top + self.leftTopPointView.top) / 2, kCropButtonSize, kCropButtonSize);
}

// Middle Touch
- (void)movePointsForMiddle:(CGPoint)locationPoint {
    switch (self.currentIndex) {
        case 4:
            // 2 and 3
            self.leftBottomPointView.frame = CGRectMake(self.leftBottomPointView.left, locationPoint.y , kCropButtonSize, kCropButtonSize);
            self.rightBottomPointView.frame = CGRectMake(self.rightBottomPointView.left, locationPoint.y, kCropButtonSize, kCropButtonSize);
            break;
        case 5:
            // 1 and 2
            self.rightBottomPointView.frame = CGRectMake(locationPoint.x, self.rightBottomPointView.top, kCropButtonSize, kCropButtonSize);
            self.rightTopPointView.frame = CGRectMake(locationPoint.x, self.rightTopPointView.top, kCropButtonSize, kCropButtonSize);
            break;
        case 6:
            //3 and 4
            self.rightTopPointView.frame = CGRectMake(self.rightTopPointView.left, locationPoint.y, kCropButtonSize, kCropButtonSize);
            self.leftTopPointView.frame = CGRectMake(self.leftTopPointView.left, locationPoint.y, kCropButtonSize, kCropButtonSize);
            break;
        case 7:
            // 1 and 4
            self.leftBottomPointView.frame = CGRectMake(locationPoint.x,self.leftBottomPointView.top, kCropButtonSize, kCropButtonSize);
            self.leftTopPointView.frame = CGRectMake(locationPoint.x,self.leftTopPointView.top, kCropButtonSize, kCropButtonSize);
            break;
    }
    
    [self cornerControlsMiddle];
}


@end
