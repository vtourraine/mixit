//
//  AMGMember+MixITResource.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGMember.h"

@class AMGMixITClient;

@interface AMGMember (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes;

+ (nullable NSURLSessionDataTask *)fetchSpeakersWithClient:(nonnull AMGMixITClient *)client
                                                   forYear:(nullable NSNumber *)year
                                                     block:(nullable void (^)(NSArray * __nonnull speakers, NSError * __nullable error))block;

+ (void)mergeResponseObjects:(nonnull NSArray *)objects
                 intoContext:(nonnull NSManagedObjectContext *)context;

@end
