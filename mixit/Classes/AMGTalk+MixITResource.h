//
//  AMGTalk+MixITResource.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGTalk.h"

@class NSURLSessionDataTask;
@class AMGMixITClient;


@interface AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes;

+ (nullable NSURLSessionDataTask *)fetchTalksWithClient:(nonnull AMGMixITClient *)client
                                                forYear:(nullable NSNumber *)year
                                                  block:(nullable void (^)(NSArray * __nonnull talks, NSError * __nullable error))block;

+ (void)mergeResponseObjects:(nonnull NSArray *)objects
                 intoContext:(nonnull NSManagedObjectContext *)context;

@end
