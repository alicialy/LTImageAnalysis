//
//  LTProcessControlView.m
//  LTImageAnalysis
//
//  Created by alicia on 10/28/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import "LTProcessControlView.h"
#import "CommonDefine.h"
#import "UIView+LTAddtions.h"
#import "LTProcessControlModel.h"


#define kButtonHeight           44

@interface LTProcessControlView ()

@property (assign, nonatomic) id target;

@end


@implementation LTProcessControlView

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
    [self setBackgroundColor:MAIN_COLOR];
}

#pragma mark - Public Method
- (void)addTarget:(id)target {
    self.target = target;
}

#pragma mark- Getters and Setters
- (void)setControlByControlModelArray:(NSArray *)controlModelArray {
    if (!self.target) {
        LTLog(@"setControlModelArray error, target not set");
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat buttonWidth = self.width / controlModelArray.count;
    CGFloat paddingY = (self.height - kButtonHeight) / 2;
    for (NSInteger i = 0; i < controlModelArray.count; i++) {
        CGRect rect = CGRectMake(i * buttonWidth, paddingY, buttonWidth, kButtonHeight);
        UIButton *button = [[UIButton alloc] initWithFrame:rect];
        LTProcessControlModel *controlModel = controlModelArray[i];
        UIImage *btnImage = [[UIImage imageNamed:controlModel.controlImgName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:btnImage forState:UIControlStateNormal];
        [button setTintColor:BUTTON_COLOR];
        [button addTarget:self.target action:NSSelectorFromString(controlModel.controlMethod) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

@end
