//
//  AMGTalkViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2021 Studio AMANgA. All rights reserved.
//

#import "AMGTalkViewController.h"

#import "AMGTalk.h"
#import "AMGMember.h"
#import "AMGMixITClient.h"
#import "AMGPlansViewController.h"
#import "UIColor+MiXiT.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface AMGTalkViewController ()

@property (nonatomic, strong, nullable) AMGTalk *talk;
@property (nonatomic, weak, nullable) NSLayoutConstraint *titleWidthConstraint;
@property (nonatomic, strong, nullable) UIPreviewAction *toggleFavoritesPreviewAction;

@end


@implementation AMGTalkViewController

- (instancetype)initWithTalk:(AMGTalk *)talk {
    self = [super init];

    if (self) {
        self.talk = talk;
        self.title = NSLocalizedString(@"Session", nil);
    }

    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor mixitBackgroundColor];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    
    [self loadBarButtonItems];

    BOOL isPastYear = (self.talk.year != nil && [[AMGMixITClient currentYear] isEqualToNumber:self.talk.year] == NO);
    BOOL isOnlineEdition = (isPastYear == NO);

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont boldSystemFontOfSize:22];
        label.numberOfLines = 0;
        label.text = self.talk.title;
        label;
    });
    [scrollView addSubview:titleLabel];

    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"EEEE";

    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc] init];
    timeDateFormatter.timeStyle = NSDateFormatterShortStyle;

    UILabel *formatLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:18];
        label.numberOfLines = 0;
        label.text = [NSString stringWithFormat:@"%@ %@", self.talk.emojiForLanguage ?: @"", [self.talk.format capitalizedStringWithLocale:[NSLocale currentLocale]] ?: @""];
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:formatLabel];

    UIImageView *locationImageView = ({
        UIImage *image = nil;
        if (@available(iOS 13.0, *)) {
            image = [UIImage systemImageNamed:@"map"];
        } else {
            image = [[UIImage imageNamed:@"IconMapLocation"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tintColor = [UIColor mixitLabelColor];
        imageView;
    });

    if (isPastYear == NO && isOnlineEdition == NO) {
        [scrollView addSubview:locationImageView];
    }

    const CGFloat infoLabelFontSize = 18;

    UILabel *locationLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        if (self.talk.room) {
            label.textColor = [UIColor mixitLabelColor];
            label.font = [UIFont systemFontOfSize:infoLabelFontSize];
            label.text = NSLocalizedStringFromTable([self.talk.room lowercaseString], @"Rooms", nil);
        }
        else {
            label.textColor = [UIColor mixitDisabledLabelColor];
            label.font = [UIFont italicSystemFontOfSize:infoLabelFontSize];
            label.text = NSLocalizedString(@"Not announced yet", nil);
        }
        label;
    });

    if (isPastYear == NO && isOnlineEdition == NO) {
        [scrollView addSubview:locationLabel];

        // UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(presentPlansViewController:)];
        // locationLabel.userInteractionEnabled = YES;
        // [locationLabel addGestureRecognizer:recognizer];
    }

    UIImageView *timeImageView = ({
        UIImage *image = nil;
        if (@available(iOS 13.0, *)) {
            image = [UIImage systemImageNamed:@"clock"];
        } else {
            image = [[UIImage imageNamed:@"IconClock2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tintColor = [UIColor mixitLabelColor];
        imageView;
    });

    if (isPastYear == NO) {
        [scrollView addSubview:timeImageView];
    }

    UILabel *timeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        if (self.talk.startDate && self.talk.endDate) {
            label.textColor = [UIColor mixitLabelColor];
            label.font = [UIFont systemFontOfSize:infoLabelFontSize];
            label.text = [NSString stringWithFormat:
                          NSLocalizedString(@"%@, %@ to %@", nil),
                          [dayDateFormatter  stringFromDate:self.talk.startDate].capitalizedString,
                          [timeDateFormatter stringFromDate:self.talk.startDate],
                          [timeDateFormatter stringFromDate:self.talk.endDate]];
        }
        else {
            label.textColor = [UIColor mixitDisabledLabelColor];
            label.font = [UIFont italicSystemFontOfSize:infoLabelFontSize];
            label.text = NSLocalizedString(@"Not announced yet", nil);
        }
        label;
    });

    if (isPastYear == NO) {
        [scrollView addSubview:timeLabel];
    }

    AMGMember *speaker = self.talk.fetchSpeakers.firstObject;

    UIImageView *speakerImageView = ({
        UIImage *image = nil;
        if (@available(iOS 13.0, *)) {
            image = [UIImage systemImageNamed:@"person.circle"];
        } else {
            image = [UIImage imageNamed:@"IconPerson"];
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });

    if (speaker.photoURLString) {
        [speakerImageView setImageWithURL:[NSURL URLWithString:speaker.photoURLString]];
    }

    [scrollView addSubview:speakerImageView];

    UILabel *speakerLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:infoLabelFontSize];
        label.numberOfLines = 0;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", speaker.firstName ?: @"", speaker.lastName ?: @""]];
        if (speaker.company.length > 0) {
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
            [text appendAttributedString:[[NSAttributedString alloc] initWithString:speaker.company attributes:@{NSFontAttributeName: [UIFont italicSystemFontOfSize:16]}]];
        }
        label.attributedText = text;
        label;
    });
    [scrollView addSubview:speakerLabel];

    UILabel *summaryLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont italicSystemFontOfSize:infoLabelFontSize];
        label.numberOfLines = 0;
        label.text = self.talk.summary;
        label;
    });
    [scrollView addSubview:summaryLabel];

    UILabel *descLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont systemFontOfSize:16];
        label.numberOfLines = 0;
        label.text = self.talk.desc;
        label;
    });
    [scrollView addSubview:descLabel];

    NSDictionary *views = NSDictionaryOfVariableBindings(self.view,
                                                         scrollView,
                                                         titleLabel,
                                                         formatLabel,
                                                         locationImageView,
                                                         locationLabel,
                                                         timeImageView,
                                                         timeLabel,
                                                         speakerImageView,
                                                         speakerLabel,
                                                         summaryLabel,
                                                         descLabel);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:0 views:views]];

    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    if (self.navigationController) {
        screenWidth = CGRectGetWidth(self.navigationController.view.frame);
    }

    NSLayoutConstraint *titleWidthConstraint = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:kNilOptions multiplier:1 constant:screenWidth - 2*15];
    [self.view addConstraint:titleWidthConstraint];
    self.titleWidthConstraint = titleWidthConstraint;

    NSArray <NSLayoutConstraint *> *equalWidthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:[scrollView(==titleLabel)]" options:0 metrics:0 views:views];
    for (NSLayoutConstraint *constraint in equalWidthConstraints) {
        constraint.priority = UILayoutPriorityDefaultHigh;
    }
    [self.view addConstraints:equalWidthConstraints];

    const CGFloat speakerImageSize = 60;
    speakerImageView.layer.cornerRadius = speakerImageSize / 2;
    speakerImageView.clipsToBounds = YES;
    [[speakerImageView.widthAnchor constraintEqualToConstant:speakerImageSize] setActive:YES];
    [[speakerImageView.heightAnchor constraintEqualToConstant:speakerImageSize] setActive:YES];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[speakerImageView]-[speakerLabel]" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:views]];

    NSString *verticalFormat = nil;
    if (isOnlineEdition && !isPastYear) {
        verticalFormat = @"V:|-20-[titleLabel]-20-[speakerImageView]-20-[formatLabel]-5-[timeImageView]-40-[summaryLabel]-20-[descLabel]-40-|";
    }
    else if (isPastYear == NO) {
        verticalFormat = @"V:|-20-[titleLabel]-20-[speakerImageView]-20-[formatLabel]-5-[locationImageView]-2-[timeImageView]-40-[summaryLabel]-20-[descLabel]-40-|";
    }
    else {
        verticalFormat = @"V:|-20-[titleLabel]-20-[speakerImageView]-20-[formatLabel]-40-[summaryLabel]-20-[descLabel]-40-|";
    }

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:verticalFormat options:kNilOptions metrics:@{} views:views]];

    UILayoutGuide *layoutGuide = self.view.readableContentGuide;
    [[layoutGuide.leadingAnchor constraintEqualToAnchor:titleLabel.leadingAnchor] setActive:YES];
    [[layoutGuide.trailingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor] setActive:YES];
    [[layoutGuide.leadingAnchor constraintEqualToAnchor:formatLabel.leadingAnchor] setActive:YES];
    [[layoutGuide.trailingAnchor constraintEqualToAnchor:formatLabel.trailingAnchor] setActive:YES];
    [[layoutGuide.leadingAnchor constraintEqualToAnchor:summaryLabel.leadingAnchor] setActive:YES];
    [[layoutGuide.trailingAnchor constraintEqualToAnchor:summaryLabel.trailingAnchor] setActive:YES];
    [[layoutGuide.leadingAnchor constraintEqualToAnchor:descLabel.leadingAnchor] setActive:YES];
    [[layoutGuide.trailingAnchor constraintEqualToAnchor:descLabel.trailingAnchor] setActive:YES];
    [[layoutGuide.leadingAnchor constraintEqualToAnchor:speakerImageView.leadingAnchor] setActive:YES];
    [[layoutGuide.trailingAnchor constraintEqualToAnchor:speakerLabel.trailingAnchor] setActive:YES];

    if (isOnlineEdition == NO && !isPastYear) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[locationImageView(==20)]-[locationLabel]" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:views]];

        [[layoutGuide.leadingAnchor constraintEqualToAnchor:locationImageView.leadingAnchor] setActive:YES];
        [[layoutGuide.trailingAnchor constraintEqualToAnchor:locationLabel.trailingAnchor] setActive:YES];
    }

    if (isPastYear == NO) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[timeImageView(==20)]-[timeLabel]" options:NSLayoutFormatAlignAllCenterY metrics:@{} views:views]];

        [[layoutGuide.leadingAnchor constraintEqualToAnchor:timeImageView.leadingAnchor] setActive:YES];
        [[layoutGuide.trailingAnchor constraintEqualToAnchor:timeLabel.trailingAnchor] setActive:YES];
    }
}

- (void)loadBarButtonItems {
    UIImage *image = nil;
    if (@available(iOS 13.0, *)) {
        NSString *iconName = @"star";
        if (self.talk.isFavorited) {
            iconName = @"star.fill";
        }
        image = [UIImage systemImageNamed:iconName];
    } else {
        NSString *iconName = @"IconStar";
        if (self.talk.isFavorited) {
            iconName = @"IconStarSelected";
        }
        image = [UIImage imageNamed:iconName];
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(toggleFavorited:)];
    item.tintColor = [UIColor mixitOrange];

    self.navigationItem.rightBarButtonItem = item;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.titleWidthConstraint.constant = size.width - (2 * 15);
    }];
}

#pragma mark - Actions

- (void)toggleFavorited:(id)sender {
    self.talk.favorited = @(!self.talk.isFavorited);
    [self.talk.managedObjectContext save:nil];

    [self loadBarButtonItems];

    [self.delegate talkViewControler:self didToggleTalk:self.talk];
}

- (IBAction)presentPlansViewController:(nullable id)sender {
    AMGPlansViewController *viewController = [[AMGPlansViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - 3D Touch preview actions

- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    if (!self.toggleFavoritesPreviewAction) {
        self.toggleFavoritesPreviewAction =
        [UIPreviewAction
         actionWithTitle:(self.talk.isFavorited) ? NSLocalizedString(@"Remove from Favorites", nil) : NSLocalizedString(@"Add to Favorites", nil)
         style:UIPreviewActionStyleDefault
         handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
             [self toggleFavorited:nil];
         }];
    }

    return @[self.toggleFavoritesPreviewAction];
}

@end
