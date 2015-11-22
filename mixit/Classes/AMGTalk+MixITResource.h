//
//  AMGTalk+MixITResource.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGTalk.h"

@class NSURLSessionDataTask;
@class MixITClient;

@interface AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(NSDictionary *)attributes;

+ (NSURLSessionDataTask *)fetchTalksWithClient:(MixITClient *)client
                                         block:(void (^)(NSArray *talks, NSError *error))block;

+ (void)mergeResponseObjects:(NSArray *)objects
                 intoContext:(NSManagedObjectContext *)context;

@end
