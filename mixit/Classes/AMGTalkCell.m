//
//  AMGTalkCell.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

#import "AMGTalkCell.h"

@interface AMGTalkCell ()

@property (nonatomic, weak, nullable) UIImageView *favoritedImageView;

@end


@implementation AMGTalkCell

+ (CGFloat)defaultHeight {
    return 76;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    if (self) {
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

    CGFloat nameLabelOriginX = 15;
    if ([self respondsToSelector:@selector(readableContentGuide)]) {
        nameLabelOriginX = self.readableContentGuide.layoutFrame.origin.x;
    }

    CGFloat labelMaxWidth = CGRectGetWidth(self.contentView.frame) - (nameLabelOriginX * 2) - 15;
    CGSize labelsMaxSize = CGSizeMake(labelMaxWidth, CGFLOAT_MAX);
    NSStringDrawingOptions drawingOptions = (NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading);
    NSDictionary *titleAttributes = @{NSFontAttributeName: self.textLabel.font};

    CGRect titleSize   = [self.textLabel.text boundingRectWithSize:labelsMaxSize options:drawingOptions attributes:titleAttributes context:nil];

    self.textLabel.frame = CGRectMake(nameLabelOriginX, 5, titleSize.size.width, 44);
    self.detailTextLabel.frame = CGRectMake(nameLabelOriginX, CGRectGetMaxY(self.contentView.frame) - 24, labelMaxWidth, 20);

    CGRect favoritedImageViewFrame = CGRectMake(0, 0, 20, 20);
    favoritedImageViewFrame.origin.x = CGRectGetWidth(self.contentView.frame) - 27;
    favoritedImageViewFrame.origin.y = CGRectGetMidY(self.contentView.frame) - CGRectGetMidY(favoritedImageViewFrame);
    self.favoritedImageView.frame = favoritedImageViewFrame;
}

@end


#import "AMGTalk.h"

@implementation AMGTalkCell (Configuration)

- (void)configureWithTalk:(nonnull AMGTalk *)talk  isPastYear:(BOOL)isPastYear {
    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc] init];
    timeDateFormatter.timeStyle = NSDateFormatterShortStyle;

    BOOL isUpcomingTalk = (talk.endDate != nil && [talk.endDate timeIntervalSinceNow] > 0);
    // BOOL isUpcomingTalk = YES; // Next year schedule isn’t available yet, so we keep all talks “active”
    BOOL isMissingDetails = (talk.room == nil && talk.startDate == nil && talk.endDate == nil);

    if (isPastYear == NO && isMissingDetails == NO && isUpcomingTalk == NO) {
        self.textLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        self.textLabel.textColor = [UIColor blackColor];
    }

    if (isPastYear == NO && (isUpcomingTalk == NO || isMissingDetails)) {
        self.detailTextLabel.textColor = [UIColor lightGrayColor];
        self.detailTextLabel.font = [UIFont italicSystemFontOfSize:self.detailTextLabel.font.pointSize];
    }
    else {
        self.detailTextLabel.textColor = [UIColor blackColor];
        self.detailTextLabel.font = [UIFont systemFontOfSize:self.detailTextLabel.font.pointSize];
    }

    self.textLabel.text = talk.title;
    self.detailTextLabel.text = ({
        NSString *text = [NSString stringWithFormat:NSLocalizedString(@"%@%@%@", nil), talk.emojiForLanguage, talk.emojiForLanguage ? @" " : @"", [talk.format capitalizedStringWithLocale:[NSLocale currentLocale]]];

        if (isPastYear == NO) {
            text = [text stringByAppendingString:NSLocalizedString(@", ", nil)];

            if (talk.room == nil && (talk.startDate == nil || talk.endDate == nil)) {
                text = [text stringByAppendingFormat:NSLocalizedString(@"Time and place not announced yet", nil), talk.room];
            }

            if (talk.room) {
                text = [text stringByAppendingString:NSLocalizedStringFromTable([talk.room lowercaseString], @"Rooms", nil)];
            }

            if (talk.startDate && talk.endDate) {
                text = [text stringByAppendingFormat:NSLocalizedString(@", %@ to %@", nil), [timeDateFormatter stringFromDate:talk.startDate], [timeDateFormatter stringFromDate:talk.endDate]];
            }
        }

        text;
    });

    if (talk.isFavorited) {
        self.favoritedImageView.image = [[UIImage imageNamed:@"IconStarSelected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else {
        self.favoritedImageView.image = nil;
    }
}

@end
