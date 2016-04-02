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

- (BOOL)updateWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)fetchSpeakersWithClient:(AMGMixITClient *)client
                                            block:(void (^)(NSArray *speakers, NSError *error))block;

+ (void)mergeResponseObjects:(NSArray *)objects
                 intoContext:(NSManagedObjectContext *)context;

@end
