//
//  AMGTalksViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

#import "AMGTalksViewController.h"

#import <SVProgressHUD.h>

#import "AMGTalk.h"
#import "AMGMixITSyncManager.h"

#import "AMGTalkViewController.h"
#import "AMGTalkCell.h"

#import "AMGAboutViewController.h"

#import "UIViewController+AMGTwitterManager.h"

static NSString * const AMGTalkCellIdentifier = @"Cell";


@interface AMGTalksViewController () <AMGMixITSyncManagerDelegate, AMGTalkViewDelegate>

@property (nonatomic, copy) NSArray *sections;

- (void)reloadSections;
- (void)loadBarButtonItems;
- (void)loadRefreshControl;

- (void)presentInfoViewController:(id)sender;

@end


@implementation AMGTalksViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        self.title = NSLocalizedString(@"Mix-IT Schedule", nil);
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadBarButtonItems];

    self.syncManager.delegate = self;

    [self.tableView registerClass:AMGTalkCell.class
           forCellReuseIdentifier:AMGTalkCellIdentifier];

    [self reloadSections];

    [self loadRefreshControl];
}

- (void)loadBarButtonItems {
    if (self.canTweet) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconTwitter"]
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self action:@selector(presentTweetComposer)];
        self.navigationItem.rightBarButtonItem = item;
    }

    UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconInfo"]
                                                                 style:UIBarButtonItemStyleBordered
                                                                target:self
                                                                action:@selector(presentInfoViewController:)];
    self.navigationItem.leftBarButtonItem = infoItem;
}

- (void)loadRefreshControl {
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self
                action:@selector(refresh:)
      forControlEvents:UIControlEventValueChanged];
    self.refreshControl = control;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.sections.count == 0) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Refreshing Data", nil)];
        [self refresh:nil];
    }

    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow
                                      animated:animated];
    }
}

- (void)reloadSections {
    NSFetchRequest   *request        = [NSFetchRequest   fetchRequestWithEntityName:AMGTalk.entityName];
    NSSortDescriptor *startSort      = [NSSortDescriptor sortDescriptorWithKey:@"startDate"  ascending:YES];
    NSSortDescriptor *roomSort       = [NSSortDescriptor sortDescriptorWithKey:@"room"       ascending:YES];
    NSSortDescriptor *identifierSort = [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES];
    request.sortDescriptors = @[startSort, roomSort, identifierSort];

    NSArray *talks = [self.syncManager.context executeFetchRequest:request error:nil];

    NSDate *startForLastTalk = nil;
    AMGTalksSection *currentSection;
    NSMutableArray *talksForCurrentSection;
    NSMutableArray *sections = [NSMutableArray array];

    for (AMGTalk *talk in talks) {
        if (!startForLastTalk || [talk.startDate timeIntervalSinceDate:startForLastTalk] > 1) {
            if (currentSection) {
                currentSection.talks = talksForCurrentSection;
                [sections addObject:currentSection];
            }

            currentSection = [AMGTalksSection new];
            currentSection.date = talk.startDate;
            talksForCurrentSection = [NSMutableArray array];
            if (!startForLastTalk || [talk.startDate timeIntervalSinceDate:startForLastTalk] > 60*60*5) {
                currentSection.firstSectionForTheDay = YES;
            }
        }

        [talksForCurrentSection addObject:talk];

        startForLastTalk = talk.startDate;
    }
    if (currentSection) {
        currentSection.talks = talksForCurrentSection;
        [sections addObject:currentSection];
    }

    self.sections = sections;
}


#pragma mark - Actions

- (void)refresh:(id)sender {
    [self.syncManager startSync];
}

- (void)presentInfoViewController:(id)sender {
    AMGAboutViewController *viewController = [[AMGAboutViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[section];
    return sectionInfo.numberOfObjects;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    AMGTalksSection *sectionInfo = self.sections[section];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.doesRelativeDateFormatting = YES;
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    dayFormatter.dateFormat = @"EEEE";

    return [[[dayFormatter stringFromDate:sectionInfo.date]
             stringByAppendingString:@", "]
            stringByAppendingString:[formatter stringFromDate:sectionInfo.date]];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    AMGTalk *talk = sectionInfo.objects[indexPath.row];
    return [AMGTalkCell heightWithTitle:talk.title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMGTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:AMGTalkCellIdentifier
                                                        forIndexPath:indexPath];
    
    NSDateFormatter *timeDateFormatter = [[NSDateFormatter alloc] init];
    timeDateFormatter.timeStyle = NSDateFormatterShortStyle;

    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    AMGTalk *talk = sectionInfo.objects[indexPath.row];

    cell.textLabel.text       = talk.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@, %@ to %@",
                                 talk.emojiForLanguage ?: @"",
                                 talk.room ?: @"",
                                 [timeDateFormatter stringFromDate:talk.startDate],
                                 [timeDateFormatter stringFromDate:talk.endDate]];

    if (talk.isFavorited) {
        cell.favoritedImageView.image = [[UIImage imageNamed:@"IconStarSelected"]
                                         imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else {
        cell.favoritedImageView.image = nil;
    }

    if ([talk.endDate timeIntervalSinceNow] > 0) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    AMGTalk *talk = sectionInfo.objects[indexPath.row];

    AMGTalkViewController *viewController = [[AMGTalkViewController alloc] initWithTalk:talk];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Mix-IT sync manager delegate

- (void)syncManagerDidStartSync:(AMGMixITSyncManager *)syncManager {}

- (void)syncManager:(AMGMixITSyncManager *)syncManager didFailSyncWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sync Error", nil)
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil] show];
}

- (void)syncManagerDidFinishSync:(AMGMixITSyncManager *)syncManager {
    [self.refreshControl endRefreshing];
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

    [self reloadSections];
    [self.tableView reloadData];
}

#pragma mark - AMGTalkViewDelegate

- (void)talkViewControler:(AMGTalkViewController *)viewController didToggleTalk:(AMGTalk *)talk {
//    [self reloadSections];
    [self.tableView reloadData];
}

@end


@implementation AMGTalksSection

- (NSString *)indexTitle {
    return nil;
}

- (NSString *)name {
    return [self.date description];
}

- (NSArray *)objects {
    return self.talks;
}

- (NSUInteger)numberOfObjects {
    return self.talks.count;
}

@end
