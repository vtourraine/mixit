//
//  AMGTalksViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGMixITSyncManager;

@interface AMGTalksViewController : UITableViewController

@property (nonatomic, strong) AMGMixITSyncManager *syncManager;

@end


@interface AMGTalksSection : NSObject <NSFetchedResultsSectionInfo>

@property (nonatomic, copy) NSArray *talks;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) BOOL firstSectionForTheDay;

@end
