//
//  AMGTalk+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2021 Studio AMANgA. All rights reserved.
//

#import "AMGTalk+MixITResource.h"

#import "AMGMixITClient.h"
#import "NSObject+AMGParsing.h"

#import <ISO8601DateFormatter.h>

@implementation AMGTalk (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes {
    self.desc = [attributes valueForKey:@"description" ifKindOf:NSString.class];
    self.format = [attributes valueForKey:@"format" ifKindOf:NSString.class];
    self.language = [attributes valueForKey:@"language" ifKindOf:NSString.class];
    self.room = [attributes valueForKey:@"room" ifKindOf:NSString.class];
    self.summary = [attributes valueForKey:@"summary" ifKindOf:NSString.class];
    self.title = [attributes valueForKey:@"title" ifKindOf:NSString.class];
    self.startDate = [AMGTalk dateFromString:[attributes valueForKey:@"start" ifKindOf:NSString.class]];
    self.endDate = [AMGTalk dateFromString:[attributes valueForKey:@"end" ifKindOf:NSString.class]];
    self.year = @([[attributes valueForKey:@"event" ifKindOf:NSString.class] integerValue]);

    NSArray *speakersIds =[attributes valueForKey:@"speakerIds" ifKindOf:NSArray.class];
    [self setSpeakersIdentifiersFromArray:speakersIds];

    return YES;
}

+ (nullable NSURLSessionDataTask *)fetchTalksWithClient:(nonnull AMGMixITClient *)client forYear:(nonnull NSNumber *)year block:(nullable void (^)(NSArray * __nonnull talks, NSError * __nullable error))block {
    NSString *path = [NSString stringWithFormat:@"%@/talk", year];

    return [client GET:path parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
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

+ (void)mergeResponseObjects:(nonnull NSArray *)objects intoContext:(nonnull NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:AMGTalk.entityName];
    NSArray *existingTalks = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString *identifier = [NSString stringWithFormat:@"%@", object[@"id"]];
        NSUInteger index = [existingTalks indexOfObjectPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            return [[obj identifier] isEqualToString:identifier];
        }];

        AMGTalk *talk = nil;

        if (index == NSNotFound) {
            talk = (AMGTalk *)[NSEntityDescription insertNewObjectForEntityForName:AMGTalk.entityName inManagedObjectContext:context];
            talk.identifier = identifier;
        }
        else {
            talk = existingTalks[index];
        }

        [talk updateWithAttributes:object];
    }
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    ISO8601DateFormatter *dateFormatter = [[ISO8601DateFormatter alloc] init];
    return [dateFormatter dateFromString:dateString];
}

@end
