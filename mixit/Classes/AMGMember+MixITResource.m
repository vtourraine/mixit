//
//  AMGMember+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGMember+MixITResource.h"

#import "AMGMixITSyncManager.h"
#import "AMGMixITClient.h"

@implementation AMGMember (MixITResource)

- (BOOL)updateWithAttributes:(NSDictionary *)attributes {
    self.company        = attributes[@"company"];
    self.firstName      = attributes[@"firstName"];
    self.lastName       = attributes[@"lastName"];
    self.login          = attributes[@"login"];
    self.longDesc       = attributes[@"longdesc"];
    self.shortDesc      = attributes[@"shortdesc"];
    self.imageURLString = attributes[@"urlimage"];

    return YES;
}

+ (NSURLSessionDataTask *)fetchSpeakersWithClient:(AMGMixITClient *)client
                                            block:(void (^)(NSArray *speakers, NSError *error))block {
    NSString *path = @"members/speakers";

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

+ (void)mergeResponseObjects:(NSArray *)objects
                 intoContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request         = [NSFetchRequest fetchRequestWithEntityName:AMGMember.entityName];
    NSArray        *existingMembers = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString    *identifier = [NSString stringWithFormat:@"%@", object[@"id"]];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
        AMGMember   *speaker    = [existingMembers filteredArrayUsingPredicate:predicate].lastObject;

        if (!speaker) {
            speaker = (AMGMember *)[NSEntityDescription insertNewObjectForEntityForName:AMGMember.entityName
                                                                 inManagedObjectContext:context];
            speaker.identifier = identifier;
        }

        [speaker updateWithAttributes:object];
    }
}

@end
