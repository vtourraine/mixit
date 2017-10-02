//
//  AMGTalksViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2017 Studio AMANgA. All rights reserved.
//

#import "AMGTalksViewController.h"

#import <SVProgressHUD.h>

#import "AMGTalk.h"
#import "AMGMember.h"
#import "AMGMixITSyncManager.h"
#import "AMGMixITClient.h"

#import "AMGTalksSearchResultsViewController.h"
#import "AMGTalkViewController.h"
#import "AMGTalkCell.h"

#import "AMGAboutViewController.h"

#import "UIColor+MiXiT.h"
#import "UIViewController+AMGTwitterManager.h"

static NSString * const AMGTalkCellIdentifier = @"Cell";


@interface AMGTalksViewController () <AMGMixITSyncManagerDelegate, AMGTalkViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, assign, getter=isPastYear) BOOL pastYear;
@property (nonatomic, copy) NSArray <AMGTalksSection *> *sections;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, weak) id <UIViewControllerPreviewing> previewingContext;

@end


@implementation AMGTalksViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];

    if (self) {
        self.title = NSLocalizedString(@"MiXiT Schedule", nil);
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Schedule", nil) style:UIBarButtonItemStylePlain target:nil action:nil];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
    [SVProgressHUD setForegroundColor:self.view.tintColor];

    [self loadBarButtonItems];

    self.syncManager.delegate = self;
    self.pastYear = (self.year != nil && [[AMGMixITClient currentYear] isEqualToNumber:self.year] == NO);

    [self.tableView registerClass:AMGTalkCell.class forCellReuseIdentifier:AMGTalkCellIdentifier];

    [self reloadSections];
    [self loadSearchController];
    [self loadRefreshControl];

    if ([self respondsToSelector:@selector(traitCollection)] &&
        [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
        self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (void)loadBarButtonItems {
    if (self.canTweet) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconTwitter"] style:UIBarButtonItemStylePlain target:self action:@selector(presentTweetComposer)];
        self.navigationItem.rightBarButtonItem = item;
    }

    if (self.year == nil) {
        UIBarButtonItem *infoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"IconInfo"] style:UIBarButtonItemStylePlain target:self action:@selector(presentInfoViewController:)];
        self.navigationItem.leftBarButtonItem = infoItem;
    }
}

- (void)loadRefreshControl {
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = control;
}

- (void)loadSearchController {
    AMGTalksSearchResultsViewController* resultsController = [[AMGTalksSearchResultsViewController alloc] init];
    resultsController.tableView.delegate = self;

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];
    self.searchController.searchResultsUpdater = self;

    if (@available(iOS 11.0, *)) {
        self.searchController.searchBar.barTintColor = [UIColor mixitOrange];
        self.searchController.searchBar.tintColor = [UIColor mixitOrange];
        self.searchController.searchBar.barStyle = UIBarStyleBlack;
        self.navigationItem.searchController = self.searchController;
    }
    else {
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }

    self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.sections.count == 0) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Refreshing Data", nil)];
        [self refresh:nil];
    }

    if (self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
    }
}

#pragma mark - Data

- (void)reloadSections {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:AMGTalk.entityName];

    request.predicate = [self yearPredicate];
    request.sortDescriptors = [self talksSortDescriptors];

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

- (nonnull NSPredicate *)yearPredicate {
    return [NSPredicate predicateWithFormat:@"%K = %@", NSStringFromSelector(@selector(year)), self.year ?: [AMGMixITClient currentYear]];
}

- (nonnull NSPredicate *)searchPredicateWithQuery:(nonnull NSString *)query {
    return [NSPredicate predicateWithFormat:@"title CONTAINS [cd] %@ OR summary CONTAINS [cd] %@ OR format CONTAINS [cd] %@", query, query, query];
}

- (nonnull NSArray <NSSortDescriptor *> *)talksSortDescriptors {
    return @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"room" ascending:YES],
             [NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
}

#pragma mark - Actions

- (void)refresh:(id)sender {
    [self.syncManager startSyncForYear:self.year ?: [AMGMixITClient currentYear]];
}

- (void)presentInfoViewController:(id)sender {
    AMGAboutViewController *viewController = [[AMGAboutViewController alloc] init];
    viewController.syncManager = self.syncManager;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    if (@available(iOS 11.0, *)) {
        navigationController.navigationBar.prefersLargeTitles = YES;
    }

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

    return [[[dayFormatter stringFromDate:sectionInfo.date].capitalizedString
             stringByAppendingString:@", "]
            stringByAppendingString:[formatter stringFromDate:sectionInfo.date]];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AMGTalkCell defaultHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AMGTalkCell defaultHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    AMGTalk *talk = sectionInfo.objects[indexPath.row];

    AMGTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:AMGTalkCellIdentifier forIndexPath:indexPath];
    [cell configureWithTalk:talk isPastYear:self.isPastYear];

    return cell;
}

- (AMGTalk *)talkForTableView:(nonnull UITableView *)tableView atIndexPath:(nonnull NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    return sectionInfo.objects[indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AMGTalk *talk = nil;

    AMGTalksSearchResultsViewController *resultsViewController = ((AMGTalksSearchResultsViewController *)self.searchController.searchResultsController);
    if (tableView == resultsViewController.tableView) {
        talk = resultsViewController.searchResults[indexPath.row];
    }
    else {
        talk = [self talkForTableView:tableView atIndexPath:indexPath];
    }

    AMGTalkViewController *viewController = [[AMGTalkViewController alloc] initWithTalk:talk];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMGTalk *talk = [self talkForTableView:tableView atIndexPath:indexPath];

    UITableViewRowAction *action =
    [UITableViewRowAction
     rowActionWithStyle:UITableViewRowActionStyleNormal
     title:talk.isFavorited ? NSLocalizedString(@"Remove from Favorites", nil) : NSLocalizedString(@"Add to Favorites", nil)
     handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
         talk.favorited = @(!talk.isFavorited);
         [talk.managedObjectContext save:nil];

         [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    action.backgroundColor = [UIColor orangeColor];

    return @[action];
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(11.0) {
    AMGTalk *talk = [self talkForTableView:tableView atIndexPath:indexPath];
    
    UIContextualAction *action = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:talk.isFavorited ? NSLocalizedString(@"Remove from Favorites", nil) : NSLocalizedString(@"Add to Favorites", nil) handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        talk.favorited = @(!talk.isFavorited);
        [talk.managedObjectContext save:nil];
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        completionHandler(YES);
    }];
    //action.image = [UIImage imageNamed:talk.isFavorited ? @"IconStar" : @"IconStarSelected"];
    action.backgroundColor = [UIColor orangeColor];

    if (@available(iOS 11.0, *)) {
        UISwipeActionsConfiguration *configuration = [UISwipeActionsConfiguration configurationWithActions:@[action]];
        configuration.performsFirstActionWithFullSwipe = NO;
        return configuration;
    } else {
        return nil;
    }
}

#pragma mark - MiXiT sync manager delegate

- (void)syncManagerDidStartSync:(AMGMixITSyncManager *)syncManager {}

- (void)syncManager:(AMGMixITSyncManager *)syncManager didFailSyncWithError:(NSError *)error {
    [self.refreshControl endRefreshing];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sync Error", nil) message:error.localizedDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

- (void)syncManagerDidFinishSync:(AMGMixITSyncManager *)syncManager {
    [self.refreshControl endRefreshing];

    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }

    [self reloadSections];
    [self.tableView reloadData];
}

#pragma mark - Talk view delegate

- (void)talkViewControler:(AMGTalkViewController *)viewController didToggleTalk:(AMGTalk *)talk {
    [self.tableView reloadData];
}

#pragma mark - View controller previewing delegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    UITableView *tableView = self.tableView;
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:location];
    if (!indexPath) {
        return nil;
    }

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        return nil;
    }

    AMGTalk *talk;

    id <NSFetchedResultsSectionInfo> sectionInfo = self.sections[indexPath.section];
    talk = sectionInfo.objects[indexPath.row];

    AMGTalkViewController *talkViewController = [[AMGTalkViewController alloc] initWithTalk:talk];
    talkViewController.delegate = self;

    previewingContext.sourceRect = cell.frame;

    return talkViewController;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self showViewController:viewControllerToCommit sender:self];
}

#pragma mark - Search results updating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    NSMutableArray <AMGTalk *> *searchResults = [NSMutableArray array];
    NSFetchRequest *talksRequest = [NSFetchRequest fetchRequestWithEntityName:AMGTalk.entityName];

    talksRequest.sortDescriptors = [self talksSortDescriptors];

    NSArray *predicates = @[[self searchPredicateWithQuery:searchString], [self yearPredicate]];
    talksRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];

    [searchResults addObjectsFromArray:[self.syncManager.context executeFetchRequest:talksRequest error:nil]];

    NSFetchRequest *authorsRequest = [NSFetchRequest fetchRequestWithEntityName:AMGMember.entityName];
    authorsRequest.predicate = [NSPredicate predicateWithFormat:@"firstName CONTAINS [cd] %@ OR lastName CONTAINS [cd] %@", searchString, searchString];
    NSArray <AMGMember *> *authors = [self.syncManager.context executeFetchRequest:authorsRequest error:nil];
    for (AMGMember *author in authors) {
        // This request doesn’t give an exact identifier match...
        talksRequest.predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K CONTAINS %@", NSStringFromSelector(@selector(year)), self.year ?: [AMGMixITClient currentYear], NSStringFromSelector(@selector(speakersIdentifiers)), author.identifier];

        // ... so we need filter the results to keep only matching talks.
        NSArray <AMGTalk *> *authorTalks = [self.syncManager.context executeFetchRequest:talksRequest error:nil];
        for (AMGTalk *talk in authorTalks) {
            if ([talk.speakersIdentifiersArray containsObject:author.identifier]) {
                [searchResults addObject:talk];
            }
        }
    }

    AMGTalksSearchResultsViewController *resultsViewController = ((AMGTalksSearchResultsViewController *)self.searchController.searchResultsController);
    resultsViewController.searchResults = searchResults;
    [resultsViewController.tableView reloadData];
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
