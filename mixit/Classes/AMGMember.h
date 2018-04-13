//
//  AMGMember.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2018 Studio AMANgA. All rights reserved.
//

@import Foundation;
@import CoreData;


@interface AMGMember : NSManagedObject

@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *longDesc;
@property (nonatomic, strong) NSString *shortDesc;
@property (nonatomic, strong) NSString *photoURLString;

+ (NSString *)entityName;

@end
