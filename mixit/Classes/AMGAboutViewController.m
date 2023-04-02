//
//  AMGAboutViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 26/03/15.
//  Copyright (c) 2015-2022 Studio AMANgA. All rights reserved.
//

#import "AMGAboutViewController.h"

#import "UIColor+MiXiT.h"

#import "AMGMixITClient.h"
#import "AMGTalksViewController.h"
#import "AMGPlansViewController.h"

@import MapKit;
@import CoreLocation;
@import SafariServices;

static NSString * const AMGButtonCellIdentifier = @"Cell";


@interface AMGAboutViewController ()//  <CLLocationManagerDelegate>

@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, strong) MKMapView *mapView;
// @property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong, nullable) NSArray <NSNumber *> *pastYears;

@end


NS_ENUM(NSUInteger, AMGAboutSections) {
    AMGAboutMapSection,
    AMGAboutLinksSection,
    AMGAboutPastYearsSection
};

NS_ENUM(NSUInteger, AMGMapRows) {
    AMGMapOpenInMapsRow,
    AMGMapPlansRow // Hidden
};


@implementation AMGAboutViewController

#pragma mark - View life cycle

- (instancetype)init {
    self = [super initWithStyle:UITableViewStyleGrouped];

    if (self) {
        self.title = NSLocalizedString(@"About MiXiT", nil);
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pastYears = [AMGMixITClient pastYears];

    [self loadNavigationItems];
    [self loadHeaderView];
    [self loadFooterView];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:AMGButtonCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    /*
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
     */
}

- (void)loadNavigationItems {
    // UIBarButtonSystemItemClose doesn’t render well with the dark navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

- (void)loadHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 0)];

    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo"]];
    logoView.frame = CGRectMake((CGRectGetWidth(headerView.frame) - CGRectGetWidth(logoView.frame))/2, 2*20,
                                CGRectGetWidth(logoView.frame), CGRectGetHeight(logoView.frame));
    logoView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [headerView addSubview:logoView];

    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoView.frame) + 8, CGRectGetWidth(headerView.frame), 80)];
    dateLabel.font = [UIFont boldSystemFontOfSize:20];
    dateLabel.numberOfLines = 2;
    dateLabel.text = NSLocalizedString(@"April 13 & 14, 2023\nLyon, France", nil);
    dateLabel.textAlignment = NSTextAlignmentCenter;
    dateLabel.textColor = [UIColor mixitActionColor];
    dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:dateLabel];

    // CPE coordinates : 45.78392, 4.869014
    // Manufacture des Tabacs coordinates: 45.7481118, 4.8602011
    self.coordinates = CLLocationCoordinate2DMake(45.7481118, 4.8602011);

    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(dateLabel.frame) + 20, CGRectGetWidth(headerView.frame), 200)];
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.coordinates;
    annotation.title = NSLocalizedString(@"MiXiT", nil);
    annotation.subtitle = NSLocalizedString(@"Manufacture des Tabacs", nil);
    [mapView addAnnotation:annotation];
    mapView.region = MKCoordinateRegionMake(self.coordinates, MKCoordinateSpanMake(0.05, 0.05));
    [headerView addSubview:mapView];
    self.mapView = mapView;

    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(mapView.frame), CGRectGetWidth(headerView.frame), 1/[UIScreen mainScreen].scale)];

    if (@available(iOS 13.0, *)) {
        topBorder.backgroundColor = [UIColor separatorColor];
    }
    else {
        topBorder.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
    }
    topBorder.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerView addSubview:topBorder];

    headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetMaxY(mapView.frame));
    self.tableView.tableHeaderView = headerView;
}

- (void)loadFooterView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 150)];
    label.numberOfLines = 0;
    label.textColor = [UIColor mixitDisabledLabelColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    label.userInteractionEnabled = YES;
    label.text = NSLocalizedString(@"This app isn’t affiliated with the MiXiT team.\n"
                                   @"Made by @vtourraine.", nil);
    self.tableView.tableFooterView = label;

    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openVTourraine:)];
    recognizer.numberOfTapsRequired = 1;
    [label addGestureRecognizer:recognizer];
}

#pragma mark - Actions

- (IBAction)openInMaps:(nullable id)sender {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinates addressDictionary:nil];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = NSLocalizedString(@"MiXiT", nil);

    [item openInMapsWithLaunchOptions:@{MKLaunchOptionsMapCenterKey: [NSValue valueWithMKCoordinate:self.coordinates]}];
}

- (IBAction)presentPlansViewController:(nullable id)sender {
    AMGPlansViewController *viewController = [[AMGPlansViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)openInSafari:(nullable id)sender {
    [self openURLString:@"https://mixitconf.org"];
}

- (IBAction)openVTourraine:(nullable id)sender {
    [self openURLString:@"https://www.vtourraine.net?mixit"];
}

- (IBAction)dismiss:(nullable id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openURLString:(nonnull NSString *)URLString {
    NSURL *URL = [NSURL URLWithString:URLString];

    if ([SFSafariViewController class]) {
        SFSafariViewController *viewController = [[SFSafariViewController alloc] initWithURL:URL];
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else {
        [[UIApplication sharedApplication] openURL:URL options:@{} completionHandler:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case AMGAboutMapSection:
            return 1;

        case AMGAboutLinksSection:
            return 1;

        case AMGAboutPastYearsSection:
            return self.pastYears.count;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AMGButtonCellIdentifier forIndexPath:indexPath];

    switch (indexPath.section) {
        case AMGAboutMapSection: {
            switch (indexPath.row) {
                case AMGMapOpenInMapsRow:
                    [self configureCell:cell forActionWithTitle:NSLocalizedString(@"Open in Maps", nil)];
                    break;

                case AMGMapPlansRow:
                    [self configureCell:cell forActionWithTitle:NSLocalizedString(@"Plans", nil)];
                    break;
            }
            break;
        }

        case AMGAboutLinksSection:
            [self configureCell:cell forActionWithTitle:NSLocalizedString(@"Open MiXiT website", nil)];
            break;

        case AMGAboutPastYearsSection:
            [self configureCell:cell forPastYearAtRow:indexPath.row];
            break;
    }

    return cell;
}

- (void)configureCell:(nonnull UITableViewCell *)cell forPastYearAtRow:(NSInteger)row {
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.textColor = [UIColor mixitLabelColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if ([self.pastYears[row] integerValue] < 2017) {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Mix-IT %@", nil), self.pastYears[row]];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"MiXiT %@", nil), self.pastYears[row]];
    }
}

- (void)configureCell:(nonnull UITableViewCell *)cell forActionWithTitle:(nonnull NSString *)title {
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.textLabel.textColor = [UIColor mixitActionColor];
    cell.textLabel.text = title;

    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case AMGAboutMapSection:
            switch (indexPath.row) {
                case AMGMapOpenInMapsRow:
                    [self openInMaps:nil];
                    break;

                case AMGMapPlansRow:
                    [self presentPlansViewController:nil];
                    break;
            }
            break;

        case AMGAboutLinksSection:
            [self openInSafari:nil];
            break;

        case AMGAboutPastYearsSection:
            [self presentTalksViewControllerForYear:self.pastYears[indexPath.row]];
            break;
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)presentTalksViewControllerForYear:(nonnull NSNumber *)year {
    AMGTalksViewController *viewController = [[AMGTalksViewController alloc] init];
    viewController.syncManager = self.syncManager;
    viewController.year = year;
    if ([year integerValue] < 2017) {
        viewController.title = [NSString stringWithFormat:NSLocalizedString(@"Mix-IT %@", nil), year];
    }
    else {
        viewController.title = [NSString stringWithFormat:NSLocalizedString(@"MiXiT %@", nil), year];
    }

    [self.navigationController pushViewController:viewController animated:YES];
}

/*
#pragma mark - Location manager delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    }
}
 */

@end
