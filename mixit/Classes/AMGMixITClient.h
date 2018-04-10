//
//  AMGMixITClient.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2018 Studio AMANgA. All rights reserved.
//

#import "AFHTTPSessionManager.h"


@interface AMGMixITClient : AFHTTPSessionManager

+ (nonnull NSArray <NSNumber *> *)pastYears;
+ (nonnull NSNumber *)currentYear;

+ (nonnull instancetype)MixITClient;

@end
