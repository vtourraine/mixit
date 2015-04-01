//
//  AMGTalkCell.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGTalkCell.h"

@interface AMGTalkCell ()

@property (nonatomic, weak) UIImageView *favoritedImageView;

@end


@implementation AMGTalkCell

+ (CGFloat)heightWithTitle:(NSString *)title {
    return 76;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        self.textLabel.numberOfLines = 0;

        UIImageView *favoritedImageView = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.tintColor = [UIColor orangeColor];
            imageView;
        });
        [self.contentView addSubview:favoritedImageView];
        self.favoritedImageView = favoritedImageView;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat                nameLabelOriginX   = 15;
    CGFloat                labelMaxWidth      = CGRectGetWidth(self.contentView.frame)   - nameLabelOriginX - 30;
    CGSize                 labelsMaxSize      = CGSizeMake(labelMaxWidth, CGFLOAT_MAX);
    NSStringDrawingOptions drawingOptions     = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    NSDictionary           *titleAttributes   = @{NSFontAttributeName: self.textLabel.font};

    CGRect titleSize   = [self.textLabel.text boundingRectWithSize:labelsMaxSize
                                                           options:drawingOptions
                                                        attributes:titleAttributes
                                                           context:nil];

    self.textLabel.frame = CGRectMake(nameLabelOriginX,
                                      5,
                                      titleSize.size.width,
                                      44);

    self.detailTextLabel.frame = CGRectMake(nameLabelOriginX,
                                            CGRectGetMaxY(self.contentView.frame) - 24,
                                            //CGRectGetMaxY(self.textLabel.frame) + 2,
                                            labelMaxWidth,
                                            20);

    CGRect favoritedImageViewFrame = CGRectMake(0, 0, 20, 20);
    favoritedImageViewFrame.origin.x = CGRectGetWidth(self.contentView.frame) - 27;
    favoritedImageViewFrame.origin.y = CGRectGetMidY(self.contentView.frame) - CGRectGetMidY(favoritedImageViewFrame);
    self.favoritedImageView.frame = favoritedImageViewFrame;
}

@end
