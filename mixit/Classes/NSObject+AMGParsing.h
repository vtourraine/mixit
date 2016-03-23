//
//  NSObject+AMGParsing.h
//  mixit
//
//  Created by Vincent Tourraine on 23/03/16.
//  Copyright © 2016 Studio AMANgA. All rights reserved.
//

@import Foundation;

@interface NSDictionary (AMGParsing)

- (nullable id)valueForKey:(nonnull NSString *)key
                  ifKindOf:(nonnull Class)aClass;

@end
