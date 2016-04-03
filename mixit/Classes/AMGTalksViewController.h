//
//  AMGTalksViewController.h
//  mixit
//
//  Created by Vincent Tourraine on 01/05/14.
//  Copyright (c) 2014-2016 Studio AMANgA. All rights reserved.
//

@import UIKit;

@class AMGMixITSyncManager, AMGTalk;

@interface AMGTalksViewController : UITableViewController

@property (nonatomic, strong, nullable) AMGMixITSyncManager *syncManager;
@property (nonatomic, copy, nullable) NSNumber *year;

@end


@interface AMGTalksSection : NSObject <NSFetchedResultsSectionInfo>

@property (nonatomic, copy, nullable) NSArray <AMGTalk *> *talks;
@property (nonatomic, copy, nullable) NSDate *date;
@property (nonatomic, assign) BOOL firstSectionForTheDay;

@end
