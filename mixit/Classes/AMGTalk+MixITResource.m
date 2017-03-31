//
//  AMGTalk+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

#import "AMGTalk+MixITResource.h"

#import "AMGMixITClient.h"
#import "NSObject+AMGParsing.h"

#import <ISO8601DateFormatter.h>

@implementation AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes {
    self.desc = [attributes valueForKey:@"description" ifKindOf:NSString.class];
    self.format = [attributes valueForKey:@"format" ifKindOf:NSString.class];
    // self.ideaForNow = [attributes valueForKey:@"ideaForNow" ifKindOf:NSString.class];
    self.language = [attributes valueForKey:@"language" ifKindOf:NSString.class];
    self.room = [attributes valueForKey:@"room" ifKindOf:NSString.class];
    self.summary = [attributes valueForKey:@"summary" ifKindOf:NSString.class];
    self.title = [attributes valueForKey:@"title" ifKindOf:NSString.class];

    NSArray *startComponents = [attributes valueForKey:@"start" ifKindOf:NSArray.class];
    self.startDate = [AMGTalk dateFromRawComponents:startComponents];
    self.endDate = [AMGTalk dateFromRawComponents:[attributes valueForKey:@"end" ifKindOf:NSArray.class]];
    self.year = startComponents.firstObject;

//    NSArray <NSDictionary *> *links = attributes[@"links"];
//    NSMutableArray *identifiers = [NSMutableArray array];
//    for (NSDictionary *link in links) {
//        NSString *rel = link[@"rel"];
//        NSString *href = link[@"href"];
//
//        if ([rel isEqualToString:@"speaker"]) {
//            NSString *identifier = [href lastPathComponent];
//            if (identifier) {
//                [identifiers addObject:identifier];
//            }
//        }
//    }

    NSArray *speakersIds =[attributes valueForKey:@"speakerIds" ifKindOf:NSArray.class];
    [self setSpeakersIdentifiersFromArray:speakersIds];

    if ([self.title containsString:@"Gonette"]) {
        NSLog(@"%@", attributes);
    }

    return YES;
}

+ (nullable NSURLSessionDataTask *)fetchTalksWithClient:(nonnull AMGMixITClient *)client
                                                forYear:(nonnull NSNumber *)year
                                                  block:(nullable void (^)(NSArray * __nonnull talks, NSError * __nullable error))block {
    NSString *path = [NSString stringWithFormat:@"%@/talk", year];

    return [client GET:path parameters:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
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

+ (void)mergeResponseObjects:(nonnull NSArray *)objects
                 intoContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:AMGTalk.entityName];
    NSArray *existingTalks = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *identifier = [NSString stringWithFormat:@"%@", object[@"id"]];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
        AMGTalk *talk = [existingTalks filteredArrayUsingPredicate:predicate].lastObject;

        if (!talk) {
            talk = (AMGTalk *)[NSEntityDescription insertNewObjectForEntityForName:AMGTalk.entityName inManagedObjectContext:context];
            talk.identifier = identifier;
        }

        [talk updateWithAttributes:object];
    }
}

+ (NSDate *)dateFromRawComponents:(NSArray <NSNumber *> *)rawComponents {
    if (rawComponents.count < 5) {
        return nil;
    }

    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = [rawComponents[0] integerValue];
    components.month = [rawComponents[1] integerValue];
    components.day = [rawComponents[2] integerValue];
    components.hour = [rawComponents[3] integerValue];
    components.minute = [rawComponents[4] integerValue];

    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    return [calendar dateFromComponents:components];
}

@end
