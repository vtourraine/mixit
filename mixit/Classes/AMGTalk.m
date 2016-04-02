//
//  AMGTalk.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

#import "AMGTalk.h"

#import "AMGMember.h"

static NSString * const AMGTalkSeparator = @";";

@implementation AMGTalk

@dynamic title;
@dynamic summary;
@dynamic startDate;
@dynamic room;
@dynamic level;
@dynamic language;
@dynamic identifier;
@dynamic endDate;
@dynamic favorited;
@dynamic format;
@dynamic desc;
@dynamic speakersIdentifiers;

+ (NSString *)entityName {
    return @"Talk";
}

- (BOOL)isFavorited {
    return self.favorited.boolValue;
}

- (NSString *)emojiForLanguage {
    if ([self.language isEqualToString:@"fr"]) {
        return @"🇫🇷";
    }
    else if ([self.language isEqualToString:@"en"]) {
        return @"🇺🇸";
    }
    else {
        return nil;
    }
}

- (void)setSpeakersIdentifiersFromArray:(NSArray *)identifiers {
    self.speakersIdentifiers = [identifiers componentsJoinedByString:AMGTalkSeparator];
}

- (NSArray <NSString *> *)speakersIdentifiersArray {
    return [self.speakersIdentifiers componentsSeparatedByString:AMGTalkSeparator];
}

- (NSArray <AMGMember *> *)fetchSpeakers {
    NSArray *identifiers = self.speakersIdentifiersArray;
    NSMutableArray *speakers = [NSMutableArray arrayWithCapacity:identifiers.count];

    for (NSString *identifier in identifiers) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:AMGMember.entityName];
        request.predicate = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
        AMGMember *member = [self.managedObjectContext executeFetchRequest:request error:nil].lastObject;

        if (member) {
            [speakers addObject:member];
        }
    }

    return speakers;
}

@end
