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

#import "NSDate+CYLDateTools.h"
#import "CYLError.h"

typedef NS_ENUM(NSUInteger, DTDateComponent){
    DTDateComponentEra,
    DTDateComponentYear,
    DTDateComponentMonth,
    DTDateComponentDay,
    DTDateComponentHour,
    DTDateComponentMinute,
    DTDateComponentSecond,
    DTDateComponentWeekday,
    DTDateComponentWeekdayOrdinal,
    DTDateComponentQuarter,
    DTDateComponentWeekOfMonth,
    DTDateComponentWeekOfYear,
    DTDateComponentYearForWeekOfYear,
    DTDateComponentDayOfYear
};

typedef NS_ENUM(NSUInteger, DateAgoFormat){
    DateAgoLong,
    DateAgoLongUsingNumericDatesAndTimes,
    DateAgoLongUsingNumericDates,
    DateAgoLongUsingNumericTimes,
    DateAgoShort
};

typedef NS_ENUM(NSUInteger, DateAgoValues){
    YearsAgo,
    MonthsAgo,
    WeeksAgo,
    DaysAgo,
    HoursAgo,
    MinutesAgo,
    SecondsAgo
};

static const unsigned int allCalendarUnitFlags = NSCalendarUnitYear | NSCalendarUnitQuarter | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitEra | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekOfYear;

static NSString *defaultCalendarIdentifier = nil;
static NSCalendar *implicitCalendar = nil;

@implementation NSDate (DateTools)

+ (void)load {
    [self cyl_setDefaultCalendarIdentifier:NSCalendarIdentifierGregorian];
}

#pragma mark - Time Ago


/**
 *  Takes in a date and returns a string with the most convenient unit of time representing
 *  how far in the past that date is from now.
 *
 *  @param NSDate - Date to be measured from now
 *
 *  @return NSString - Formatted return string
 */
+ (NSString *)cyl_timeAgoSinceDate:(NSDate *)date {
    return [date cyl_timeAgoSinceDate:[NSDate date]];
}

/**
 *  Takes in a date and returns a shortened string with the most convenient unit of time representing
 *  how far in the past that date is from now.
 *
 *  @param NSDate - Date to be measured from now
 *
 *  @return NSString - Formatted return string
 */
+ (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date {
    return [date cyl_shortTimeAgoSinceDate:[NSDate date]];
}

/**
 *  Returns a string with the most convenient unit of time representing
 *  how far in the past that date is from now.
 *
 *  @return NSString - Formatted return string
 */
- (NSString *)cyl_timeAgoSinceNow {
    return [self cyl_timeAgoSinceDate:[NSDate date]];
}

/**
 *  Returns a shortened string with the most convenient unit of time representing
 *  how far in the past that date is from now.
 *
 *  @return NSString - Formatted return string
 */
- (NSString *)cyl_shortTimeAgoSinceNow {
    return [self cyl_shortTimeAgoSinceDate:[NSDate date]];
}

- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date {
    return [self cyl_timeAgoSinceDate:date numericDates:NO];
}

- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates{
    return [self cyl_timeAgoSinceDate:date numericDates:useNumericDates numericTimes:NO];
}

- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date numericDates:(BOOL)useNumericDates numericTimes:(BOOL)useNumericTimes{
    if (useNumericDates && useNumericTimes) {
        return [self cyl_timeAgoSinceDate:date format:DateAgoLongUsingNumericDatesAndTimes];
    } else if (useNumericDates) {
        return [self cyl_timeAgoSinceDate:date format:DateAgoLongUsingNumericDates];
    } else if (useNumericTimes) {
        return [self cyl_timeAgoSinceDate:date format:DateAgoLongUsingNumericDates];
    } else {
        return [self cyl_timeAgoSinceDate:date format:DateAgoLong];
    }
}

- (NSString *)cyl_shortTimeAgoSinceDate:(NSDate *)date {
    return [self cyl_timeAgoSinceDate:date format:DateAgoShort];
}

- (NSString *)cyl_timeAgoSinceDate:(NSDate *)date format:(DateAgoFormat)format {

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;

    // if timeAgo < 24h => compare DateTime else compare Date only
    NSUInteger upToHours = NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour;
    NSDateComponents *difference = [calendar components:upToHours fromDate:earliest toDate:latest options:0];
    
    if (difference.hour < 24) {
        if (difference.hour >= 1) {
            return [self cyl_localizedStringFor:format valueType:HoursAgo value:difference.hour];
        } else if (difference.minute >= 1) {
            return [self cyl_localizedStringFor:format valueType:MinutesAgo value:difference.minute];
        } else {
            return [self cyl_localizedStringFor:format valueType:SecondsAgo value:difference.second];
        }
        
    } else {
        NSUInteger bigUnits = NSCalendarUnitTimeZone | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear;
        
        NSDateComponents *components = [calendar components:bigUnits fromDate:earliest];
        earliest = [calendar dateFromComponents:components];
        
        components = [calendar components:bigUnits fromDate:latest];
        latest = [calendar dateFromComponents:components];

        difference = [calendar components:bigUnits fromDate:earliest toDate:latest options:0];
        
        if (difference.year >= 1) {
            return [self cyl_localizedStringFor:format valueType:YearsAgo value:difference.year];
        } else if (difference.month >= 1) {
            return [self cyl_localizedStringFor:format valueType:MonthsAgo value:difference.month];
        } else if (difference.weekOfYear >= 1) {
            return [self cyl_localizedStringFor:format valueType:WeeksAgo value:difference.weekOfYear];
        } else {
            return [self cyl_localizedStringFor:format valueType:DaysAgo value:difference.day];
        }
    }
}

- (NSString *)cyl_localizedStringFor:(DateAgoFormat)format valueType:(DateAgoValues)valueType value:(NSInteger)value {
    BOOL isShort = format == DateAgoShort;
    BOOL isNumericDate = format == DateAgoLongUsingNumericDates || format == DateAgoLongUsingNumericDatesAndTimes;
    BOOL isNumericTime = format == DateAgoLongUsingNumericTimes || format == DateAgoLongUsingNumericDatesAndTimes;
    
    switch (valueType) {
        case YearsAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@y" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@years ago" withValue:value];
            } else if (isNumericDate) {
                return DateToolsLocalizedStrings(@"1 year ago");
            } else {
                return DateToolsLocalizedStrings(@"Last year");
            }
        case MonthsAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@M" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@months ago" withValue:value];
            } else if (isNumericDate) {
                return DateToolsLocalizedStrings(@"1 month ago");
            } else {
                return DateToolsLocalizedStrings(@"Last month");
            }
        case WeeksAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@w" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@weeks ago" withValue:value];
            } else if (isNumericDate) {
                return DateToolsLocalizedStrings(@"1 week ago");
            } else {
                return DateToolsLocalizedStrings(@"Last week");
            }
        case DaysAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@d" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@days ago" withValue:value];
            } else if (isNumericDate) {
                return DateToolsLocalizedStrings(@"1 day ago");
            } else {
                return DateToolsLocalizedStrings(@"Yesterday");
            }
        case HoursAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@h" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@hours ago" withValue:value];
            } else if (isNumericTime) {
                return DateToolsLocalizedStrings(@"1 hour ago");
            } else {
                return DateToolsLocalizedStrings(@"An hour ago");
            }
        case MinutesAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@m" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@minutes ago" withValue:value];
            } else if (isNumericTime) {
                return DateToolsLocalizedStrings(@"1 minute ago");
            } else {
                return DateToolsLocalizedStrings(@"A minute ago");
            }
        case SecondsAgo:
            if (isShort) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d%@s" withValue:value];
            } else if (value >= 2) {
                return [self cyl_logicLocalizedStringFromFormat:@"%%d %@seconds ago" withValue:value];
            } else if (isNumericTime) {
                return DateToolsLocalizedStrings(@"1 second ago");
            } else {
                return DateToolsLocalizedStrings(@"Just now");
            }
    }
    return nil;
}

- (NSString *)cyl_logicLocalizedStringFromFormat:(NSString *)format withValue:(NSInteger)value {
    NSString * localeFormat = [NSString stringWithFormat:format, [self cyl_getLocaleFormatUnderscoresWithValue:value]];
    return [NSString stringWithFormat:DateToolsLocalizedStrings(localeFormat), value];
}

- (NSString *)cyl_getLocaleFormatUnderscoresWithValue:(double)value {
    NSString *localeCode = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
    
    // Russian (ru) and Ukrainian (uk)
    if([localeCode isEqualToString:@"ru"] || [localeCode isEqualToString:@"uk"]) {
        int XY = (int)floor(value) % 100;
        int Y = (int)floor(value) % 10;
        
        if(Y == 0 || Y > 4 || (XY > 10 && XY < 15)) {
            return @"";
        }

        if(Y > 1 && Y < 5 && (XY < 10 || XY > 20))  {
            return @"_";
        }

        if(Y == 1 && XY != 11) {
            return @"__";
        }
    }
    
    // Add more languages here, which are have specific translation rules...
    
    return @"";
}

#pragma mark - Date Components Without Calendar
/**
 *  Returns the era of the receiver. (0 for BC, 1 for AD for Gregorian)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_era{
    return [self cyl_componentForDate:self type:DTDateComponentEra calendar:nil];
}

/**
 *  Returns the year of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_year{
    return [self cyl_componentForDate:self type:DTDateComponentYear calendar:nil];
}

/**
 *  Returns the month of the year of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_month{
    return [self cyl_componentForDate:self type:DTDateComponentMonth calendar:nil];
}

/**
 *  Returns the day of the month of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_day{
    return [self cyl_componentForDate:self type:DTDateComponentDay calendar:nil];
}

/**
 *  Returns the hour of the day of the receiver. (0-24)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_hour{
    return [self cyl_componentForDate:self type:DTDateComponentHour calendar:nil];
}

/**
 *  Returns the minute of the receiver. (0-59)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_minute {
    return [self cyl_componentForDate:self type:DTDateComponentMinute calendar:nil];
}

/**
 *  Returns the second of the receiver. (0-59)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_second{
    return [self cyl_componentForDate:self type:DTDateComponentSecond calendar:nil];
}

/**
 *  Returns the day of the week of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_weekday{
    return [self cyl_componentForDate:self type:DTDateComponentWeekday calendar:nil];
}

/**
 *  Returns the ordinal for the day of the week of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_weekdayOrdinal{
    return [self cyl_componentForDate:self type:DTDateComponentWeekdayOrdinal calendar:nil];
}

/**
 *  Returns the quarter of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_quarter{
    return [self cyl_componentForDate:self type:DTDateComponentQuarter calendar:nil];
}

/**
 *  Returns the week of the month of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_weekOfMonth{
    return [self cyl_componentForDate:self type:DTDateComponentWeekOfMonth calendar:nil];
}

/**
 *  Returns the week of the year of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_weekOfYear{
    return [self cyl_componentForDate:self type:DTDateComponentWeekOfYear calendar:nil];
}

/**
 *  I honestly don't know much about this value...
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_yearForWeekOfYear{
    return [self cyl_componentForDate:self type:DTDateComponentYearForWeekOfYear calendar:nil];
}

/**
 *  Returns how many days are in the month of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_daysInMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange days = [calendar rangeOfUnit:NSCalendarUnitDay
                                  inUnit:NSCalendarUnitMonth
                                 forDate:self];
    return days.length;
}

/**
 *  Returns the day of the year of the receiver. (1-365 or 1-366 for leap year)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_dayOfYear{
    return [self cyl_componentForDate:self type:DTDateComponentDayOfYear calendar:nil];
}

/**
 *  Returns how many days are in the year of the receiver.
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_daysInYear{
    if (self.cyl_isInLeapYear) {
        return 366;
    }
    
    return 365;
}

/**
 *  Returns whether the receiver falls in a leap year.
 *
 *  @return NSInteger
 */
- (BOOL)cyl_isInLeapYear{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *dateComponents = [calendar components:allCalendarUnitFlags fromDate:self];
    
    if (dateComponents.year%400 == 0){
        return YES;
    }
    else if (dateComponents.year%100 == 0){
        return NO;
    }
    else if (dateComponents.year%4 == 0){
        return YES;
    }
    
    return NO;
}

- (BOOL)cyl_isToday {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
	NSDate *today = [cal dateFromComponents:components];
	components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
	NSDate *otherDate = [cal dateFromComponents:components];

	return [today isEqualToDate:otherDate];
}

- (BOOL)cyl_isTomorrow {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[[NSDate date] cyl_dateByAddingDays:1]];
	NSDate *tomorrow = [cal dateFromComponents:components];
	components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
	NSDate *otherDate = [cal dateFromComponents:components];
    
	return [tomorrow isEqualToDate:otherDate];
}

- (BOOL)cyl_isYesterday{
    NSCalendar *cal = [NSCalendar currentCalendar];
	NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[[NSDate date] cyl_dateBySubtractingDays:1]];
	NSDate *tomorrow = [cal dateFromComponents:components];
	components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
	NSDate *otherDate = [cal dateFromComponents:components];
    
	return [tomorrow isEqualToDate:otherDate];
}

- (BOOL)cyl_isWeekend {
    NSCalendar *calendar            = [NSCalendar currentCalendar];
    NSRange weekdayRange            = [calendar maximumRangeOfUnit:NSCalendarUnitWeekday];
    NSDateComponents *components    = [calendar components:NSCalendarUnitWeekday
                                                  fromDate:self];
    NSUInteger weekdayOfSomeDate    = [components weekday];
    
    BOOL result = NO;
    
    if (weekdayOfSomeDate == weekdayRange.location || weekdayOfSomeDate == weekdayRange.length)
        result = YES;
    
    return result;
}


/**
 *  Returns whether two dates fall on the same day.
 *
 *  @param date NSDate - Date to compare with sender
 *  @return BOOL - YES if both paramter dates fall on the same day, NO otherwise
 */
- (BOOL)cyl_isSameDay:(NSDate *)date {
    return [NSDate cyl_isSameDay:self asDate:date];
}

/**
 *  Returns whether two dates fall on the same day.
 *
 *  @param date NSDate - First date to compare
 *  @param compareDate NSDate - Second date to compare
 *  @return BOOL - YES if both paramter dates fall on the same day, NO otherwise
 */
+ (BOOL)cyl_isSameDay:(NSDate *)date asDate:(NSDate *)compareDate
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *dateOne = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:compareDate];
    NSDate *dateTwo = [cal dateFromComponents:components];
    
    return [dateOne isEqualToDate:dateTwo];
}

#pragma mark - Date Components With Calendar
/**
 *  Returns the era of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the era (0 for BC, 1 for AD for Gregorian)
 */
- (NSInteger)cyl_eraWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentEra calendar:calendar];
}

/**
 *  Returns the year of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the year as an integer
 */
- (NSInteger)cyl_yearWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentYear calendar:calendar];
}

/**
 *  Returns the month of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the month as an integer
 */
- (NSInteger)cyl_monthWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentMonth calendar:calendar];
}

/**
 *  Returns the day of the month of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the day of the month as an integer
 */
- (NSInteger)cyl_dayWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentDay calendar:calendar];
}

/**
 *  Returns the hour of the day of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the hour of the day as an integer
 */
- (NSInteger)cyl_hourWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentHour calendar:calendar];
}

/**
 *  Returns the minute of the hour of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the minute of the hour as an integer
 */
- (NSInteger)cyl_minuteWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentMinute calendar:calendar];
}

/**
 *  Returns the second of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the second as an integer
 */
- (NSInteger)cyl_secondWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentSecond calendar:calendar];
}

/**
 *  Returns the weekday of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the weekday as an integer
 */
- (NSInteger)cyl_weekdayWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentWeekday calendar:calendar];
}

/**
 *  Returns the weekday ordinal of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the weekday ordinal as an integer
 */
- (NSInteger)cyl_weekdayOrdinalWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentWeekdayOrdinal calendar:calendar];
}

/**
 *  Returns the quarter of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the quarter as an integer
 */
- (NSInteger)cyl_quarterWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentQuarter calendar:calendar];
}

/**
 *  Returns the week of the month of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the week of the month as an integer
 */
- (NSInteger)cyl_weekOfMonthWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentWeekOfMonth calendar:calendar];
}

/**
 *  Returns the week of the year of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the week of the year as an integer
 */
- (NSInteger)cyl_weekOfYearWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentWeekOfYear calendar:calendar];
}

/**
 *  Returns the year for week of the year (???) of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the year for week of the year as an integer
 */
- (NSInteger)cyl_yearForWeekOfYearWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentYearForWeekOfYear calendar:calendar];
}


/**
 *  Returns the day of the year of the receiver from a given calendar
 *
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - represents the day of the year as an integer
 */
- (NSInteger)cyl_dayOfYearWithCalendar:(NSCalendar *)calendar{
    return [self cyl_componentForDate:self type:DTDateComponentDayOfYear calendar:calendar];
}

/**
 *  Takes in a date, calendar and desired date component and returns the desired NSInteger
 *  representation for that component
 *
 *  @param date      NSDate - The date to be be mined for a desired component
 *  @param component DTDateComponent - The desired component (i.e. year, day, week, etc)
 *  @param calendar  NSCalendar - The calendar to be used in the processing (Defaults to Gregorian)
 *
 *  @return NSInteger
 */
- (NSInteger)cyl_componentForDate:(NSDate *)date type:(DTDateComponent)component calendar:(NSCalendar *)calendar{
    if (!calendar) {
        calendar = [[self class] cyl_implicitCalendar];
    }
    
    unsigned int unitFlags = 0;
    
    if (component == DTDateComponentYearForWeekOfYear) {
       unitFlags = NSCalendarUnitYear | NSCalendarUnitQuarter | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitEra | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear;
    }
    else {
        unitFlags = allCalendarUnitFlags;
    }

    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    switch (component) {
        case DTDateComponentEra:
            return [dateComponents era];
        case DTDateComponentYear:
            return [dateComponents year];
        case DTDateComponentMonth:
            return [dateComponents month];
        case DTDateComponentDay:
            return [dateComponents day];
        case DTDateComponentHour:
            return [dateComponents hour];
        case DTDateComponentMinute:
            return [dateComponents minute];
        case DTDateComponentSecond:
            return [dateComponents second];
        case DTDateComponentWeekday:
            return [dateComponents weekday];
        case DTDateComponentWeekdayOrdinal:
            return [dateComponents weekdayOrdinal];
        case DTDateComponentQuarter:
            return [dateComponents quarter];
        case DTDateComponentWeekOfMonth:
            return [dateComponents weekOfMonth];
        case DTDateComponentWeekOfYear:
            return [dateComponents weekOfYear];
        case DTDateComponentYearForWeekOfYear:
            return [dateComponents yearForWeekOfYear];
        case DTDateComponentDayOfYear:
            return [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:date];
        default:
            break;
    }
    
    return 0;
}

#pragma mark - Date Creating
+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
	
	return [self cyl_dateWithYear:year month:month day:day hour:0 minute:0 second:0];
}

+ (NSDate *)cyl_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
	
	NSDate *nsDate = nil;
	NSDateComponents *components = [[NSDateComponents alloc] init];
	
	components.year   = year;
	components.month  = month;
	components.day    = day;
	components.hour   = hour;
	components.minute = minute;
	components.second = second;
	
	nsDate = [[[self class] cyl_implicitCalendar] dateFromComponents:components];
	
	return nsDate;
}

+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString {

	return [self cyl_dateWithString:dateString formatString:formatString timeZone:[NSTimeZone systemTimeZone]];
}

+ (NSDate *)cyl_dateWithString:(NSString *)dateString formatString:(NSString *)formatString timeZone:(NSTimeZone *)timeZone {

	static NSDateFormatter *parser = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    parser = [[NSDateFormatter alloc] init];
	});

	parser.dateStyle = NSDateFormatterNoStyle;
	parser.timeStyle = NSDateFormatterNoStyle;
	parser.timeZone = timeZone;
	parser.dateFormat = formatString;

	return [parser dateFromString:dateString];
}


#pragma mark - Date Editing
#pragma mark Date By Adding
/**
 *  Returns a date representing the receivers date shifted later by the provided number of years.
 *
 *  @param years NSInteger - Number of years to add
 *
 *  @return NSDate - Date modified by the number of desired years
 */
- (NSDate *)cyl_dateByAddingYears:(NSInteger)years{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:years];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of months.
 *
 *  @param years NSInteger - Number of months to add
 *
 *  @return NSDate - Date modified by the number of desired months
 */
- (NSDate *)cyl_dateByAddingMonths:(NSInteger)months{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:months];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of weeks.
 *
 *  @param years NSInteger - Number of weeks to add
 *
 *  @return NSDate - Date modified by the number of desired weeks
 */
- (NSDate *)cyl_dateByAddingWeeks:(NSInteger)weeks{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:weeks];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of days.
 *
 *  @param years NSInteger - Number of days to add
 *
 *  @return NSDate - Date modified by the number of desired days
 */
- (NSDate *)cyl_dateByAddingDays:(NSInteger)days{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:days];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of hours.
 *
 *  @param years NSInteger - Number of hours to add
 *
 *  @return NSDate - Date modified by the number of desired hours
 */
- (NSDate *)cyl_dateByAddingHours:(NSInteger)hours{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:hours];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of minutes.
 *
 *  @param years NSInteger - Number of minutes to add
 *
 *  @return NSDate - Date modified by the number of desired minutes
 */
- (NSDate *)cyl_dateByAddingMinutes:(NSInteger)minutes{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMinute:minutes];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted later by the provided number of seconds.
 *
 *  @param years NSInteger - Number of seconds to add
 *
 *  @return NSDate - Date modified by the number of desired seconds
 */
- (NSDate *)cyl_dateByAddingSeconds:(NSInteger)seconds{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setSecond:seconds];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

#pragma mark Date By Subtracting
/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of years.
 *
 *  @param years NSInteger - Number of years to subtract
 *
 *  @return NSDate - Date modified by the number of desired years
 */
- (NSDate *)cyl_dateBySubtractingYears:(NSInteger)years{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:-1*years];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of months.
 *
 *  @param years NSInteger - Number of months to subtract
 *
 *  @return NSDate - Date modified by the number of desired months
 */
- (NSDate *)cyl_dateBySubtractingMonths:(NSInteger)months{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:-1*months];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of weeks.
 *
 *  @param years NSInteger - Number of weeks to subtract
 *
 *  @return NSDate - Date modified by the number of desired weeks
 */
- (NSDate *)cyl_dateBySubtractingWeeks:(NSInteger)weeks{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setWeekOfYear:-1*weeks];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of days.
 *
 *  @param years NSInteger - Number of days to subtract
 *
 *  @return NSDate - Date modified by the number of desired days
 */
- (NSDate *)cyl_dateBySubtractingDays:(NSInteger)days{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:-1*days];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of hours.
 *
 *  @param years NSInteger - Number of hours to subtract
 *
 *  @return NSDate - Date modified by the number of desired hours
 */
- (NSDate *)cyl_dateBySubtractingHours:(NSInteger)hours{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setHour:-1*hours];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of minutes.
 *
 *  @param years NSInteger - Number of minutes to subtract
 *
 *  @return NSDate - Date modified by the number of desired minutes
 */
- (NSDate *)cyl_dateBySubtractingMinutes:(NSInteger)minutes{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMinute:-1*minutes];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

/**
 *  Returns a date representing the receivers date shifted earlier by the provided number of seconds.
 *
 *  @param years NSInteger - Number of seconds to subtract
 *
 *  @return NSDate - Date modified by the number of desired seconds
 */
- (NSDate *)cyl_dateBySubtractingSeconds:(NSInteger)seconds{
    NSCalendar *calendar = [[self class] cyl_implicitCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setSecond:-1*seconds];
    
    return [calendar dateByAddingComponents:components toDate:self options:0];
}

#pragma mark - Date Comparison
#pragma mark Time From
/**
 *  Returns an NSInteger representing the amount of time in years between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *  Uses the default Gregorian calendar
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return NSInteger - The NSInteger representation of the years between receiver and provided date
 */
- (NSInteger)cyl_yearsFrom:(NSDate *)date {
    return [self cyl_yearsFrom:date calendar:nil];
}

/**
 *  Returns an NSInteger representing the amount of time in months between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *  Uses the default Gregorian calendar
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return NSInteger - The NSInteger representation of the years between receiver and provided date
 */
- (NSInteger)cyl_monthsFrom:(NSDate *)date {
    return [self cyl_monthsFrom:date calendar:nil];
}

/**
 *  Returns an NSInteger representing the amount of time in weeks between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *  Uses the default Gregorian calendar
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return NSInteger - The double representation of the weeks between receiver and provided date
 */
- (NSInteger)cyl_weeksFrom:(NSDate *)date {
    return [self cyl_weeksFrom:date calendar:nil];
}

/**
 *  Returns an NSInteger representing the amount of time in days between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *  Uses the default Gregorian calendar
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return NSInteger - The double representation of the days between receiver and provided date
 */
- (NSInteger)cyl_daysFrom:(NSDate *)date {
    return [self cyl_daysFrom:date calendar:nil];
}

/**
 *  Returns an NSInteger representing the amount of time in hours between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return double - The double representation of the hours between receiver and provided date
 */
- (double)cyl_hoursFrom:(NSDate *)date {
    return ([self timeIntervalSinceDate:date])/SECONDS_IN_HOUR;
}

/**
 *  Returns an NSInteger representing the amount of time in minutes between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return double - The double representation of the minutes between receiver and provided date
 */
- (double)cyl_minutesFrom:(NSDate *)date {
    return ([self timeIntervalSinceDate:date])/SECONDS_IN_MINUTE;
}

/**
 *  Returns an NSInteger representing the amount of time in seconds between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date NSDate - The provided date for comparison
 *
 *  @return double - The double representation of the seconds between receiver and provided date
 */
- (double)cyl_secondsFrom:(NSDate *)date {
    return [self timeIntervalSinceDate:date];
}

#pragma mark Time From With Calendar
/**
 *  Returns an NSInteger representing the amount of time in years between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date     NSDate - The provided date for comparison
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - The double representation of the years between receiver and provided date
 */
- (NSInteger)cyl_yearsFrom:(NSDate *)date calendar:(NSCalendar *)calendar{
    if (!calendar) {
        calendar = [[self class] cyl_implicitCalendar];
    }
    
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    NSInteger multiplier = (earliest == self) ? -1 : 1;
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:earliest toDate:latest options:0];
    return multiplier*components.year;
}

/**
 *  Returns an NSInteger representing the amount of time in months between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date     NSDate - The provided date for comparison
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - The double representation of the months between receiver and provided date
 */
- (NSInteger)cyl_monthsFrom:(NSDate *)date calendar:(NSCalendar *)calendar{
    if (!calendar) {
        calendar = [[self class] cyl_implicitCalendar];
    }
    
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    NSInteger multiplier = (earliest == self) ? -1 : 1;
    NSDateComponents *components = [calendar components:allCalendarUnitFlags fromDate:earliest toDate:latest options:0];
    return multiplier*(components.month + 12*components.year);
}

/**
 *  Returns an NSInteger representing the amount of time in weeks between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date     NSDate - The provided date for comparison
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - The double representation of the weeks between receiver and provided date
 */
- (NSInteger)cyl_weeksFrom:(NSDate *)date calendar:(NSCalendar *)calendar{
    if (!calendar) {
        calendar = [[self class] cyl_implicitCalendar];
    }
    
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    NSInteger multiplier = (earliest == self) ? -1 : 1;
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekOfYear fromDate:earliest toDate:latest options:0];
    return multiplier*components.weekOfYear;
}

/**
 *  Returns an NSInteger representing the amount of time in days between the receiver and the provided date.
 *  If the receiver is earlier than the provided date, the returned value will be negative.
 *
 *  @param date     NSDate - The provided date for comparison
 *  @param calendar NSCalendar - The calendar to be used in the calculation
 *
 *  @return NSInteger - The double representation of the days between receiver and provided date
 */
- (NSInteger)cyl_daysFrom:(NSDate *)date calendar:(NSCalendar *)calendar{
    if (!calendar) {
        calendar = [[self class] cyl_implicitCalendar];
    }
    
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    NSInteger multiplier = (earliest == self) ? -1 : 1;
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:earliest toDate:latest options:0];
    return multiplier*components.day;
}

#pragma mark Time Until
/**
 *  Returns the number of years until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return NSInteger representiation of years
 */
- (NSInteger)cyl_yearsUntil{
    return [self cyl_yearsLaterThan:[NSDate date]];
}

/**
 *  Returns the number of months until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return NSInteger representiation of months
 */
- (NSInteger)cyl_monthsUntil{
    return [self cyl_monthsLaterThan:[NSDate date]];
}

/**
 *  Returns the number of weeks until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return NSInteger representiation of weeks
 */
- (NSInteger)cyl_weeksUntil{
    return [self cyl_weeksLaterThan:[NSDate date]];
}

/**
 *  Returns the number of days until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return NSInteger representiation of days
 */
- (NSInteger)cyl_daysUntil{
    return [self cyl_daysLaterThan:[NSDate date]];
}

/**
 *  Returns the number of hours until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return double representiation of hours
 */
- (double)cyl_hoursUntil{
    return [self cyl_hoursLaterThan:[NSDate date]];
}

/**
 *  Returns the number of minutes until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return double representiation of minutes
 */
- (double)cyl_minutesUntil{
    return [self cyl_minutesLaterThan:[NSDate date]];
}

/**
 *  Returns the number of seconds until the receiver's date. Returns 0 if the receiver is the same or earlier than now.
 *
 *  @return double representiation of seconds
 */
- (double)cyl_secondsUntil{
    return [self cyl_secondsLaterThan:[NSDate date]];
}

#pragma mark Time Ago
/**
 *  Returns the number of years the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return NSInteger representiation of years
 */
- (NSInteger)cyl_yearsAgo{
    return [self cyl_yearsEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of months the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return NSInteger representiation of months
 */
- (NSInteger)cyl_monthsAgo{
    return [self cyl_monthsEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of weeks the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return NSInteger representiation of weeks
 */
- (NSInteger)cyl_weeksAgo{
    return [self cyl_weeksEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of days the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return NSInteger representiation of days
 */
- (NSInteger)cyl_daysAgo{
    return [self cyl_daysEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of hours the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return double representiation of hours
 */
- (double)cyl_hoursAgo{
    return [self cyl_hoursEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of minutes the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return double representiation of minutes
 */
- (double)cyl_minutesAgo{
    return [self cyl_minutesEarlierThan:[NSDate date]];
}

/**
 *  Returns the number of seconds the receiver's date is earlier than now. Returns 0 if the receiver is the same or later than now.
 *
 *  @return double representiation of seconds
 */
- (double)cyl_secondsAgo{
    return [self cyl_secondsEarlierThan:[NSDate date]];
}

#pragma mark Earlier Than
/**
 *  Returns the number of years the receiver's date is earlier than the provided comparison date. 
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of years
 */
- (NSInteger)cyl_yearsEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_yearsFrom:date], 0));
}

/**
 *  Returns the number of months the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of months
 */
- (NSInteger)cyl_monthsEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_monthsFrom:date], 0));
}

/**
 *  Returns the number of weeks the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of weeks
 */
- (NSInteger)cyl_weeksEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_weeksFrom:date], 0));
}

/**
 *  Returns the number of days the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of days
 */
- (NSInteger)cyl_daysEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_daysFrom:date], 0));
}

/**
 *  Returns the number of hours the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of hours
 */
- (double)cyl_hoursEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_hoursFrom:date], 0));
}

/**
 *  Returns the number of minutes the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of minutes
 */
- (double)cyl_minutesEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_minutesFrom:date], 0));
}

/**
 *  Returns the number of seconds the receiver's date is earlier than the provided comparison date.
 *  Returns 0 if the receiver's date is later than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of seconds
 */
- (double)cyl_secondsEarlierThan:(NSDate *)date {
    return ABS(MIN([self cyl_secondsFrom:date], 0));
}

#pragma mark Later Than
/**
 *  Returns the number of years the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of years
 */
- (NSInteger)cyl_yearsLaterThan:(NSDate *)date {
    return MAX([self cyl_yearsFrom:date], 0);
}

/**
 *  Returns the number of months the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of months
 */
- (NSInteger)cyl_monthsLaterThan:(NSDate *)date {
    return MAX([self cyl_monthsFrom:date], 0);
}

/**
 *  Returns the number of weeks the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of weeks
 */
- (NSInteger)cyl_weeksLaterThan:(NSDate *)date {
    return MAX([self cyl_weeksFrom:date], 0);
}

/**
 *  Returns the number of days the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return NSInteger representing the number of days
 */
- (NSInteger)cyl_daysLaterThan:(NSDate *)date {
    return MAX([self cyl_daysFrom:date], 0);
}

/**
 *  Returns the number of hours the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of hours
 */
- (double)cyl_hoursLaterThan:(NSDate *)date {
    return MAX([self cyl_hoursFrom:date], 0);
}

/**
 *  Returns the number of minutes the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of minutes
 */
- (double)cyl_minutesLaterThan:(NSDate *)date {
    return MAX([self cyl_minutesFrom:date], 0);
}

/**
 *  Returns the number of seconds the receiver's date is later than the provided comparison date.
 *  Returns 0 if the receiver's date is earlier than or equal to the provided comparison date.
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return double representing the number of seconds
 */
- (double)cyl_secondsLaterThan:(NSDate *)date {
    return MAX([self cyl_secondsFrom:date], 0);
}


#pragma mark Comparators
/**
 *  Returns a YES if receiver is earlier than provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
- (BOOL)cyl_isEarlierThan:(NSDate *)date {
    if (self.timeIntervalSince1970 < date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a YES if receiver is later than provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
- (BOOL)cyl_isLaterThan:(NSDate *)date {
    if (self.timeIntervalSince1970 > date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a YES if receiver is earlier than or equal to the provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
- (BOOL)cyl_isEarlierThanOrEqualTo:(NSDate *)date {
    if (self.timeIntervalSince1970 <= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

/**
 *  Returns a YES if receiver is later than or equal to provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
- (BOOL)cyl_isLaterThanOrEqualTo:(NSDate *)date {
    if (self.timeIntervalSince1970 >= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

#pragma mark - Formatted Dates
#pragma mark Formatted With Style
/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given style
 *
 *  @param style NSDateFormatterStyle - Desired date formatting style
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style {
    return [self cyl_formattedDateWithStyle:style timeZone:[NSTimeZone systemTimeZone] locale:[NSLocale autoupdatingCurrentLocale]];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given style and time zone
 *
 *  @param style    NSDateFormatterStyle - Desired date formatting style
 *  @param timeZone NSTimeZone - Desired time zone
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone {
    return [self cyl_formattedDateWithStyle:style timeZone:timeZone locale:[NSLocale autoupdatingCurrentLocale]];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given style and locale
 *
 *  @param style  NSDateFormatterStyle - Desired date formatting style
 *  @param locale NSLocale - Desired locale
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style locale:(NSLocale *)locale {
    return [self cyl_formattedDateWithStyle:style timeZone:[NSTimeZone systemTimeZone] locale:locale];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given style, time zone and locale
 *
 *  @param style    NSDateFormatterStyle - Desired date formatting style
 *  @param timeZone NSTimeZone - Desired time zone
 *  @param locale   NSLocale - Desired locale
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithStyle:(NSDateFormatterStyle)style timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });

    [formatter setDateStyle:style];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

#pragma mark Formatted With Format
/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given date format
 *
 *  @param format NSString - String representing the desired date format
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithFormat:(NSString *)format{
    return [self cyl_formattedDateWithFormat:format timeZone:[NSTimeZone systemTimeZone] locale:[NSLocale autoupdatingCurrentLocale]];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given date format and time zone
 *
 *  @param format   NSString - String representing the desired date format
 *  @param timeZone NSTimeZone - Desired time zone
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone {
    return [self cyl_formattedDateWithFormat:format timeZone:timeZone locale:[NSLocale autoupdatingCurrentLocale]];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given date format and locale
 *
 *  @param format NSString - String representing the desired date format
 *  @param locale NSLocale - Desired locale
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithFormat:(NSString *)format locale:(NSLocale *)locale {
    return [self cyl_formattedDateWithFormat:format timeZone:[NSTimeZone systemTimeZone] locale:locale];
}

/**
 *  Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone and locale
 *
 *  @param format   NSString - String representing the desired date format
 *  @param timeZone NSTimeZone - Desired time zone
 *  @param locale   NSLocale - Desired locale
 *
 *  @return NSString representing the formatted date string
 */
- (NSString *)cyl_formattedDateWithFormat:(NSString *)format timeZone:(NSTimeZone *)timeZone locale:(NSLocale *)locale {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });

    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone];
    [formatter setLocale:locale];
    return [formatter stringFromDate:self];
}

#pragma mark - Helpers
/**
 *  Class method that returns whether the given year is a leap year for the Gregorian Calendar
 *  Returns YES if year is a leap year, otherwise returns NO
 *
 *  @param year NSInteger - Year to evaluate
 *
 *  @return BOOL evaluation of year
 */
+ (BOOL)cyl_isLeapYear:(NSInteger)year{
    if (year%400){
        return YES;
    }
    else if (year%100){
        return NO;
    }
    else if (year%4){
        return YES;
    }
    
    return NO;
}

/**
 *  Retrieves the default calendar identifier used for all non-calendar-specified operations
 *
 *  @return NSString - NSCalendarIdentifier
 */
+ (NSString *)cyl_defaultCalendarIdentifier {
    return defaultCalendarIdentifier;
}

/**
 *  Sets the default calendar identifier used for all non-calendar-specified operations
 *
 *  @param identifier NSString - NSCalendarIdentifier
 */
+ (void)cyl_setDefaultCalendarIdentifier:(NSString *)identifier {
    defaultCalendarIdentifier = [identifier copy];
    implicitCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:defaultCalendarIdentifier ?: NSCalendarIdentifierGregorian];
}

/**
 *  Retrieves a default NSCalendar instance, based on the value of defaultCalendarSetting
 *
 *  @return NSCalendar The current implicit calendar
 */
+ (NSCalendar *)cyl_implicitCalendar {
    return implicitCalendar;
}

@end
