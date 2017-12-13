//
//  LTCropViewController.m
//  LTImageAnalysis
//
//  Created by alicia on 10/28/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTProcessImageViewController.h"
#import "CommonDefine.h"
#import "UIView+LTAddtions.h"
#import "UIImageView+LTAddtions.h"
#import "LTProcessControlView.h"
#import "LTProcessControlModel.h"
#import "LTCropView.h"
#import "LTLineView.h"
#import "LTSliderView.h"
#import "LTImageDetector.h"

#define kContourMinScale        0.1
#define kSegmentMinScale        0.5
#define kMinLineDistanceScale   0.08
#define kLineBaseTag            100
#define KAnimationDuration      0.25
#define kMagnifyImageWH         100
#define kMagnifyBorderWidth     2
#define kMagnifyDragCount       6

@interface LTProcessImageViewController ()

@property (nonatomic, strong) UIImageView *showImageView;
@property (nonatomic, strong) UIImageView *magnifyImageView;
@property (nonatomic, strong) LTProcessControlView *controlView;
@property (nonatomic, strong) LTCropView *cropView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) LTSliderView *sliderView;
@property (nonatomic, strong) LTImageDetector *detector;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) UIImage *cropImage;
@property (nonatomic, strong) NSArray *linesArray;
@property (nonatomic, assign) BOOL isLineArraySorted;
@property (nonatomic, assign) NSUInteger dragCount;
@property (nonatomic, assign) NSUInteger currentCount;

@end

@implementation LTProcessImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self processImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init
- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.originalImage = image;
        self.cropImage = image;
    }
    return self;
}

- (void)setupViews {
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    // Content View
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:contentView];
    self.contentView = contentView;
    
    // Image View
    CGFloat paddingX = MAIN_PADDING;
    CGFloat paddingY = STATUSBAR_HEIGHT + MAIN_PADDING;
    CGRect imageViewFrame = CGRectMake(paddingX, paddingY, self.view.width - 2 * paddingX, self.view.height - kControlViewHeight - paddingY - MAIN_PADDING);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setImage:self.originalImage];
    [imageView setUserInteractionEnabled:YES];
    self.showImageView = imageView;
    [contentView addSubview:imageView];
  
    // Crop View
    CGRect cropFrame = CGRectMake(imageView.contentFrame.origin.x, imageView.contentFrame.origin.y, imageView.contentFrame.size.width, imageView.contentFrame.size.height);
    cropFrame = CGRectInset(cropFrame, -kCropButtonSize / 2, -kCropButtonSize / 2);
    LTCropView *cropView = [[LTCropView alloc] initWithFrame:cropFrame];
    self.cropView = cropView;
    [contentView addSubview:cropView];
    
    // Control View
    CGRect controlFrame = CGRectMake(0, self.view.height - kControlViewHeight, self.view.width, kControlViewHeight);
    LTProcessControlView *controlView = [[LTProcessControlView alloc] initWithFrame:controlFrame];
    [controlView addTarget:self];
    [controlView setControlByControlModelArray:[self getCropControlModelArray]];
    self.controlView = controlView;
    
    // Slider View
    CGRect sliderFrame = CGRectMake(0, CGRectGetMaxY(controlFrame) - kSliderViewHeight, self.view.width, kSliderViewHeight);
    LTSliderView *sliderView = [[LTSliderView alloc] initWithFrame:sliderFrame];
    [self.view addSubview:sliderView];
    [sliderView setHidden:YES];
    self.sliderView = sliderView;
    
    // Add Slider View firt to make Control View overlap Slider View
    [self.view addSubview:controlView];
    
    [self addGesture];
    
}

- (void)addGesture {
    UIPanGestureRecognizer *singlePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePanGesture:)];
    singlePanGesture.maximumNumberOfTouches = 1;
    [self.cropView addGestureRecognizer:singlePanGesture];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.contentView addGestureRecognizer:tap];
}

#pragma mark - Actions
- (void)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)backCropAction:(id)sender {
    [self switchViewControlWithModelArray:[self getCropControlModelArray]];
    
    BOOL isHidden = [self.sliderView isHidden];
    if (!isHidden) {
        [self setSliderViewHidden:YES];
    }
    self.showImageView.image = self.originalImage;
    [[self.showImageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.cropView setHidden:NO];
    self.linesArray = nil;
}

- (void)cropAction:(id)sender {
    if([self.cropView frameEdited]) {
        [self.cropView setHidden:YES];
        
        CGFloat scaleFactor = [self.showImageView contentScale];
        LTFramePointModel *framePointModel = [self.cropView getCropFramePointModel];
        framePointModel = [framePointModel toScale:scaleFactor];
        UIImage *undistortedImage = [self.detector cropAndTransformUIImage:self.showImageView.image framePointModel:framePointModel];
        
        [UIView transitionWithView:self.showImageView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            self.showImageView.image = undistortedImage;
            self.cropImage = undistortedImage;
            
        } completion:^(BOOL finished) {
            [self switchViewControlWithModelArray:[self getProcessControlModelArray]];
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Invalid Rect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)findLinesAction:(id)sender {
    UIImage *image = self.cropImage;
    int minLineLength = image.size.width * LINE_MIN_SCALE;
    int maxLineGap = 25;
    
    NSArray *linePosArray = [self.detector findLinesPosYArray:image minLineLength:minLineLength maxLineGap:maxLineGap];
    
    CGFloat minLineDistance = image.size.width * kMinLineDistanceScale;
    linePosArray = [self filterLinePosArray:linePosArray withMinLineDistance:minLineDistance];

    CGFloat scale = self.showImageView.contentScale;
    CGFloat offsetY = self.showImageView.contentFrame.origin.y - self.showImageView.top;
    for (NSNumber *number in linePosArray) {
        CGFloat y = [number integerValue] * scale + offsetY;
        [self addLineViewToY:y];
    }
    
    /*
    CGFloat lowerValue = [self.sliderView getLowerSliderValue];
    CGFloat upperValue = [self.sliderView getUpperSliderValue];
    UIImage *lineImage = [self.detector debugFindLinesPosYArray:image minLineLength:minLineLength maxLineGap:maxLineGap lowerThreshold:lowerValue upperThreshold:upperValue];
    [self.showImageView setImage:lineImage];
     */
}

- (void)findContourAction:(id)sender {
    NSArray *sortedArray = [self getLinePosArray];
    if (!self.isLineArraySorted) {
        sortedArray = [self sortLinePosArray:sortedArray];
    }
    
    CGFloat lowerValue = [self.sliderView getLowerSliderValue];
    CGFloat upperValue = [self.sliderView getUpperSliderValue];
    
    UIImage *image;
    if (!sortedArray || [sortedArray count] == 0) {
        image = [self.detector findContours:self.cropImage linesArray:sortedArray minScale:kContourMinScale lowerThreshold:lowerValue upperThreshold:upperValue];
    } else {
        image = [self.detector segment:self.cropImage linesArray:sortedArray minScale:kSegmentMinScale lowerThreshold:lowerValue upperThreshold:upperValue];
    }
    [self.showImageView setImage:image];
}

- (void)showSliderAction:(id)sender {
    BOOL isHidden = [self.sliderView isHidden];
    [self setSliderViewHidden:!isHidden];
}

- (void)setSliderViewHidden:(BOOL)isHidden {
    CGRect sliderFrame = [self.sliderView frame];
    if (isHidden) {
        sliderFrame.origin.y = CGRectGetMinY(self.controlView.frame);
    } else {
        sliderFrame.origin.y = CGRectGetMinY(self.controlView.frame) - kSliderViewHeight;
        [self.sliderView setHidden:NO];
    }
    [UIView animateWithDuration:KAnimationDuration animations:^{
        [self.sliderView setFrame:sliderFrame];
    } completion:^(BOOL finished) {
        if (isHidden) {
            [self.sliderView setHidden:YES];
        }
    }];
}

- (void)doNothingAction:(id)sender {
    
}

#pragma mark - Gesture

- (void)tapGesture:(UITapGestureRecognizer *)tapGesture {
    if (![self.cropView isHidden]) {
        return;
    }
    CGPoint point = [tapGesture locationInView:self.showImageView];
    CGRect rect = [self.showImageView imageFrame];
    if (point.y < rect.origin.y) {
        return;
    }
    if (point.y > rect.origin.y + rect.size.height) {
        return;
    }
    
    [self addLineViewToY:point.y];
    self.isLineArraySorted = NO;
}

- (void)singlePanGesture:(UIPanGestureRecognizer *)gestureRecongizer {
    CGPoint point = [gestureRecongizer locationInView:self.cropView];    
    if (gestureRecongizer.state == UIGestureRecognizerStateBegan) {
        [self.cropView findPointAtLocation:point];
    }
    if (gestureRecongizer.state == UIGestureRecognizerStateEnded){
        self.cropView.activePoint.backgroundColor = [UIColor grayColor];
        self.cropView.activePoint = nil;
        [self.cropView checkAngle:0];
    }
    [self.cropView moveActivePointToLocation:point];
    
    // Draw Magnify Image
    BOOL magnifyIsShow = gestureRecongizer.state != UIGestureRecognizerStateEnded && self.cropView.activePoint && !self.cropView.middlePoint;
    [self setMagnifyShow:magnifyIsShow];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.numberOfTouches == 1) {
        CGPoint posInStretch = [gestureRecognizer locationInView:self.cropView];
        BOOL result = [self.cropView findPointAtLocation:posInStretch];
        if (result) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - LTLineDelegate
- (void)deleteLineWithTag:(NSInteger)tag {
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.linesArray];
    for (UIView *view in self.linesArray) {
        if ([view tag] == tag) {
            [tempArray removeObject:view];
            break;
        }
    }
    self.linesArray = [tempArray copy];
}

#pragma mark - Private Method
- (void)processImage {
    LTFramePointModel *framePointModel = [self.detector getEdgesRect:self.showImageView];
    if (framePointModel) {
        [self.cropView setCropFramePointModel:framePointModel];
    }
}

- (NSArray *)getLinePosArray {
    CGFloat scale = [self.showImageView contentScale];
    CGRect rect = [self.showImageView imageFrame];
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[self.linesArray count]];
    for (UIView *lineView in self.linesArray) {
        NSNumber *numberPos = [NSNumber numberWithFloat:(lineView.top - rect.origin.y + kLineDelButtonWH / 2) / scale];
        [tempArray addObject:numberPos];
    }
    
    return tempArray;
}

- (void)addLineViewToY:(CGFloat)y {
    CGRect contentRect = [self.showImageView contentFrame];
    LTLineView *lineView = [[LTLineView alloc] initWithFrame:CGRectMake(0, y, contentRect.size.width, kLineViewHeight)];
    lineView.tag = kLineBaseTag + self.linesArray.count;
    lineView.delegate = self;
    [self.showImageView addSubview:lineView];
   
    if (self.linesArray) {
        NSMutableArray *tempArray = [self.linesArray mutableCopy];
        [tempArray addObject:lineView];
        self.linesArray = [tempArray copy];
    } else {
        self.linesArray = [NSArray arrayWithObject:lineView];
    }
}

- (NSArray *)filterLinePosArray:(NSArray *)linePosArray withMinLineDistance:(CGFloat)minLineDistance {
    NSInteger count = [linePosArray count];
    if (count > 1) {
        NSArray *sortedArray = [self sortLinePosArray:linePosArray];
        NSInteger lastAddPosY = 0;
        NSMutableArray *filterArray = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 1; i < count; i++) {
            NSInteger posY = [sortedArray[i] integerValue];
            if (lastAddPosY == 0 || posY - lastAddPosY > minLineDistance) {
                [filterArray addObject:[NSNumber numberWithFloat:posY]];
                lastAddPosY = posY;
            }
        }
        return [filterArray copy];
    } else {
        return linePosArray;
    }
}

- (NSArray *)sortLinePosArray:(NSArray *)linePosArray {
    NSArray *sortedArray = [linePosArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber * obj2) {
        NSInteger iVal1 = [obj1 integerValue];
        NSInteger iVal2 = [obj2 integerValue];
        if (iVal1 > iVal2) {
            return NSOrderedDescending;
        } else if (iVal1 < iVal2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    self.isLineArraySorted = YES;
    return sortedArray;
}

- (void)setMagnifyShow:(BOOL)isShow {
    if (isShow) {
        self.dragCount++;
        if (self.dragCount % kMagnifyDragCount != 0) {
            return;
        }
        
        NSUInteger imageCount = self.dragCount;
        
        CGPoint activePoint = CGPointMake(self.cropView.activePoint.frame.origin.x, self.cropView.activePoint.frame.origin.y);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            CGFloat x = activePoint.x - kMagnifyImageWH / 2 + self.cropView.frame.origin.x;
            CGFloat y = activePoint.y - kMagnifyImageWH / 2 + self.cropView.frame.origin.y;
            CGRect subRect = CGRectMake(x, y, kMagnifyImageWH, kMagnifyImageWH);
            
            UIImage *magnifyImage = [self.contentView convertViewToImageWithRect:subRect];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (imageCount < self.currentCount || self.dragCount == 0) {
                    return;
                }
                self.currentCount = imageCount;
                
                self.magnifyImageView.image = magnifyImage;
                self.magnifyImageView.hidden = NO;
                
                CGFloat buttonPadding = kCropButtonSize / 2;
                self.magnifyImageView.frame = CGRectMake(activePoint.x + self.cropView.frame.origin.x - kMagnifyImageWH / 2, activePoint.y + self.cropView.frame.origin.y - kMagnifyImageWH  - buttonPadding, kMagnifyImageWH, kMagnifyImageWH);
            });
        });
    } else {
        self.magnifyImageView.hidden = YES;
        self.dragCount = 0;
        self.currentCount = 0;
    }
}

#pragma mark - ControlView Property

- (void)switchViewControlWithModelArray:(NSArray *)controlModelArray {
    CGRect controlFrame = [self.controlView frame];
    CGRect newFrame = [self.controlView frame];
    newFrame.origin.y = SCREEN_HEIGHT;
    [UIView animateWithDuration:KAnimationDuration animations:^{
        [self.controlView setFrame:newFrame];
    } completion:^(BOOL finished) {
        [self.controlView setControlByControlModelArray:controlModelArray];
        [self.controlView setFrame:controlFrame];
    }];
}

- (NSArray *)getCropControlModelArray {
    LTProcessControlModel *model1 = [[LTProcessControlModel alloc] init];
    model1.controlImgName = @"back";
    model1.controlMethod = @"backAction:";
    
    LTProcessControlModel *model2 = [[LTProcessControlModel alloc] init];
    model2.controlImgName = @"";
    model2.controlMethod = @"doNothingAction:";
    
    LTProcessControlModel *model3 = [[LTProcessControlModel alloc] init];
    model3.controlImgName = @"";
    model3.controlMethod = @"doNothingAction:";
    
    LTProcessControlModel *model4 = [[LTProcessControlModel alloc] init];
    model4.controlImgName = @"crop";
    model4.controlMethod = @"cropAction:";
    
    return @[model1, model2, model3, model4];
}

- (NSArray *)getProcessControlModelArray {
    LTProcessControlModel *model1 = [[LTProcessControlModel alloc] init];
    model1.controlImgName = @"back";
    model1.controlMethod = @"backCropAction:";
    
    
//    LTProcessControlModel *model2 = [[LTProcessControlModel alloc] init];
//    model2.controlImgName = @"search";
//    model2.controlMethod = @"showSliderAction:";
    
    LTProcessControlModel *model3 = [[LTProcessControlModel alloc] init];
    model3.controlImgName = @"search";
    model3.controlMethod = @"findLinesAction:";
    
    LTProcessControlModel *model4 = [[LTProcessControlModel alloc] init];
    model4.controlImgName = @"done";
    model4.controlMethod = @"findContourAction:";

    return @[model1, model3, model4];
}

#pragma mark- Getters and Setters
- (LTImageDetector *)detector {
    if (!_detector) {
        _detector = [[LTImageDetector alloc] init];
    }
    return _detector;
}

- (UIImageView *)magnifyImageView {
    if (!_magnifyImageView) {
        _magnifyImageView = [[UIImageView alloc] init];
        _magnifyImageView.contentMode = UIViewContentModeScaleAspectFill;
        _magnifyImageView.layer.cornerRadius = kMagnifyImageWH /2;
        _magnifyImageView.layer.masksToBounds = YES;
        _magnifyImageView.layer.borderWidth = kMagnifyBorderWidth;
        _magnifyImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self.view addSubview:_magnifyImageView];
    }
    return _magnifyImageView;
}


@end
