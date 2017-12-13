//
//  LTProcessControlView.h
//  LTImageAnalysis
//
//  Created by alicia on 10/28/17.
//  Copyright © 2017 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kControlViewHeight          50      // This View Height

@interface LTProcessControlView : UIView

- (void)setControlByControlModelArray:(NSArray *)controlModelArray;

- (void)addTarget:(id)target;

@end
