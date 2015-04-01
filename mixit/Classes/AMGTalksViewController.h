//
//  AMGTalksViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2015 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGMixITSyncManager;

@interface AMGTalksViewController : UITableViewController

@property (nonatomic, strong) AMGMixITSyncManager *syncManager;

@end


@interface AMGTalksSection : NSObject <NSFetchedResultsSectionInfo>

@property (nonatomic, copy) NSArray *talks;

@end
