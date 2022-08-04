//
//  AMGTalksSearchResultsViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 25/09/2017.
//  Copyright © 2017 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGTalk;


@interface AMGTalksSearchResultsViewController : UITableViewController

@property (nonatomic, strong, nullable) NSArray <AMGTalk *> *searchResults;

@end
