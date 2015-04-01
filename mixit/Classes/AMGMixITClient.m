//
//  AMGMixITClient.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGMixITClient.h"

static NSString * const AMGMixITAPIBaseURLString = @"http://www.mix-it.fr/api/";

@implementation AMGMixITClient

+ (instancetype)MixITClient {
    NSURL          *baseURL = [NSURL URLWithString:AMGMixITAPIBaseURLString];
    AMGMixITClient *client  = [[AMGMixITClient alloc] initWithBaseURL:baseURL];

    return client;
}

@end
