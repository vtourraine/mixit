//
//  AMGTalkCell.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

@import UIKit;

@interface AMGTalkCell : UITableViewCell

@property (nonatomic, weak, readonly) UIImageView *favoritedImageView;

+ (CGFloat)heightWithTitle:(NSString *)title;

@end
