//
//  mixitTests.m
//  mixitTests
//
//  Created by Vincent Tourraine on 30/04/14.
//  Copyright (c) 2014-2022 Studio AMANgA. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AMGTalk+MixITResource.h"

@interface mixitTests : XCTestCase

@end

@implementation mixitTests

- (void)testDateParsing {
    NSDate *date = [AMGTalk dateFromString:@"2022-05-24T09:30:00"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    XCTAssertEqual(components.year, 2022);
    XCTAssertEqual(components.hour, 9);
    XCTAssertEqual(components.minute, 30);
    XCTAssertEqual(components.second, 0);
}

@end
