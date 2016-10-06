//
//  AMGTalkCell.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import UIKit;


@interface AMGTalkCell : UITableViewCell

@property (nonatomic, weak, nullable, readonly) UIImageView *favoritedImageView;

+ (CGFloat)heightWithTitle:(nonnull NSString *)title;

@end
