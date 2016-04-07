//
//  AMGTalkViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGTalk;
@protocol AMGTalkViewDelegate;


@interface AMGTalkViewController : UIViewController

@property (nonatomic, strong, readonly) AMGTalk *talk;
@property (nonatomic, weak) id <AMGTalkViewDelegate> delegate;

- (instancetype)initWithTalk:(AMGTalk *)talk;

@end


@protocol AMGTalkViewDelegate <NSObject>

- (void)talkViewControler:(AMGTalkViewController *)viewController
            didToggleTalk:(AMGTalk *)talk;

@end
