//
//  LTSliderView.m
//  LTImageAnalysis
//
//  Created by Alicia on 2017/11/10.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import "LTSliderView.h"
#import "CommonDefine.h"
#import "UIView+LTAddtions.h"
#import "LTValuedSlider.h"

#define kSliderMaxValue     200
#define kViewAlpha          0.7

@interface LTSliderView ()

@property (nonatomic, strong) LTValuedSlider *upperSlider;
@property (nonatomic, strong) LTValuedSlider *lowerSlider;

@end


@implementation LTSliderView

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
    }
    return self;
}


- (void)setupViews {
    [self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:kViewAlpha]];
    
    CGFloat width = SCREEN_WIDTH - 2 * kPadding;
    
    CGRect lowerSliderFrame = CGRectMake(kPadding, MAIN_PADDING, width, kSliderHeight);
    LTValuedSlider *lowerSlider = [[LTValuedSlider alloc] initWithFrame:lowerSliderFrame];
    [lowerSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:lowerSlider];
    self.lowerSlider = lowerSlider;
    
    CGRect upperSliderFrame = CGRectMake(kPadding, CGRectGetMaxY(lowerSliderFrame) + kPadding / 2, width, kSliderHeight);
    LTValuedSlider *upperSlider = [[LTValuedSlider alloc] initWithFrame:upperSliderFrame];
    [upperSlider addTarget:self action:@selector(sliderValueChangedAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:upperSlider];
    self.upperSlider = upperSlider;
    
    [self.lowerSlider setMaximumValue:kSliderMaxValue];
    [self.upperSlider setMaximumValue:kSliderMaxValue];
    [self.lowerSlider setValue:DEBUG_LOWER_THRESHOLD];
    [self.upperSlider setValue:DEBUG_UPPER_THRESHOLD];
}

#pragma mark - Public Method
- (float)getLowerSliderValue {
    return self.lowerSlider.value;
}

- (float)getUpperSliderValue {
    return self.upperSlider.value;
}

#pragma mark - Actions
- (void)sliderValueChangedAction:(UISlider *)slider {
    /*
     float sliderValue = [slider value];
     if (slider == self.upperSlider) {
     if (sliderValue > [self.lowerSlider value]) {
     [self setCannyImage];
     }
     } else if (slider == self.lowerSlider) {
     if (sliderValue < [self.upperSlider value]) {
     [self setCannyImage];
     }
     }
     */
}


@end
