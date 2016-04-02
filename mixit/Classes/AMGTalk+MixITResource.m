//
//  AMGTalk+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGTalk+MixITResource.h"

#import "AMGMixITClient.h"
#import "NSObject+AMGParsing.h"

#import <ISO8601DateFormatter.h>

@implementation AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(NSDictionary *)attributes {
    self.desc       = [attributes valueForKey:@"description" ifKindOf:NSString.class];
    self.format     = [attributes valueForKey:@"format"      ifKindOf:NSString.class];
    self.ideaForNow = [attributes valueForKey:@"ideaForNow"  ifKindOf:NSString.class];
    self.language   = [attributes valueForKey:@"lang"        ifKindOf:NSString.class];
    self.room       = [attributes valueForKey:@"room"        ifKindOf:NSString.class];
    self.summary    = [attributes valueForKey:@"summary"     ifKindOf:NSString.class];
    self.title      = [attributes valueForKey:@"title"       ifKindOf:NSString.class];

    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    self.startDate = [dateFormatter dateFromString:[attributes valueForKey:@"start" ifKindOf:NSString.class]];
    self.endDate   = [dateFormatter dateFromString:[attributes valueForKey:@"end"   ifKindOf:NSString.class]];

    NSString *yearString = [attributes valueForKey:@"year" ifKindOf:NSString.class];
    NSInteger yearInteger = [yearString integerValue];
    if (yearInteger > 0) {
        self.year = @(yearInteger);
    }

    NSArray <NSDictionary *> *links = attributes[@"links"];
    NSMutableArray *identifiers = [NSMutableArray array];
    for (NSDictionary *link in links) {
        NSString *rel = link[@"rel"];
        NSString *href = link[@"href"];

        if ([rel isEqualToString:@"speaker"]) {
            NSString *identifier = [href lastPathComponent];
            if (identifier) {
                [identifiers addObject:identifier];
            }
        }
    }

    [self setSpeakersIdentifiersFromArray:identifiers];

    return YES;
}

+ (NSURLSessionDataTask *)fetchTalksWithClient:(AMGMixITClient *)client
                                         block:(void (^)(NSArray *posts, NSError *error))block {
    // parameters:@{@"details": @"true"}
    return [client GET:@"session" parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
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

        NSString    *identifier = [NSString stringWithFormat:@"%@", object[@"idSession"]];
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
