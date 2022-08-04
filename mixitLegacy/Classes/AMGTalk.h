//
//  AMGTalk.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import Foundation;
@import CoreData;

@class AMGMember;


@interface AMGTalk : NSManagedObject

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSDate   *endDate;
@property (nonatomic, strong) NSNumber *favorited;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSString *ideaForNow;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *level;
@property (nonatomic, strong) NSString *room;
@property (nonatomic, strong) NSString *speakersIdentifiers;
@property (nonatomic, strong) NSDate   *startDate;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *year;

+ (NSString *)entityName;

- (BOOL)isFavorited;

- (NSString *)emojiForLanguage;
- (NSArray <NSString *> *)speakersIdentifiersArray;
- (void)setSpeakersIdentifiersFromArray:(NSArray *)identifiers;

- (NSArray <AMGMember *> *)fetchSpeakers;

@end
