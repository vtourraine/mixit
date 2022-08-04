//
//  AMGTalkViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2021 Studio AMANgA. All rights reserved.
//

@import UIKit;
@import EventKit;
@import EventKitUI;

@class AMGTalk;
@protocol AMGTalkViewDelegate;


@interface AMGTalkViewController : UIViewController <EKEventEditViewDelegate>

@property (nonatomic, strong, nullable, readonly) AMGTalk *talk;
@property (nonatomic, weak, nullable) id <AMGTalkViewDelegate> delegate;

- (nonnull instancetype)initWithTalk:(nonnull AMGTalk *)talk;

@end


@protocol AMGTalkViewDelegate <NSObject>

- (void)talkViewControler:(nonnull AMGTalkViewController *)viewController
            didToggleTalk:(nonnull AMGTalk *)talk;

@end
