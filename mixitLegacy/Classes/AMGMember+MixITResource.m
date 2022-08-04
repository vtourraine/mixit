//
//  AMGMember+MixITResource.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2018 Studio AMANgA. All rights reserved.
//

#import "AMGMember+MixITResource.h"

#import "AMGMixITSyncManager.h"
#import "AMGMixITClient.h"
#import "NSObject+AMGParsing.h"

@implementation AMGMember (MixITResource)

- (BOOL)updateWithAttributes:(nonnull NSDictionary *)attributes {
    self.identifier = [attributes valueForKey:@"legacyId" ifKindOf:NSString.class];
    self.company = [attributes valueForKey:@"company" ifKindOf:NSString.class];
    self.firstName = [attributes valueForKey:@"firstname" ifKindOf:NSString.class];
    self.lastName = [attributes valueForKey:@"lastname" ifKindOf:NSString.class];
    self.login = [attributes valueForKey:@"login" ifKindOf:NSString.class];
    self.longDesc = [attributes valueForKey:@"description" ifKindOf:NSString.class];
    self.photoURLString = [attributes valueForKey:@"photoUrl" ifKindOf:NSString.class];
    if ([self.photoURLString hasPrefix:@"/images"]) {
        self.photoURLString = [@"https://mixitconf.org" stringByAppendingString:self.photoURLString];
    }

    if (self.identifier == nil) {
        self.identifier = self.login;
    }

    return YES;
}

+ (nullable NSURLSessionDataTask *)fetchUsersWithClient:(nonnull AMGMixITClient *)client
                                                  block:(nullable void (^)(NSArray * __nonnull speakers, NSError * __nullable error))block {
    return [client GET:@"user/" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * __unused task, id JSON) {
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
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:AMGMember.entityName];
    NSArray *existingMembers = [context executeFetchRequest:request error:nil];

    for (NSDictionary *object in objects) {
        if (![object isKindOfClass:NSDictionary.class]) {
            continue;
        }

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"login == %@", object[@"login"]];
        AMGMember *speaker = [existingMembers filteredArrayUsingPredicate:predicate].lastObject;

        if (!speaker) {
            speaker = (AMGMember *)[NSEntityDescription insertNewObjectForEntityForName:AMGMember.entityName inManagedObjectContext:context];
        }

        [speaker updateWithAttributes:object];
    }
}

@end
