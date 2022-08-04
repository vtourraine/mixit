//
//  NSObject+AMGParsing.m
//  mixit
//
//  Created by Vincent Tourraine on 23/03/16.
//  Copyright © 2016 Studio AMANgA. All rights reserved.
//

#import "NSObject+AMGParsing.h"

@implementation NSDictionary (AMGParsing)

- (nullable id)valueForKey:(nonnull NSString *)key ifKindOf:(nonnull Class)aClass {
    id value = self[key];
    if ([value isKindOfClass:aClass]) {
        return value;
    }

    return nil;
}

@end
