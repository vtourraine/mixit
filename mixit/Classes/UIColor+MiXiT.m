//
//  UIColor+MiXiT.m
//  mixit
//
//  Created by Vincent Tourraine on 23/02/2017.
//  Copyright © 2017-2019 Studio AMANgA. All rights reserved.
//

#import "UIColor+MiXiT.h"

@implementation UIColor (MiXiT)

+ (instancetype)mixitPurple {
    return [UIColor colorWithRed:44./255 green:36./255 blue:60./255 alpha:1];
}

+ (instancetype)mixitOrange {
    return [UIColor colorWithRed:253./255 green:141./255 blue:85./255 alpha:1];
}

+ (instancetype)mixitLabelColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor labelColor];
    }
    else {
        return [UIColor blackColor];
    }
}

+ (instancetype)mixitSecondaryLabelColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor secondaryLabelColor];
    }
    else {
        return [UIColor darkGrayColor];
    }
}

+ (instancetype)mixitDisabledLabelColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor tertiaryLabelColor];
    }
    else {
        return [UIColor lightGrayColor];
    }
}

+ (instancetype)mixitBackgroundColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor systemBackgroundColor];
    }
    else {
        return [UIColor whiteColor];
    }
}

+ (instancetype)mixitActionColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            return (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor mixitOrange] : [UIColor mixitPurple];
        }];
    }
    else {
        return [UIColor mixitPurple];
    }
}

@end
