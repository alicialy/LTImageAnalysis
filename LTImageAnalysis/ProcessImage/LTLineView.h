//
//  LTLineView.h
//  LTImageAnalysis
//
//  Created by Alicia on 2017/11/1.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kLineHeight             2
#define kLineDelButtonWH        24
#define kLineViewHeight         kLineDelButtonWH

@protocol LTLineDelegate <NSObject>

- (void)deleteLineWithTag:(NSInteger)tag;

@end

@interface LTLineView : UIView

@property (nonatomic, weak) id delegate;

@end
