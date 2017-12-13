//
//  LTSliderView.h
//  LTImageAnalysis
//
//  Created by Alicia on 2017/11/10.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kSliderHeight       40
#define kPadding            MAIN_PADDING
#define kSliderViewHeight   ((kSliderHeight + kPadding) * 2)

@interface LTSliderView : UIView

- (float)getLowerSliderValue;
- (float)getUpperSliderValue;

@end
