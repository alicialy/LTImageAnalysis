//
//  LTValuedSlider.m
//  LTImageAnalysis
//
//  Created by Alicia on 2017/11/10.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import "LTValuedSlider.h"
#import "CommonDefine.h"

#define kLabelWidth     50
#define kLabelHeight    20

@interface LTValuedSlider ()

@property (strong, nonatomic) UILabel *valueLabel;

@end

@implementation LTValuedSlider


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
    UILabel *valueLabel = [[UILabel alloc] init];
    [valueLabel setTextColor:MAIN_COLOR];
    [self addSubview:valueLabel];
    self.valueLabel = valueLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateValueLabel];
}

#pragma mark - Public Method

- (void)isHideValue:(BOOL)isHideValue {
    _isHideValue = isHideValue;
    [self.valueLabel setHidden:isHideValue];
}

#pragma mark - Private method

- (CGRect)thumbRect {
    return  [self thumbRectForBounds:self.bounds
                           trackRect:[self trackRectForBounds:self.bounds]
                               value:self.value];
}

- (void)updateValueLabel {
    if (self.isHideValue) {
        return;
    }
    
    if (self.value) {
        [self.valueLabel setHidden:NO];
    } else {
        [self.valueLabel setHidden:YES];
    }
    
    CGRect thumbRect = [self thumbRect];
    CGFloat thumbW = thumbRect.size.width;
    CGFloat thumbH = thumbRect.size.height;
    
    NSString *valueString = [NSString stringWithFormat:@"%.1f", self.value];
    [self.valueLabel setText:valueString];
    
    CGRect labelRect = CGRectInset(thumbRect, (thumbW - kLabelWidth) / 2, (thumbH - kLabelHeight) / 2);
    labelRect.origin.y = thumbRect.origin.y - kLabelHeight;
    [self.valueLabel setFrame:labelRect];
}

@end
