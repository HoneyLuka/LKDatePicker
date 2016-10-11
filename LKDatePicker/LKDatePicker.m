//
//  LKDatePicker.m
//  LKDatePicker
//
//  Created by Luka on 13-11-15.
//  Copyright (c) 2013年 HoneyLuka. All rights reserved.
//

#import "LKDatePicker.h"

#define YEAR_CIRCULATE_TIMES 50

#define MONTH_CIRCULATE_TIMES 1000
#define MONTH_COUNT 12

#define DAY_CIRCULATE_TIMES 400

#define HOUR_CIRCULATE_TIMES 500
#define HOUR_COUNT 24

#define MINUTE_CIRCULATE_TIMES 200
#define MINUTE_COUNT 60

const NSUInteger kCalendarUnitsAll =
NSCalendarUnitYear |
NSCalendarUnitMonth |
NSCalendarUnitDay |
NSCalendarUnitHour |
NSCalendarUnitMinute;

const NSInteger kLKDatePickerYearComponent = 0;
const NSInteger kLKDatePickerMonthComponent = 1;
const NSInteger kLKDatePickerDayComponent = 2;
const NSInteger kLKDatePickerHourComponent = 3;
const NSInteger kLKDatePickerMinuteComponent = 4;

const NSInteger kLKDatePickerDefaultOffset = 200;

NSString * const kLKDatePickerDefaultFormat = @"yyyy-MM-dd HH:mm";

const CGFloat kLKDatePickerToolBarHeight = 40.f;

@interface LKDatePicker () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong, readwrite) NSDate *date;
@property (nonatomic, copy, readwrite) NSString *dateString;

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, assign) NSInteger defaultYear;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;
@property (nonatomic, assign) NSInteger hour;
@property (nonatomic, assign) NSInteger minute;

@end

@implementation LKDatePicker

#pragma mark - Init

+ (instancetype)picker
{
    LKDatePicker *picker = [[LKDatePicker alloc]init];
    return picker;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dateFormat = kLKDatePickerDefaultFormat;
    self.preOffset = kLKDatePickerDefaultOffset;
    self.sufOffset = kLKDatePickerDefaultOffset;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.formatter = [[NSDateFormatter alloc]init];
    
    [self initView];
}

#pragma mark - Views

- (void)initView
{
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
    [self initContentView];
    [self initPickerView];
    [self initToolBar];
    [self initCloseButton];
}

- (void)initContentView
{
    self.contentView = [[UIView alloc]init];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    
    NSLayoutConstraint *leftConst = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *bottomConst = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *rightConst = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraints:@[leftConst, bottomConst, rightConst]];
}

- (void)initPickerView
{
    self.pickerView = [[UIPickerView alloc]initWithFrame:self.bounds];
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.showsSelectionIndicator = YES;
    [self.contentView addSubview:self.pickerView];
    
    NSLayoutConstraint *leftConst = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *bottomConst = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *rightConst = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:0];
    [self.contentView addConstraints:@[leftConst, bottomConst, rightConst]];
}

- (void)initToolBar
{
    self.toolBar = [[UIView alloc]init];
    self.toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolBar.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.0];
    [self.contentView addSubview:self.toolBar];
    
    NSLayoutConstraint *heightConst = [NSLayoutConstraint constraintWithItem:self.toolBar
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute multiplier:1
                                                                    constant:kLKDatePickerToolBarHeight];
    [self.toolBar addConstraint:heightConst];
    
    NSLayoutConstraint *leftConst = [NSLayoutConstraint constraintWithItem:self.toolBar
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.contentView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *rightConst = [NSLayoutConstraint constraintWithItem:self.toolBar
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:0];
    NSLayoutConstraint *topConst = [NSLayoutConstraint constraintWithItem:self.toolBar
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.contentView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *bottomConst = [NSLayoutConstraint constraintWithItem:self.toolBar
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.pickerView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0];
    [self.contentView addConstraints:@[leftConst, topConst, rightConst, bottomConst]];
}

- (void)initCloseButton
{
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.closeButton setTitle:@"完成" forState:UIControlStateNormal];
    self.closeButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self.closeButton addTarget:self
                         action:@selector(dismiss)
               forControlEvents:UIControlEventTouchUpInside];
    
    [self.toolBar addSubview:self.closeButton];
    
    NSLayoutConstraint *topConst = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.toolBar
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *rightConst = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.toolBar
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:0];
    NSLayoutConstraint *bottomConst = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolBar
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *widthConst = [NSLayoutConstraint constraintWithItem:self.closeButton
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:kLKDatePickerToolBarHeight];
    [self.closeButton addConstraint:widthConst];
    [self.toolBar addConstraints:@[topConst, bottomConst, rightConst]];
}

#pragma mark - Methods

- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showInView:window];
}

- (void)showInView:(UIView *)view
{
    if (!view) {
        return;
    }
    
    if (self.superview) {
        [self removeFromSuperview];
    }
    
    self.alpha = 0;
    
    [self resetAll];
    [view addSubview:self];
    [self configConst:view];
    
    CGSize size = [self.contentView systemLayoutSizeFittingSize:view.bounds.size];
    self.contentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, size.height);
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        self.contentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (self.onShow) {
            self.onShow(self);
        }
    }];
}

- (void)configConst:(UIView *)view
{
    NSLayoutConstraint *leftConst = [NSLayoutConstraint constraintWithItem:self
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:view
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1
                                                                  constant:0];
    NSLayoutConstraint *bottomConst = [NSLayoutConstraint constraintWithItem:self
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:view
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0];
    NSLayoutConstraint *rightConst = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:0];
    NSLayoutConstraint *topConst = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:view
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0];
    [view addConstraints:@[leftConst, rightConst, topConst, bottomConst]];
}

- (void)dismiss
{
    if (!self.superview) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.contentView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity,
                                                                0,
                                                                CGRectGetHeight(self.contentView.bounds));
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.onClose) {
            self.onClose(self);
        }
        [self removeFromSuperview];
    }];
}

- (void)resetAll
{
    [self reloadDefaultDate];
    [self updateDate];
    [self resetComponents:kCalendarUnitsAll];
}

- (void)resetComponents:(NSCalendarUnit)unit
{
    if (unit & NSCalendarUnitYear) {
        NSInteger index = [self calculateRealIndex:self.year - self.minYear
                                    circulateTimes:YEAR_CIRCULATE_TIMES
                                      elementCount:[self calculateForYearsCount]];
        [self.pickerView selectRow:index inComponent:kLKDatePickerYearComponent animated:NO];
    }
    
    if (unit & NSCalendarUnitMonth) {
        NSInteger index = [self calculateRealIndex:self.month - 1
                                    circulateTimes:MONTH_CIRCULATE_TIMES
                                      elementCount:MONTH_COUNT];
        [self.pickerView selectRow:index inComponent:kLKDatePickerMonthComponent animated:NO];
    }
    
    if (unit & NSCalendarUnitDay) {
        NSInteger index = [self calculateRealIndex:self.day - 1
                                    circulateTimes:DAY_CIRCULATE_TIMES
                                      elementCount:[self calculateForDays]];
        [self.pickerView selectRow:index inComponent:kLKDatePickerDayComponent animated:NO];
    }
    
    if (self.type != LKDatePickerTypeFull) {
        return;
    }
    
    if (unit & NSCalendarUnitHour) {
        NSInteger index = [self calculateRealIndex:self.hour
                                    circulateTimes:HOUR_CIRCULATE_TIMES
                                      elementCount:HOUR_COUNT];
        [self.pickerView selectRow:index inComponent:kLKDatePickerHourComponent animated:NO];
    }
    
    if (unit & NSCalendarUnitMinute) {
        NSInteger index = [self calculateRealIndex:self.minute
                                    circulateTimes:MINUTE_CIRCULATE_TIMES
                                      elementCount:MINUTE_COUNT];
        [self.pickerView selectRow:index inComponent:kLKDatePickerMinuteComponent animated:NO];
    }
}

- (void)reloadDefaultDate
{
    if (!self.defaultDate) {
        self.defaultDate = [NSDate date];
    }
    
    NSDateComponents *components = [[NSCalendar currentCalendar]components:kCalendarUnitsAll
                                                                  fromDate:self.defaultDate];
    self.defaultYear = components.year;
    self.year = components.year;
    self.month = components.month;
    self.day = components.day;
    self.hour = components.hour;
    self.minute = components.minute;
}

- (void)updateDate
{
    [self.formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSString *dateString = [NSString stringWithFormat:@"%ld-%ld-%ld-%ld-%ld",
                            self.year, self.month, self.day, self.hour, self.minute];
    self.date = [self.formatter dateFromString:dateString];
    
    if (self.dateFormat.length) {
        [self.formatter setDateFormat:self.dateFormat];
        self.dateString = [self.formatter stringFromDate:self.date];
    }
}

#pragma mark - Action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.tapToClose) {
        [self dismiss];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    
}

#pragma mark - Utils

- (NSInteger)calculateRealIndex:(NSInteger)originIndex
                 circulateTimes:(NSInteger)times
                   elementCount:(NSInteger)count
{
    if (times % 2 != 0) {
        times--;
    }
    
    NSInteger index = originIndex + times / 2 * count;
    return index;
}

- (NSInteger)minYear
{
    return self.defaultYear - self.preOffset;
}

- (NSInteger)maxYear
{
    return self.defaultYear + self.sufOffset;
}

- (NSInteger)calculateForYearsCount
{
    return self.maxYear - self.minYear + 1;
}

//计算选中的月份有多少天
- (NSInteger)calculateForDays
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM"];
    
    NSString *dateString = [NSString stringWithFormat:@"%ld-%ld", self.year, self.month];
    
    NSDate *date = [formatter dateFromString:dateString];
    
    NSRange dayRange = [self.calendar rangeOfUnit:NSCalendarUnitDay
                                           inUnit:NSCalendarUnitMonth
                                          forDate:date];
    return dayRange.length;
}

#pragma mark - UIPickerViewDelegate and DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.type == LKDatePickerTypeFull) {
        return 5;
        
    }
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case kLKDatePickerYearComponent:
            return YEAR_CIRCULATE_TIMES * [self calculateForYearsCount];
            
        case kLKDatePickerMonthComponent:
            return MONTH_CIRCULATE_TIMES * MONTH_COUNT;
            
        case kLKDatePickerDayComponent:
            return [self calculateForDays] * DAY_CIRCULATE_TIMES;
            
        case kLKDatePickerHourComponent:
            return HOUR_CIRCULATE_TIMES * HOUR_COUNT;
            
        case kLKDatePickerMinuteComponent:
            return MINUTE_CIRCULATE_TIMES * MINUTE_COUNT;
            
        default:
            return 0;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat maxWidth = CGRectGetWidth(pickerView.bounds) * 0.9f;
    NSInteger maxComponents = self.type == LKDatePickerTypeFull ? 5 : 3;
    
    return floor(maxWidth / maxComponents);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    
    if (!label) {
        label = [[UILabel alloc]init];
        label.font = [UIFont boldSystemFontOfSize:14.f];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    switch (component) {
        case 0:
            label.text = [NSString stringWithFormat:@"%ld年", row % [self calculateForYearsCount] + self.minYear];
            break;
            
        case 1:
            label.text = [NSString stringWithFormat:@"%.2ld月", row % MONTH_COUNT + 1];
            break;
            
        case 2:
            label.text = [NSString stringWithFormat:@"%.2ld日", row % [self calculateForDays] + 1];
            break;
            
        case 3:
            label.text = [NSString stringWithFormat:@"%.2ld时", row % HOUR_COUNT];
            break;
            
        case 4:
            label.text = [NSString stringWithFormat:@"%.2ld分", row % MINUTE_COUNT];
            break;
            
        default:
            return nil;
            break;
    }
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case kLKDatePickerYearComponent:
            self.year = row % [self calculateForYearsCount] + self.minYear;
            
            if ([self calculateForDays] < self.day) {
                self.day = [self calculateForDays];
            }
            
            [pickerView reloadComponent:kLKDatePickerDayComponent];
            [self resetComponents:NSCalendarUnitYear | NSCalendarUnitDay];
            break;
            
        case kLKDatePickerMonthComponent:
            self.month = row % MONTH_COUNT + 1;
            
            if ([self calculateForDays] < self.day) {
                self.day = [self calculateForDays];
            }
            
            //更新day
            [pickerView reloadComponent:kLKDatePickerDayComponent];
            [self resetComponents:NSCalendarUnitMonth | NSCalendarUnitDay];
            break;
            
        case 2:
            self.day = row % [self calculateForDays] + 1;
            
            [self resetComponents:NSCalendarUnitDay];
            break;
            
        case 3:
            self.hour = row % HOUR_COUNT;
            
            [self resetComponents:NSCalendarUnitHour];
            break;
            
        case 4:
            self.minute = row % MINUTE_COUNT;
            
            [self resetComponents:NSCalendarUnitMinute];
            break;
            
        default:
            break;
    }
    
    [self updateDate];
    
    if (self.onChange) {
        self.onChange(self);
    }
    //    NSLog(@"%ld年, %ld月, %ld日, %ld时, %ld分",
    //          self.year, self.month, self.day, self.hour, self.minute);
}

@end
