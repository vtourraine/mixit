//
//  AMGMixITClient.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGMixITClient.h"

static NSString * const AMGMixITAPIBaseURLString = @"https://www.mix-it.fr/api/";


@implementation AMGMixITClient

+ (nonnull NSArray <NSNumber *> *)pastYears {
    return @[@2012, @2013, @2014, @2015];
}

+ (nonnull NSNumber *)currentYear {
    return @2016;
}

+ (instancetype)MixITClient {
    NSURL          *baseURL = [NSURL URLWithString:AMGMixITAPIBaseURLString];
    AMGMixITClient *client  = [[AMGMixITClient alloc] initWithBaseURL:baseURL];

    return client;
}

@end
