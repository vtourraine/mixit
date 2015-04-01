//
//  AMGTalkViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGTalkViewController.h"

#import "AMGTalk.h"
#import "AMGMember.h"

#import <AFNetworking/UIImageView+AFNetworking.h>

@interface AMGTalkViewController ()

@property (nonatomic, strong) AMGTalk *talk;

- (void)loadBarButtonItems;

- (void)toggleFavorited:(id)sender;

@end


@implementation AMGTalkViewController

- (instancetype)initWithTalk:(AMGTalk *)talk {
    self = [super init];
    if (self) {
        self.talk  = talk;
        self.title = NSLocalizedString(@"Session", nil);
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    view.backgroundColor  = [UIColor whiteColor];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadBarButtonItems];

    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];

    UILabel *titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont boldSystemFontOfSize:22];
        label.numberOfLines = 0;
        label.text          = self.talk.title;
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:titleLabel];

    NSDateFormatter *dayDateFormatter = [[NSDateFormatter alloc] init];
    dayDateFormatter.dateFormat = @"EE";

    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc] init];
    timeDateFormatter.timeStyle = NSDateFormatterShortStyle;

    UILabel *formatLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont systemFontOfSize:18];
        label.numberOfLines = 0;
        label.text          = [NSString stringWithFormat:@"%@ %@",
                               self.talk.emojiForLanguage ?: @"",
                               self.talk.format ?: @""];
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:formatLabel];
    
    UIImageView *locationImageView = ({
        UIImage     *image     = [[UIImage imageNamed:@"IconLocationPin"]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
    [scrollView addSubview:locationImageView];
    
    UILabel *locationLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont systemFontOfSize:18];
        label.numberOfLines = 0;
        label.text          = self.talk.room;
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:locationLabel];

    UIImageView *timeImageView = ({
        UIImage     *image     = [[UIImage imageNamed:@"IconClock2"]
                                  imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView;
    });
    [scrollView addSubview:timeImageView];

    UILabel *timeLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont systemFontOfSize:18];
        label.numberOfLines = 0;
        label.text          = [NSString stringWithFormat:@"%@, %@ to %@",
                               [dayDateFormatter  stringFromDate:self.talk.startDate],
                               [timeDateFormatter stringFromDate:self.talk.startDate],
                               [timeDateFormatter stringFromDate:self.talk.endDate]];
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:timeLabel];

    AMGMember *speaker = self.talk.fetchSpeakers.firstObject;

    UIImageView *speakerImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        imageView.layer.cornerRadius = 30;
        imageView.clipsToBounds = YES;
        if (speaker.imageURLString) {
            [imageView setImageWithURL:[NSURL URLWithString:speaker.imageURLString]];
        }
        imageView;
    });
    [scrollView addSubview:speakerImageView];

    UILabel *speakerLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont systemFontOfSize:18];
        label.numberOfLines = 0;
        label.text          = [NSString stringWithFormat:@"%@ %@",
                               speaker.firstName ?: @"",
                               speaker.lastName  ?: @""];
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:speakerLabel];
    
    UILabel *summaryLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont italicSystemFontOfSize:18];
        label.numberOfLines = 0;
        label.text          = self.talk.summary;
        label.preferredMaxLayoutWidth = 280;
        label;
    });
    [scrollView addSubview:summaryLabel];

    UILabel *descLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font          = [UIFont systemFontOfSize:16];
        label.numberOfLines = 0;
        label.text          = self.talk.desc;
        label.preferredMaxLayoutWidth = 280;
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

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleLabel]-|"
                                                                      options:kNilOptions
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[formatLabel]-|"
                                                                      options:kNilOptions
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[locationImageView(==20)]-[locationLabel]-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[timeImageView(==20)]-[timeLabel]-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[speakerImageView(==60)]-[speakerLabel]-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[summaryLabel]-|"
                                                                      options:kNilOptions
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[descLabel]-|"
                                                                      options:kNilOptions
                                                                      metrics:@{}
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[titleLabel]-20-[formatLabel]-4-[locationImageView]-2-[timeImageView]-20-[speakerImageView(==60)]-20-[summaryLabel]-20-[descLabel]-40-|"
                                                                      options:kNilOptions
                                                                      metrics:@{}
                                                                        views:views]];
}

- (void)loadBarButtonItems {
    NSString *iconName = @"IconStar";
    if (self.talk.isFavorited) {
        iconName = @"IconStarSelected";
    }

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:iconName]
                                                             style:UIBarButtonItemStyleBordered
                                                            target:self
                                                            action:@selector(toggleFavorited:)];
    item.tintColor = [UIColor orangeColor];

    self.navigationItem.rightBarButtonItem = item;
}


#pragma mark - Actions

- (void)toggleFavorited:(id)sender {
    self.talk.favorited = @(!self.talk.isFavorited);
    [self.talk.managedObjectContext save:nil];

    [self loadBarButtonItems];

    [self.delegate talkViewControler:self didToggleTalk:self.talk];
}

@end
