//
//  AMGTalk+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGTalk+MixITResource.h"

#import "AMGMixITClient.h"
#import <ISO8601DateFormatter.h>

@implementation AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(NSDictionary *)attributes {
    self.desc     = attributes[@"talk"][@"description"];
    self.format   = attributes[@"talk"][@"format"];
    self.language = attributes[@"talk"][@"language"];
    self.level    = attributes[@"talk"][@"level"];
    self.room     = attributes[@"talk"][@"room"];
    self.summary  = attributes[@"talk"][@"summary"];
    self.title    = attributes[@"talk"][@"title"];

    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    self.startDate = [dateFormatter dateFromString:attributes[@"talk"][@"start"]];
    self.endDate   = [dateFormatter dateFromString:attributes[@"talk"][@"end"]];

    NSArray *identifiersNumbers = attributes[@"talk"][@"speakers"];
    NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:identifiersNumbers.count];
    for (NSNumber *number in identifiersNumbers) {
        [identifiers addObject:[NSString stringWithFormat:@"%@", number]];
    }
    [self setSpeakersIdentifiersFromArray:identifiers];

    return YES;
}

+ (NSURLSessionDataTask *)fetchTalksWithClient:(AMGMixITClient *)client
                                         block:(void (^)(NSArray *posts, NSError *error))block {
    return [client GET:@"talks" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
        if (![JSON isKindOfClass:NSArray.class]) {
            if (block) {
                block(@[], nil);
            }
            return;
        }

        if (block) {
            block(JSON, nil);
        }
    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
        if (block) {
            block(@[], error);
        }
    }];
}

+ (void)mergeResponseObjects:(NSArray *)objects
                 intoContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request       = [NSFetchRequest fetchRequestWithEntityName:AMGTalk.entityName];
    NSArray        *existingTalks = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString    *identifier = [NSString stringWithFormat:@"%@", object[@"id"]];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
        AMGTalk     *talk       = [existingTalks filteredArrayUsingPredicate:predicate].lastObject;

        if (!talk) {
            talk = (AMGTalk *)[NSEntityDescription insertNewObjectForEntityForName:AMGTalk.entityName
                                                            inManagedObjectContext:context];
            talk.identifier = identifier;
        }

        [talk updateWithAttributes:object];
    }
}

@end
