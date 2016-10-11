//
//  LKDatePicker.h
//  LKDatePicker
//
//  Created by Luka on 13-11-15.
//  Copyright (c) 2013年 HoneyLuka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LKDatePicker;
typedef void(^LKDatePickerHandler)(LKDatePicker *picker);

typedef enum {
    LKDatePickerTypeFull = 0,    //年月日时分
    LKDatePickerTypePlain,       //年月日
}LKDatePickerType;

@interface LKDatePicker : UIView

#pragma mark - Output

@property (nonatomic, strong, readonly) NSDate *date;
@property (nonatomic, copy, readonly) NSString *dateString;

@property (nonatomic, copy) LKDatePickerHandler onShow;
@property (nonatomic, copy) LKDatePickerHandler onChange;
@property (nonatomic, copy) LKDatePickerHandler onClose;

#pragma mark - Input

@property (nonatomic, assign) LKDatePickerType type;

/**
 If nil, will use nowDate.
 */
@property (nonatomic, copy) NSDate *defaultDate;

/**
 Using this to format dateString. Default is 'yyyy-MM-dd HH:mm'.
 */
@property (nonatomic, copy) NSString *dateFormat;

/**
 Close self when tap on blank. Default is NO.
 */
@property (nonatomic, assign) BOOL tapToClose;

/**
 Year offset, based on 'defaultDate'. Default is 200.
 */
@property (nonatomic, assign) NSInteger preOffset;
@property (nonatomic, assign) NSInteger sufOffset;

- (void)showInView:(UIView *)view;

/**
 Show in keyWindow.
 */
- (void)show;

+ (instancetype)picker;

@end
