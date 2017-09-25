//
//  AMGTalkCell.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGTalk;


@interface AMGTalkCell : UITableViewCell

@property (nonatomic, weak, nullable, readonly) UIImageView *favoritedImageView;

+ (CGFloat)defaultHeight;

@end


@interface AMGTalkCell (Configuration)

- (void)configureWithTalk:(nonnull AMGTalk *)talk  isPastYear:(BOOL)isPastYear;

@end
