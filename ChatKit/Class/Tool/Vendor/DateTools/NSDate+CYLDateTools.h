// Copyright (C) 2014 by Matthew York
//
// Permission is hereby granted, free of charge, to any
// person obtaining a copy of this software and
// associated documentation files (the "Software"), to
// deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge,
// publish, distribute, sublicense, and/or sell copies of the
// Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall
// be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
// BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "CYLError.h"

#ifndef DateToolsLocalizedStrings
#define DateToolsLocalizedStrings(key) \
NSLocalizedStringFromTableInBundle(key, @"DateTools", [NSBundle bundleWithPath:[[[NSBundle bundleForClass:[CYLError class]] resourcePath] stringByAppendingPathComponent:@"DateTools.bundle"]], nil)
#endif

#import <Foundation/Foundation.h>
#import "CYLDateToolsConstants.h"

@interface NSDate (DateTools)

#pragma mark - Time Ago
+ (NSString *)cyl_timeAgoSinceDate:(NSDate *)date;
+ (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date;
- (NSString *)cyl_timeAgoSinceNow;
- (NSString *)cyl_shortTimeAgoSinceNow;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates;
- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates numericTimes:(BOOL)useNumericTimes;
- (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date;


#pragma mark - Date Components Without Calendar
- (NSInteger)cyl_era;
- (NSInteger)cyl_year;
- (NSInteger)cyl_month;
- (NSInteger)cyl_day;
- (NSInteger)cyl_hour;
- (NSInteger)cyl_minute;
- (NSInteger)cyl_second;
- (NSInteger)cyl_weekday;
- (NSInteger)cyl_weekdayOrdinal;
- (NSInteger)cyl_quarter;
- (NSInteger)cyl_weekOfMonth;
- (NSInteger)cyl_weekOfYear;
- (NSInteger)cyl_yearForWeekOfYear;
- (NSInteger)cyl_daysInMonth;
- (NSInteger)cyl_dayOfYear;
- (NSInteger)cyl_daysInYear;
- (BOOL)cyl_isInLeapYear;
- (BOOL)cyl_isToday;
- (BOOL)cyl_isTomorrow;
- (BOOL)cyl_isYesterday;
- (BOOL)cyl_isWeekend;
- (BOOL)cyl_isSameDay:(NSDate *)date;
+ (BOOL)cyl_isSameDay:(NSDate *)date asDate:(NSDate *)compareDate;

#pragma mark - Date Components With Calendar


- (NSInteger)cyl_eraWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_yearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_monthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_dayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_hourWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_minuteWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_secondWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekdayWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekdayOrdinalWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_quarterWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekOfMonthWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_weekOfYearWithCalendar:(NSCalendar *)calendar;
- (NSInteger)cyl_yearForWeekOfYearWithCalendar:(NSCalendar *)calendar;


#pragma mark - Date Creating
+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString;
+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString timeZone:(NSTimeZone *)timeZone;


#pragma mark - Date Editing
#pragma mark Date By Adding
- (NSDate *)cyl_dateByAddingYears:(NSInteger)years;
- (NSDate *)cyl_dateByAddingMonths:(NSInteger)months;
- (NSDate *)cyl_dateByAddingWeeks:(NSInteger)weeks;
- (NSDate *)cyl_dateByAddingDays:(NSInteger)days;
- (NSDate *)cyl_dateByAddingHours:(NSInteger)hours;
- (NSDate *)cyl_dateByAddingMinutes:(NSInteger)minutes;
- (NSDate *)cyl_dateByAddingSeconds:(NSInteger)seconds;
#pragma mark Date By Subtracting
- (NSDate *)cyl_dateBySubtractingYears:(NSInteger)years;
- (NSDate *)cyl_dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)cyl_dateBySubtractingWeeks:(NSInteger)weeks;
- (NSDate *)cyl_dateBySubtractingDays:(NSInteger)days;
- (NSDate *)cyl_dateBySubtractingHours:(NSInteger)hours;
- (NSDate *)cyl_dateBySubtractingMinutes:(NSInteger)minutes;
- (NSDate *)cyl_dateBySubtractingSeconds:(NSInteger)seconds;

#pragma mark - Date Comparison
#pragma mark Time From
-(NSInteger)cyl_yearsFrom:(NSDate *)date;
-(NSInteger)cyl_monthsFrom:(NSDate *)date;
-(NSInteger)cyl_weeksFrom:(NSDate *)date;
-(NSInteger)cyl_daysFrom:(NSDate *)date;
-(double)cyl_hoursFrom:(NSDate *)date;
-(double)cyl_minutesFrom:(NSDate *)date;
-(double)cyl_secondsFrom:(NSDate *)date;
#pragma mark Time From With Calendar
-(NSInteger)cyl_yearsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_monthsFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_weeksFrom:(NSDate *)date calendar:(NSCalendar *)calendar;
-(NSInteger)cyl_daysFrom:(NSDate *)date calendar:(NSCalendar *)calendar;

#pragma mark Time Until
-(NSInteger)cyl_yearsUntil;
-(NSInteger)cyl_monthsUntil;
-(NSInteger)cyl_weeksUntil;
-(NSInteger)cyl_daysUntil;
-(double)cyl_hoursUntil;
-(double)cyl_minutesUntil;
-(double)cyl_secondsUntil;
#pragma mark Time Ago
-(NSInteger)cyl_yearsAgo;
-(NSInteger)cyl_monthsAgo;
-(NSInteger)cyl_weeksAgo;
-(NSInteger)cyl_daysAgo;
-(double)cyl_hoursAgo;
-(double)cyl_minutesAgo;
-(double)cyl_secondsAgo;
#pragma mark Earlier Than
-(NSInteger)cyl_yearsEarlierThan:(NSDate *)date;
-(NSInteger)cyl_monthsEarlierThan:(NSDate *)date;
-(NSInteger)cyl_weeksEarlierThan:(NSDate *)date;
-(NSInteger)cyl_daysEarlierThan:(NSDate *)date;
-(double)cyl_hoursEarlierThan:(NSDate *)date;
-(double)cyl_minutesEarlierThan:(NSDate *)date;
-(double)cyl_secondsEarlierThan:(NSDate *)date;
#pragma mark Later Than
-(NSInteger)cyl_yearsLaterThan:(NSDate *)date;
-(NSInteger)cyl_monthsLaterThan:(NSDate *)date;
-(NSInteger)cyl_weeksLaterThan:(NSDate *)date;
-(NSInteger)cyl_daysLaterThan:(NSDate *)date;
-(double)cyl_hoursLaterThan:(NSDate *)date;
-(double)cyl_minutesLaterThan:(NSDate *)date;
-(double)cyl_secondsLaterThan:(NSDate *)date;
#pragma mark Comparators
-(BOOL)cyl_isEarlierThan:(NSDate *)date;
-(BOOL)cyl_isLaterThan:(NSDate *)date;
-(BOOL)cyl_isEarlierThanOrEqualTo:(NSDate *)date;
-(BOOL)cyl_isLaterThanOrEqualTo:(NSDate *)date;

#pragma mark - Formatted Dates
#pragma mark Formatted With Style
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style locale:(NSLocale *)locale;
-(NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;
#pragma mark Formatted With Format
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale;
-(NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale;

#pragma mark - Helpers
+(NSString *)cyl_defaultCalendarIdentifier;
+ (void)cyl_setDefaultCalendarIdentifier:(NSString *)identifier;
@end
