//
//  UIViewController+AMGTwitterManager.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "UIViewController+AMGTwitterManager.h"

@import Social;

static NSString * const AMGMixITHashtag = @"#mixit16";

@implementation UIViewController (AMGTwitterManager)

- (BOOL)canTweet {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)presentTweetComposer {
    SLComposeViewController *viewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [viewController setInitialText:AMGMixITHashtag];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
