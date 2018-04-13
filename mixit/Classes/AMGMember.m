//
//  AMGMember.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2018 Studio AMANgA. All rights reserved.
//

#import "AMGMember.h"


@implementation AMGMember

@dynamic company;
@dynamic firstName;
@dynamic identifier;
@dynamic lastName;
@dynamic login;
@dynamic longDesc;
@dynamic shortDesc;
@dynamic photoURLString;

+ (NSString *)entityName {
    return @"Member";
}

@end
