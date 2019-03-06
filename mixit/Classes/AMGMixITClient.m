//
//  AMGMixITClient.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2019 Studio AMANgA. All rights reserved.
//

#import "AMGMixITClient.h"

static NSString * const AMGMixITAPIBaseURLString = @"https://mixitconf.org/api/";


@implementation AMGMixITClient

+ (nonnull NSArray <NSNumber *> *)pastYears {
    return @[@2012, @2013, @2014, @2015, @2016, @2017, @2018];
}

+ (nonnull NSNumber *)currentYear {
    return @2019;
}

+ (instancetype)MixITClient {
    NSURL *baseURL = [NSURL URLWithString:AMGMixITAPIBaseURLString];
    AMGMixITClient *client = [[AMGMixITClient alloc] initWithBaseURL:baseURL];

    return client;
}

@end
