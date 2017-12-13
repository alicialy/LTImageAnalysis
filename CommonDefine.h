//
//  CommonDefine.h
//  LTImageAnalysis
//
//  Created by Alicia on 2017/10/27.
//  Copyright © 2017年 LeafTeam. All rights reserved.
//

#ifndef CommonDefine_h
#define CommonDefine_h


#endif /* CommonDefine_h */

// Log
#ifdef DEBUG
    #define LTLog(args, ...)    NSLog((@"%s - [Line:%d] -- " args), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define LTLog(args, ...)
#endif

// Size
#define SCREEN_WIDTH            ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT           ([[UIScreen mainScreen] bounds].size.height)
#define STATUSBAR_HEIGHT        ([[UIApplication sharedApplication] statusBarFrame].size.height)

#define MAIN_PADDING            15

// Color
#define MAIN_COLOR              [UIColor colorWithRed:0.0f/255 green:155.0f/255 blue:255.0f/255 alpha:1.0f]
#define BUTTON_COLOR            [UIColor whiteColor]

// Image Analysis
#define LINE_MIN_SCALE          0.3
#define LINE_MAX_GAP_SCALE      0.05

#define DEBUG_LOWER_THRESHOLD           40
#define DEBUG_UPPER_THRESHOLD           90

#define CANNY_LINE_LOWER_THRESHOLD      40
#define CANNY_LINE_UPPER_THRESHOLD      90

#define CANNY_CONTOUR_LOWER_THRESHOLD   25
#define CANNY_CONTOUR_UPPER_THRESHOLD   75


