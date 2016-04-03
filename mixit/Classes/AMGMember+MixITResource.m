//
//  AMGMember+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGMember+MixITResource.h"

#import "AMGMixITSyncManager.h"
#import "AMGMixITClient.h"
#import "NSObject+AMGParsing.h"

@implementation AMGMember (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes {
    self.company        = [attributes valueForKey:@"company"   ifKindOf:NSString.class];
    self.firstName      = [attributes valueForKey:@"firstname" ifKindOf:NSString.class];
    self.lastName       = [attributes valueForKey:@"lastname"  ifKindOf:NSString.class];
    self.login          = [attributes valueForKey:@"login"     ifKindOf:NSString.class];
    self.longDesc       = [attributes valueForKey:@"longDescription"  ifKindOf:NSString.class];
    self.shortDesc      = [attributes valueForKey:@"shortDescription" ifKindOf:NSString.class];

    return YES;
}

+ (nullable NSURLSessionDataTask *)fetchSpeakersWithClient:(nonnull AMGMixITClient *)client
                                                   forYear:(nullable NSNumber *)year
                                                     block:(nullable void (^)(NSArray * __nonnull speakers, NSError * __nullable error))block {
    NSDictionary *parameters = nil;
    if (year) {
        parameters = @{@"year": year};
    }

    return [client GET:@"member/speaker" parameters:parameters success:^(NSURLSessionDataTask * __unused task, id JSON) {
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
    NSFetchRequest *request         = [NSFetchRequest fetchRequestWithEntityName:AMGMember.entityName];
    NSArray        *existingMembers = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSString    *identifier = [NSString stringWithFormat:@"%@", object[@"idMember"]];
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
