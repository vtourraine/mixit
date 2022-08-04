//
//  AMGTalksSearchResultsViewController.m
//  mixit
//
//  Created by Vincent Tourraine on 25/09/2017.
//  Copyright © 2017 Studio AMANgA. All rights reserved.
//

#import "AMGTalksSearchResultsViewController.h"

#import "AMGTalk.h"
#import "AMGTalkCell.h"

@interface AMGTalksSearchResultsViewController ()

@end

@implementation AMGTalksSearchResultsViewController

#pragma mark - View life cycle

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:AMGTalkCell.class forCellReuseIdentifier:@"Cell"];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMGTalk *talk = self.searchResults[indexPath.row];

    AMGTalkCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell configureWithTalk:talk isPastYear:NO];

    return cell;
}

@end
